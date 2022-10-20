// SPDX-License-Identifier: GPL-2.0-only

#include <linux/delay.h>
#include <linux/dma-mapping.h>
#include <linux/err.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/iopoll.h>
#include <linux/platform_device.h>
#include <linux/clk.h>
#include <linux/io.h>
#include <linux/of.h>
#include <linux/of_device.h>
#include <linux/pinctrl/consumer.h>
#include <linux/regulator/consumer.h>
#include <linux/reset.h>
#include <linux/mmc/card.h>
#include <linux/mmc/host.h>
#include <linux/mmc/mmc.h>
#include <linux/mmc/slot-gpio.h>
#include <linux/ktime.h>

/*
 * AXI SD Card driver.
 *
 * AXI SD Card is open source Verilog implementation of high speed SD card controller.
 * It is mainly used in FPGA designs.
 */

#ifdef CONFIG_DEBUG_INFO
#pragma GCC optimize("O0")
#endif

// Capability bits
#define SDC_CAPABILITY_SD_4BIT  0x0001
#define SDC_CAPABILITY_SD_RESET 0x0002

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

#define CMD_TIMEOUT_MS 1000
#define BUSY_TIMEOUT_MS 500

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
    volatile uint32_t dma_addres;
};

struct sdc_host {
    struct platform_device * pdev;
    struct sdc_regs __iomem * regs;
    uint32_t clk_freq;
    spinlock_t lock;
    struct mmc_request * mrq;
    struct mmc_data * data;
    int irq;
};

static const struct of_device_id axi_sdc_of_match_table[] = {
    { .compatible = "riscv,axi-sd-card-1.0" },
    {},
};
MODULE_DEVICE_TABLE(of, axi_sdc_of_match_table);

/* Set clock prescalar value based on the required clock in HZ */
static void sdc_set_clock(struct sdc_host * host, uint clock) {
    unsigned clk_div;

    /* Min clock frequency should be 400KHz */
    if (clock < 400000) clock = 400000;

    clk_div = host->clk_freq / (2 * clock);
    if (clk_div > 0x100) clk_div = 0x100;
    if (clk_div < 1) clk_div = 1;

    if (host->regs->clock_divider != clk_div - 1) {
        host->regs->clock_divider = clk_div - 1;
        udelay(10000);
    }
}

static int sdc_cmd_finish(struct sdc_host * host, struct mmc_command * cmd) {
    while (1) {
        unsigned status = host->regs->cmd_int_status;
        if (status) {
            // clear interrupts
            host->regs->cmd_int_status = 0;
            while (host->regs->software_reset != 0) {}
            if (status == SDC_CMD_INT_STATUS_CC) {
                // get response
                cmd->resp[0] = host->regs->response1;
                if (cmd->flags & MMC_RSP_136) {
                    cmd->resp[1] = host->regs->response2;
                    cmd->resp[2] = host->regs->response3;
                    cmd->resp[3] = host->regs->response4;
                }
                return 0;
            }
            if (status & SDC_CMD_INT_STATUS_CTE) return cmd->error = -ETIME;
            cmd->error = -EIO;
            break;
        }
    }
    return cmd->error;
}

static int sdc_setup_data_xfer(struct sdc_host * host, struct mmc_host * mmc, struct mmc_data * data) {
    uint64_t addr = sg_phys(data->sg);
    uint64_t timeout = 0;

    data->bytes_xfered = 0;

    if (addr & 3) return -EINVAL;
    if (data->blksz & 3) return -EINVAL;
    if (data->blksz < 4) return -EINVAL;
    if (data->blksz > 0x1000) return -EINVAL;
    if (data->blocks > 0x10000) return -EINVAL;
    if (addr + data->blksz * data->blocks > 0x100000000) return -EINVAL;
    if (data->sg->length < data->blksz * data->blocks) return -EINVAL;

    // SD card data transfer time
    timeout += data->blocks * data->blksz * 8 / (1 << mmc->ios.bus_width);
    // SD card "busy" time
    timeout += (uint64_t)mmc->ios.clock * BUSY_TIMEOUT_MS / 1000 * data->blocks;

    host->regs->dma_addres = (uint32_t)addr;
    host->regs->block_size = data->blksz - 1;
    host->regs->block_count = data->blocks - 1;
    host->regs->data_timeout = (uint32_t)timeout;
    if (host->regs->data_timeout != timeout) host->regs->data_timeout = 0;

    return 0;
}

static int sdc_send_cmd(struct sdc_host * host, struct mmc_host * mmc, struct mmc_command * cmd, struct mmc_data * data) {
    int command = cmd->opcode << 8;
    uint64_t timeout = 0;
    int xfer = 0;

    if (cmd->flags & MMC_RSP_PRESENT) {
        if (cmd->flags & MMC_RSP_136)
            command |= 2;
        else {
            command |= 1;
        }
    }
    if (cmd->flags & MMC_RSP_BUSY) command |= 1 << 2;
    if (cmd->flags & MMC_RSP_CRC) command |= 1 << 3;
    if (cmd->flags & MMC_RSP_OPCODE) command |= 1 << 4;

    if (data && (data->flags & (MMC_DATA_READ | MMC_DATA_WRITE)) && data->blocks) {
        if (data->flags & MMC_DATA_READ) command |= 1 << 5;
        if (data->flags & MMC_DATA_WRITE) command |= 1 << 6;
        data->error = sdc_setup_data_xfer(host, mmc, data);
        if (data->error < 0) return data->error;
        xfer = 1;
    }

    timeout = (uint64_t)mmc->ios.clock * CMD_TIMEOUT_MS / 1000;

    host->regs->command = command;
    host->regs->cmd_timeout = (uint32_t)timeout;
    if (host->regs->cmd_timeout != timeout) host->regs->cmd_timeout = 0;
    host->regs->argument = cmd->arg;

    if (sdc_cmd_finish(host, cmd) < 0) return cmd->error;
    if (xfer) host->data = data;

    return 0;
}

static void sdc_request(struct mmc_host * mmc, struct mmc_request * mrq) {
    struct sdc_host * host = mmc_priv(mmc);

    /* Clear the error statuses in case this is a retry */
    if (mrq->sbc) mrq->sbc->error = 0;
    if (mrq->cmd) mrq->cmd->error = 0;
    if (mrq->data) mrq->data->error = 0;
    if (mrq->stop) mrq->stop->error = 0;

    spin_lock_irq(&host->lock);
    host->data = NULL;
    host->mrq = mrq;

    if (!mrq->sbc || sdc_send_cmd(host, mmc, mrq->sbc, NULL) == 0) {
        sdc_send_cmd(host, mmc, mrq->cmd, mrq->data);
    }

    if (host->data == NULL) {
        mmc_request_done(mmc, mrq);
        host->mrq = NULL;
    }
    else {
        host->regs->dat_int_enable = SDC_DAT_INT_STATUS_TRS | SDC_DAT_INT_STATUS_ERR;
    }

    spin_unlock_irq(&host->lock);
}

static void sdc_set_ios(struct mmc_host * mmc, struct mmc_ios * ios) {
    struct sdc_host * host = mmc_priv(mmc);

    spin_lock_irq(&host->lock);

    sdc_set_clock(host, ios->clock);
    host->regs->control = ios->bus_width == MMC_BUS_WIDTH_4 ? SDC_CONTROL_SD_4BIT : 0;

    spin_unlock_irq(&host->lock);
}

static void sdc_reset(struct mmc_host * mmc) {
    struct sdc_host * host = mmc_priv(mmc);
    uint32_t card_detect = 0;

    spin_lock_irq(&host->lock);

    sdc_set_clock(host, 400000);

    // software reset
    host->regs->software_reset = 1;
    while ((host->regs->software_reset & 1) == 0) {}
    // clear software reset
    host->regs->software_reset = 0;
    while (host->regs->software_reset != 0) {}
    udelay(10000);

    // set bus width 1 bit
    host->regs->control = 0;

    // disable cmd/data interrupts
    host->regs->cmd_int_enable = 0;
    host->regs->dat_int_enable = 0;
    // clear cmd/data interrupts
    host->regs->cmd_int_status = 0;
    host->regs->dat_int_status = 0;
    // enable card detect interrupt
    card_detect = host->regs->card_detect;
    if (card_detect & SDC_CARD_INSERT_INT_REQ) {
        host->regs->card_detect = SDC_CARD_REMOVE_INT_EN;
    }
    else if (card_detect & SDC_CARD_REMOVE_INT_REQ) {
        host->regs->card_detect = SDC_CARD_INSERT_INT_EN;
    }
    while (host->regs->software_reset != 0) {}

    spin_unlock_irq(&host->lock);
}

static void sdc_card_reset(struct mmc_host * mmc) {
    struct sdc_host * host = mmc_priv(mmc);
    uint32_t control = 0;

    spin_lock_irq(&host->lock);

    control = host->regs->control;
    host->regs->control = control | SDC_CONTROL_SD_RESET;
    udelay(10);
    host->regs->control = control & ~(uint32_t)SDC_CONTROL_SD_RESET;
    udelay(10);

    spin_unlock_irq(&host->lock);
}

static int sdc_get_cd(struct mmc_host * mmc) {
    struct sdc_host * host = mmc_priv(mmc);
    uint32_t card_detect = host->regs->card_detect;
    if (card_detect == 0) return 1; /* Card detect not supported */
    return (card_detect & SDC_CARD_INSERT_INT_REQ) != 0;
}

static irqreturn_t sdc_isr(int irq, void * dev_id) {
    struct mmc_host * mmc = (struct mmc_host *)dev_id;
    struct sdc_host * host = mmc_priv(mmc);
    uint32_t card_detect = 0;
    uint32_t data_status = 0;
    unsigned long flags;

    spin_lock_irqsave(&host->lock, flags);

    card_detect = host->regs->card_detect;
    if (card_detect & SDC_CARD_INSERT_INT_REQ) {
        if (card_detect & SDC_CARD_INSERT_INT_EN) {
            host->regs->card_detect = SDC_CARD_REMOVE_INT_EN;
            mmc_detect_change(mmc, 0);
        }
    }
    else if (card_detect & SDC_CARD_REMOVE_INT_REQ) {
        if (card_detect & SDC_CARD_REMOVE_INT_EN) {
            host->regs->card_detect = SDC_CARD_INSERT_INT_EN;
            mmc_detect_change(mmc, 0);
        }
    }

    if ((data_status = host->regs->dat_int_status) != 0) {
        host->regs->dat_int_enable = 0;
        host->regs->dat_int_status = 0;
        while (host->regs->software_reset != 0) {}
        if (host->data) {
            struct mmc_request * mrq = host->mrq;
            struct mmc_data * data = host->data;
            if (data_status == SDC_DAT_INT_STATUS_TRS) {
                data->bytes_xfered = data->blksz * data->blocks;
            }
            else {
                data->error = -EIO;
                if (data_status & SDC_DAT_INT_STATUS_CTE) data->error = -ETIME;
            }
            if (mrq->stop) sdc_send_cmd(host, mmc, mrq->stop, NULL);
            mmc_request_done(mmc, mrq);
            host->data = NULL;
            host->mrq = NULL;
        }
    }

    spin_unlock_irqrestore(&host->lock, flags);
    return IRQ_HANDLED;
}

/*---------------------------------------------------------------------*/

static const struct mmc_host_ops axi_sdc_ops = {
    .request = sdc_request,
    .set_ios = sdc_set_ios,
    .get_cd = sdc_get_cd,
    .card_hw_reset = sdc_card_reset,
};

static int axi_sdc_probe(struct platform_device * pdev) {
    struct device * dev = &pdev->dev;
    struct resource * iomem;
    struct sdc_host * host;
    struct mmc_host * mmc;
    void __iomem * ioaddr;
    int irq;
    int ret;

    iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    ioaddr = devm_ioremap_resource(dev, iomem);
    if (IS_ERR(ioaddr)) return PTR_ERR(ioaddr);

    irq = platform_get_irq(pdev, 0);
    if (irq <= 0) return -ENXIO;

    mmc = mmc_alloc_host(sizeof(*host), dev);
    if (!mmc) return -ENOMEM;

    mmc->ops = &axi_sdc_ops;
    host = mmc_priv(mmc);
    host->pdev = pdev;
    host->regs = (struct sdc_regs __iomem *)ioaddr;
    host->irq = irq;

    ret = of_property_read_u32(dev->of_node, "clock", &host->clk_freq);
    if (ret) host->clk_freq = 100000000;

    ret = mmc_of_parse(mmc);
    if (ret) {
        mmc_free_host(mmc);
        return ret;
    }

    if (mmc->f_min == 0) mmc->f_min = host->clk_freq / 0x200; /* maximum clock division 256 * 2 */
    if (mmc->f_max == 0) mmc->f_max = host->clk_freq / 2; /* minimum clock division 2 */
    if ((mmc->caps2 & MMC_CAP2_NO_SDIO) == 0) {
        /* TODO: deprecated 10/19/2022, set in DTS */
        mmc->caps |= MMC_CAP_SD_HIGHSPEED | MMC_CAP_MMC_HIGHSPEED;
        mmc->caps2 |= MMC_CAP2_NO_SDIO;
    }
    mmc->ocr_avail = MMC_VDD_32_33 | MMC_VDD_33_34;
    mmc->max_segs = 1;
    mmc->max_req_size = 0x2000000;
    mmc->max_seg_size = 0x2000000;
    mmc->max_blk_size = 0x1000;
    mmc->max_blk_count = 0x10000;

    ret = request_irq(host->irq, sdc_isr, IRQF_TRIGGER_HIGH, "fpga-axi-sdc", mmc);
    if (ret) {
        mmc_free_host(mmc);
        return ret;
    }

    ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
    if (ret) {
        printk(KERN_ERR "AXI-SDC: Can't set DMA mask\n");
        mmc_free_host(mmc);
        return ret;
    }

    sdc_reset(mmc);

    ret = mmc_add_host(mmc);
    if (ret) {
        printk(KERN_ERR "AXI-SDC: Can't register device\n");
        mmc_free_host(mmc);
        return ret;
    }

    spin_lock_init(&host->lock);

    platform_set_drvdata(pdev, host);
    return 0;
}

static int axi_sdc_remove(struct platform_device * pdev) {
    struct sdc_host * host = platform_get_drvdata(pdev);
    struct mmc_host * mmc = mmc_from_priv(host);

    free_irq(host->irq, mmc);
    mmc_remove_host(mmc);
    mmc_free_host(mmc);
    return 0;
}

static struct platform_driver axi_sdc_driver = {
    .driver = {
        .name = "riscv-axi-sdc",
        .of_match_table = axi_sdc_of_match_table,
    },
    .probe = axi_sdc_probe,
    .remove = axi_sdc_remove,
};

module_platform_driver(axi_sdc_driver);

MODULE_DESCRIPTION("AXI SD Card driver");
MODULE_AUTHOR("Eugene Tarassov");
MODULE_LICENSE("GPL v2");
