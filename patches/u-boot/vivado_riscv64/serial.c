// SPDX-License-Identifier: GPL-2.0+

#include <config.h>
#include <common.h>
#include <dm.h>
#include <asm/io.h>
#include <linux/compiler.h>
#include <serial.h>

#define SR_RX_FIFO_VALID_DATA   (1 << 0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1 << 1) /* receive FIFO full    */
#define SR_TX_FIFO_EMPTY        (1 << 2) /* transmit FIFO empty  */
#define SR_TX_FIFO_FULL         (1 << 3) /* transmit FIFO full   */

#define ULITE_CONTROL_RST_TX    0x01
#define ULITE_CONTROL_RST_RX    0x02

struct axi_uart_regs {
    unsigned int rx_fifo;
    unsigned int tx_fifo;
    unsigned int status;
    unsigned int control;
};

struct axi_uart_data {
    struct axi_uart_regs * regs;
};

static int axi_uart_putc(struct udevice * dev, const char ch) {
    struct axi_uart_data * plat = dev_get_plat(dev);
    struct axi_uart_regs * regs = plat->regs;

    if (in_le32(&regs->status) & SR_TX_FIFO_FULL) return -EAGAIN;

    out_le32(&regs->tx_fifo, ch & 0xff);

    return 0;
}

static int axi_uart_getc(struct udevice * dev) {
    struct axi_uart_data * plat = dev_get_plat(dev);
    struct axi_uart_regs * regs = plat->regs;

    if (!(in_le32(&regs->status) & SR_RX_FIFO_VALID_DATA)) return -EAGAIN;

    return in_le32(&regs->rx_fifo) & 0xff;
}

static int axi_uart_pending(struct udevice * dev, bool input) {
    struct axi_uart_data * plat = dev_get_plat(dev);
    struct axi_uart_regs * regs = plat->regs;

    if (input) return in_le32(&regs->status) & SR_RX_FIFO_VALID_DATA;

    return !(in_le32(&regs->status) & SR_TX_FIFO_EMPTY);
}

static int axi_uart_probe(struct udevice * dev) {
    struct axi_uart_data * plat = dev_get_plat(dev);
    struct axi_uart_regs * regs = plat->regs;

    out_le32(&regs->control, ULITE_CONTROL_RST_RX | ULITE_CONTROL_RST_TX);

    return 0;
}

static int axi_uart_of_to_plat(struct udevice * dev) {
    struct axi_uart_data * plat = dev_get_plat(dev);

    plat->regs = (struct axi_uart_regs *)dev_read_addr(dev);

    return 0;
}

static const struct dm_serial_ops axi_uart_ops = {
    .putc = axi_uart_putc,
    .pending = axi_uart_pending,
    .getc = axi_uart_getc,
};

static const struct udevice_id axi_uart_ids[] = {
    { .compatible = "xlnx,opb-uartlite-1.00.b", },
    { .compatible = "xlnx,xps-uartlite-1.00.a" },
    { .compatible = "riscv,axi-uart-1.0" },
    { }
};

U_BOOT_DRIVER(serial_axi_uart) = {
    .name   = "axi-uart",
    .id = UCLASS_SERIAL,
    .of_match = axi_uart_ids,
    .of_to_plat = axi_uart_of_to_plat,
    .plat_auto = sizeof(struct axi_uart_data),
    .probe = axi_uart_probe,
    .ops = &axi_uart_ops,
};
