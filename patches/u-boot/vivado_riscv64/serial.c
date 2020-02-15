// SPDX-License-Identifier: GPL-2.0+
/*
 * (C) Copyright 2008 - 2015 Michal Simek <monstr@monstr.eu>
 * Clean driver and add xilinx constant from header file
 *
 * (C) Copyright 2004 Atmark Techno, Inc.
 * Yasushi SHOJI <yashi@atmark-techno.com>
 */

#include <config.h>
#include <common.h>
#include <dm.h>
#include <asm/io.h>
#include <linux/compiler.h>
#include <serial.h>

#define SR_TX_FIFO_FULL         BIT(3) /* transmit FIFO full */
#define SR_TX_FIFO_EMPTY        BIT(2) /* transmit FIFO empty */
#define SR_RX_FIFO_VALID_DATA   BIT(0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         BIT(1) /* receive FIFO full */

#define ULITE_CONTROL_RST_TX    0x01
#define ULITE_CONTROL_RST_RX    0x02

struct uartlite_regs {
    unsigned int rx_fifo;
    unsigned int tx_fifo;
    unsigned int status;
    unsigned int control;
};

struct uartlite_platdata {
    struct uartlite_regs *regs;
};

static int uartlite_serial_putc(struct udevice *dev, const char ch)
{
    struct uartlite_platdata *plat = dev_get_platdata(dev);
    struct uartlite_regs *regs = plat->regs;

    if (in_le32(&regs->status) & SR_TX_FIFO_FULL) return -EAGAIN;

    out_le32(&regs->tx_fifo, ch & 0xff);

    return 0;
}

static int uartlite_serial_getc(struct udevice *dev)
{
    struct uartlite_platdata *plat = dev_get_platdata(dev);
    struct uartlite_regs *regs = plat->regs;

    if (!(in_le32(&regs->status) & SR_RX_FIFO_VALID_DATA)) return -EAGAIN;

    return in_le32(&regs->rx_fifo) & 0xff;
}

static int uartlite_serial_pending(struct udevice *dev, bool input)
{
    struct uartlite_platdata *plat = dev_get_platdata(dev);
    struct uartlite_regs *regs = plat->regs;

    if (input) return in_le32(&regs->status) & SR_RX_FIFO_VALID_DATA;

    return !(in_le32(&regs->status) & SR_TX_FIFO_EMPTY);
}

static int uartlite_serial_probe(struct udevice *dev)
{
    struct uartlite_platdata *plat = dev_get_platdata(dev);
    struct uartlite_regs *regs = plat->regs;

    out_le32(&regs->control, 0);
    out_le32(&regs->control, ULITE_CONTROL_RST_RX | ULITE_CONTROL_RST_TX);

    return 0;
}

static int uartlite_serial_ofdata_to_platdata(struct udevice *dev)
{
    struct uartlite_platdata *plat = dev_get_platdata(dev);

    plat->regs = (struct uartlite_regs *)devfdt_get_addr(dev);

    return 0;
}

static const struct dm_serial_ops uartlite_serial_ops = {
    .putc = uartlite_serial_putc,
    .pending = uartlite_serial_pending,
    .getc = uartlite_serial_getc,
};

static const struct udevice_id uartlite_serial_ids[] = {
    { .compatible = "xlnx,xps-uartlite-1.00.a" },
    { }
};

U_BOOT_DRIVER(serial_uartlite) = {
    .name   = "uartlite-1.0",
    .id = UCLASS_SERIAL,
    .of_match = uartlite_serial_ids,
    .ofdata_to_platdata = uartlite_serial_ofdata_to_platdata,
    .platdata_auto_alloc_size = sizeof(struct uartlite_platdata),
    .probe = uartlite_serial_probe,
    .ops    = &uartlite_serial_ops,
};
