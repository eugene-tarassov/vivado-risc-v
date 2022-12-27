/*
 *
 * Copyright (C) 2013-2021 Authors
 *
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 *
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 *
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from https://www.gnu.org/licenses/licenses.html
 */

#include <common.h>
#include <malloc.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <command.h>
#include <dm.h>
#include <dm/device_compat.h>
#include <linux/delay.h>
#include <mmc.h>

/*
* AXI SD Card driver.
*
* AXI SD Card is open source Verilog implementation of high speed SD card controller.
* It is mainly used in FPGA designs.
*/

// Capability bits
#define SDC_CAPABILITY_SD_4BIT  0x0001
#define SDC_CAPABILITY_SD_RESET 0x0002
#define SDC_CAPABILITY_ADDR     0xff00

// Control bits
#define SDC_CONTROL_SD_4BIT     0x0001
#define SDC_CONTROL_SD_RESET    0x0002

// Card detect bits
#define SDC_CARD_INSERT_INT_EN  0x0001
#define SDC_CARD_INSERT_INT_REQ 0x0002
#define SDC_CARD_REMOVE_INT_EN  0x0004
#define SDC_CARD_REMOVE_INT_REQ 0x0008

// Command status bits
#define SDC_CMD_INT_STATUS_CC   0x0001  // Command complete
#define SDC_CMD_INT_STATUS_EI   0x0002  // Any error
#define SDC_CMD_INT_STATUS_CTE  0x0004  // Timeout
#define SDC_CMD_INT_STATUS_CCRC 0x0008  // CRC error
#define SDC_CMD_INT_STATUS_CIE  0x0010  // Command code check error

// Data status bits
#define SDC_DAT_INT_STATUS_TRS  0x0001  // Transfer complete
#define SDC_DAT_INT_STATUS_ERR  0x0002  // Any error
#define SDC_DAT_INT_STATUS_CTE  0x0004  // Timeout
#define SDC_DAT_INT_STATUS_CRC  0x0008  // CRC error
#define SDC_DAT_INT_STATUS_CFE  0x0010  // Data FIFO underrun or overrun

#define CMD_TIMEOUT 0xfffff

struct sdc_regs {
    volatile uint32_t argument;
    volatile uint32_t command;
    volatile uint32_t response1;
    volatile uint32_t response2;
    volatile uint32_t response3;
    volatile uint32_t response4;
    volatile uint32_t data_timeout;
    volatile uint32_t control;
    volatile uint32_t cmd_timeout;
    volatile uint32_t clock_divider;
    volatile uint32_t software_reset;
    volatile uint32_t power_control;
    volatile uint32_t capability;
    volatile uint32_t cmd_int_status;
    volatile uint32_t cmd_int_enable;
    volatile uint32_t dat_int_status;
    volatile uint32_t dat_int_enable;
    volatile uint32_t block_size;
    volatile uint32_t block_count;
    volatile uint32_t card_detect;
    volatile uint32_t res_50;
    volatile uint32_t res_54;
    volatile uint32_t res_58;
    volatile uint32_t res_5c;
    volatile uint64_t dma_addres;
};

struct sdc_priv {
    struct sdc_regs * regs;
    uint32_t dma_addr_bits;
    uint32_t clk_freq;
    int acmd;
};

struct sdc_plat {
    struct mmc_config cfg;
    struct mmc mmc;
};

/* Set clock prescalar value based on the required clock in HZ */
static void sdc_set_clock(struct sdc_priv * priv, uint clock) {
    /* Min clock frequency should be 400KHz */
    //if (mmc->clk_disable) clock = 400000;
    if (clock < 400000) clock = 400000;

    unsigned clk_div = priv->clk_freq / (2 * clock);
    if (clk_div > 0x100) clk_div = 0x100;
    if (clk_div < 1) clk_div = 1;

    priv->regs->clock_divider = clk_div - 1;
    udelay(10000);
}

static int sdc_finish(struct sdc_priv * dev, struct mmc_cmd * cmd) {
    while (1) {
        unsigned status = dev->regs->cmd_int_status;
        if (status) {
            // clear interrupts
            dev->regs->cmd_int_status = 0;
            while (dev->regs->software_reset != 0) {}
            if (status == SDC_CMD_INT_STATUS_CC) {
                // get response
                cmd->response[0] = dev->regs->response1;
                if (cmd->resp_type & MMC_RSP_136) {
                    cmd->response[1] = dev->regs->response2;
                    cmd->response[2] = dev->regs->response3;
                    cmd->response[3] = dev->regs->response4;
                }
                dev->acmd = cmd->cmdidx == MMC_CMD_APP_CMD;
                return 0;
            }
            break;
        }
    }
    return -1;
}

static int sdc_data_finish(struct sdc_priv * dev) {
    int status;

    while ((status = dev->regs->dat_int_status) == 0) {}
    dev->regs->dat_int_status = 0;
    while (dev->regs->software_reset != 0) {}

    if (status == SDC_DAT_INT_STATUS_TRS) return 0;

    int command = (MMC_CMD_STOP_TRANSMISSION << 8) | 1 | (1 << 2) | (1 << 3) | (1 << 4);
    dev->regs->command = command;
    dev->regs->cmd_timeout = CMD_TIMEOUT;
    dev->regs->argument = 0;
    while ((status = dev->regs->cmd_int_status) == 0) {}
    dev->regs->cmd_int_status = 0;
    while (dev->regs->software_reset != 0) {}

    return -1;
}

static int sdc_setup_data_xfer(struct sdc_priv * dev, struct mmc * mmc, struct mmc_data * data) {
    uint64_t addr = (uint64_t)(data->flags & MMC_DATA_READ ? data->dest : data->src);

    if (addr & 3) return -1;
    if (data->blocksize & 3) return -1;
    if (data->blocksize < 4) return -1;
    if (data->blocksize > 0x1000) return -1;
    if (data->blocks > 0x10000) return -1;
    if (addr + data->blocksize * data->blocks > ((uint64_t)1 << dev->dma_addr_bits)) return -1;

    uint64_t timeout = (uint64_t)data->blocks * data->blocksize * 8 / mmc->bus_width;
    timeout += (uint64_t)mmc->clock / 1000 * data->blocks;
    timeout += (uint64_t)mmc->clock / 100; // 10ms
    if (timeout > 0xffffff) timeout = 0;

    dev->regs->dma_addres = addr;
    dev->regs->block_size = data->blocksize - 1;
    dev->regs->block_count = data->blocks - 1;
    dev->regs->data_timeout = (uint32_t)timeout;

    return 0;
}

static int sdc_probe(struct udevice * udev) {
    struct sdc_priv * priv = dev_get_priv(udev);
    struct sdc_plat * plat = dev_get_plat(udev);
    struct mmc_uclass_priv * upriv = dev_get_uclass_priv(udev);
    struct mmc_config * cfg = &plat->cfg;
    uint32_t capability;

    fdt_addr_t addr = dev_read_addr(udev);
    if (addr == FDT_ADDR_T_NONE) {
        dev_err(udev, "failed to parse device address\n");
        return -EINVAL;
    }
    priv->regs = (struct sdc_regs *)addr;

    priv->clk_freq = dev_read_u32_default(udev, "clock", 100000000);

    int error = mmc_of_parse(udev, cfg);
    if (error < 0) {
        dev_err(udev, "failed to parse host caps\n");
        return error;
    }

    cfg->name = udev->name;
    cfg->f_min = priv->clk_freq / 0x200; /* maximum clock division 256 * 2 */
    if (cfg->f_max == 0) cfg->f_max = priv->clk_freq / 2; /* minimum clock division 2 */
    cfg->voltages = MMC_VDD_32_33 | MMC_VDD_33_34;
    if (cfg->host_caps == 0) cfg->host_caps = MMC_MODE_4BIT | MMC_MODE_HS;
    cfg->b_max = 0x10000;

    priv->dma_addr_bits = 32;
    capability = priv->regs->capability;
    if (capability & SDC_CAPABILITY_ADDR) {
        priv->dma_addr_bits = (capability & SDC_CAPABILITY_ADDR) >> __builtin_ctz(SDC_CAPABILITY_ADDR);
    }

    sdc_set_clock(priv, 400000);

    // software reset
    priv->regs->software_reset = 1;
    while ((priv->regs->software_reset & 1) == 0) {}
    // clear software reset
    priv->regs->software_reset = 0;
    while (priv->regs->software_reset != 0) {}
    udelay(10000);

    priv->regs->control = 0;

    upriv->mmc = &plat->mmc;

    return 0;
}

#if CONFIG_IS_ENABLED(DM_MMC)

static int sdc_get_cd(struct udevice * udev) {
    //struct sdc_priv * priv = dev_get_priv(udev);
    /* TODO: card detect not supported yet */
    return 1;
}

static int sdc_send_cmd(struct udevice * udev, struct mmc_cmd * cmd, struct mmc_data * data) {
    struct sdc_priv * dev = dev_get_priv(udev);

    int xfer = 0;
    int command = cmd->cmdidx << 8;
    if (cmd->resp_type & MMC_RSP_PRESENT) {
        if (cmd->resp_type & MMC_RSP_136)
            command |= 2;
        else {
            command |= 1;
        }
    }
    if (cmd->resp_type & MMC_RSP_BUSY  ) command |= 1 << 2;
    if (cmd->resp_type & MMC_RSP_CRC   ) command |= 1 << 3;
    if (cmd->resp_type & MMC_RSP_OPCODE) command |= 1 << 4;

    if (data && (data->flags & (MMC_DATA_READ | MMC_DATA_WRITE)) && data->blocks) {
        struct sdc_plat * plat = dev_get_plat(udev);
        if (data->flags & MMC_DATA_READ ) command |= 1 << 5;
        if (data->flags & MMC_DATA_WRITE) command |= 1 << 6;
        if (sdc_setup_data_xfer(dev, &plat->mmc, data) < 0) return -1;
        xfer = 1;
    }

    dev->regs->command = command;
    dev->regs->cmd_timeout = CMD_TIMEOUT;
    dev->regs->argument = cmd->cmdarg;

    if (sdc_finish(dev, cmd) < 0) return -1;
    if (xfer && sdc_data_finish(dev) < 0) return -1;

    return 0;
}

static int sdc_set_ios(struct udevice * udev) {
    struct sdc_plat * plat = dev_get_plat(udev);
    struct sdc_priv * dev = dev_get_priv(udev);
    struct mmc * mmc = &plat->mmc;

    sdc_set_clock(dev, mmc->clock);
    dev->regs->control = mmc->bus_width >= 4 ? SDC_CONTROL_SD_4BIT : 0;

    // disable all interrupts
    dev->regs->cmd_int_enable = 0;
    dev->regs->dat_int_enable = 0;
    // clear all interrupts
    dev->regs->cmd_int_status = 0;
    dev->regs->dat_int_status = 0;
    while (dev->regs->software_reset != 0) {}

    return 0;
}

#if CONFIG_IS_ENABLED(BLK)
static int sdc_bind(struct udevice * dev) {
    struct sdc_plat * plat = dev_get_plat(dev);
    return mmc_bind(dev, &plat->mmc, &plat->cfg);
}
#endif

static const struct dm_mmc_ops sdc_ops = {
    .get_cd = sdc_get_cd,
    .send_cmd = sdc_send_cmd,
    .set_ios = sdc_set_ios,
};

static const struct udevice_id mmc_ids[] = {
    { .compatible = "riscv,axi-sd-card-1.0" },
    {}
};

U_BOOT_DRIVER(sdc_priv) = {
    .name = "axi-sd-card-1.0",
    .id = UCLASS_MMC,
    .of_match = mmc_ids,
    .ops = &sdc_ops,
#if CONFIG_IS_ENABLED(BLK)
    .bind = sdc_bind,
#endif
    .probe = sdc_probe,
    .plat_auto = sizeof(struct sdc_plat),
    .priv_auto = sizeof(struct sdc_priv),
};

#endif /* CONFIG_IS_ENABLED(DM_MMC) */
