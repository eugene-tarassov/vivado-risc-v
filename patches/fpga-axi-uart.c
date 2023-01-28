// SPDX-License-Identifier: GPL-2.0-or-later

#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/interrupt.h>
#include <linux/platform_device.h>
#include <linux/serial_core.h>
#include <linux/serial.h>
#include <linux/console.h>
#include <linux/tty.h>
#include <linux/tty_flip.h>
#include <linux/of.h>

/*
* AXI UART driver.
*
* AXI UART is open source Verilog implementation of simple serial UART.
* It is mainly used in FPGA designs.
*/

#ifdef CONFIG_DEBUG_INFO
#pragma GCC optimize("O0")
#endif

#define SR_RX_FIFO_VALID    (1 << 0) /* receive FIFO not empty */
#define SR_RX_FIFO_FULL     (1 << 1) /* receive FIFO full      */
#define SR_TX_FIFO_EMPTY    (1 << 2) /* transmit FIFO empty    */
#define SR_TX_FIFO_FULL     (1 << 3) /* transmit FIFO full     */
#define SR_CTS              (1 << 4) /* clear to send          */

#define CR_RESET_RX_FIFO    (1 << 0) /* reset receive FIFO     */
#define CR_RESET_TX_FIFO    (1 << 1) /* reset transmit FIFO    */
#define CR_IE_RX_READY      (1 << 4) /* enable receive ready interrupt  */
#define CR_IE_TX_READY      (1 << 5) /* enable transmit ready interrupt */
#define CR_TX_STOP          (1 << 6) /* stop transmit          */

struct uart_regs {
    volatile uint32_t rx_fifo;
    volatile uint32_t tx_fifo;
    volatile uint32_t status;
    volatile uint32_t control;
};

#define DRIVER_NAME "axi-uart"
#define DEVICE_NAME "ttyAU"
#define PORT_AXI_UART 74
#define MAX_PORTS  CONFIG_SERIAL_AXI_UART_PORTS
static struct uart_port axi_uart_ports[MAX_PORTS];

#define MAX_CHARS_PER_INTERRUPT 32

#ifdef CONFIG_SERIAL_AXI_UART_CONSOLE
static void axi_uart_console_putchar(struct uart_port * port, unsigned char ch) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    while (regs->status & SR_TX_FIFO_FULL) {}
    regs->tx_fifo = ch;
}

static void axi_uart_console_write(struct console * con, const char * s, unsigned n) {
    struct uart_port * port = axi_uart_ports + con->index;
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    unsigned long flags;
    uint32_t control;

    spin_lock_irqsave(&port->lock, flags);
    control = regs->control;
    regs->control = control & ~CR_TX_STOP;
    uart_console_write(port, s, n, axi_uart_console_putchar);
    if (control & CR_TX_STOP) {
        while ((regs->status & SR_TX_FIFO_EMPTY) == 0) {}
        regs->control = control;
    }
    spin_unlock_irqrestore(&port->lock, flags);
}

static int axi_uart_console_setup(struct console * con, char * options) {
    struct uart_port * port;
    int baud = 115200;
    int bits = 8;
    int parity = 'n';
    int flow = 'n';

    if (con->index < 0 || con->index >= MAX_PORTS) con->index = 0;
    port = axi_uart_ports + con->index;
    if (!port->membase) return -ENODEV;

    if (options) uart_parse_options(options, &baud, &parity, &bits, &flow);

    return uart_set_options(port, con, baud, parity, bits, flow);
}

static struct uart_driver axi_uart_port_driver;

static struct console axi_uart_console = {
    .name = DEVICE_NAME,
    .device = uart_console_device,
    .setup = axi_uart_console_setup,
    .write = axi_uart_console_write,
    .flags = CON_PRINTBUFFER,
    .index = -1,
    .data = &axi_uart_port_driver,
};

static void axi_uart_early_write(struct console * con, const char * s, unsigned n) {
    struct earlycon_device * dev = con->data;
    struct uart_port * port = &dev->port;
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    unsigned long flags;
    uint32_t control;

    spin_lock_irqsave(&port->lock, flags);
    control = regs->control;
    regs->control = control & ~CR_TX_STOP;
    uart_console_write(port, s, n, axi_uart_console_putchar);
    while ((regs->status & SR_TX_FIFO_EMPTY) == 0) {}
    regs->control = control;
    spin_unlock_irqrestore(&port->lock, flags);
}

static int __init axi_uart_early_setup(struct earlycon_device * device, const char * options) {
    if (device->port.membase == NULL) return -ENODEV;
    device->con->write = axi_uart_early_write;
    return 0;
}

OF_EARLYCON_DECLARE(axi_uart, "riscv,axi-uart-1.0", axi_uart_early_setup);
#endif

#ifdef CONFIG_CONSOLE_POLL
static int axi_uart_get_poll_char(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    while ((regs->status & SR_RX_FIFO_VALID) == 0) {}
    return regs->rx_fifo;
}

static void axi_uart_put_poll_char(struct uart_port *port, unsigned char ch) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    regs->control &= ~CR_TX_STOP;
    while ((regs->status & SR_TX_FIFO_EMPTY) != 0) {}
    regs->tx_fifo = ch & 0xff;
}
#endif

static struct uart_driver axi_uart_port_driver = {
    .owner = THIS_MODULE,
    .driver_name = DRIVER_NAME,
    .dev_name = DEVICE_NAME,
    .nr = MAX_PORTS,
#ifdef CONFIG_SERIAL_AXI_UART_CONSOLE
    .cons = &axi_uart_console,
#endif
};

static int axi_uart_transmit(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    struct circ_buf * xmit = &port->state->xmit;
    uint32_t control = regs->control;
    unsigned tx_cnt = 0;
    int ret = 0;

    regs->control = control &= ~CR_IE_TX_READY;
    while (tx_cnt < MAX_CHARS_PER_INTERRUPT) {
        if (port->x_char) {
            regs->tx_fifo = port->x_char | 0x100;
            port->icount.tx++;
            port->x_char = 0;
            ret = 1;
        }
        else if (uart_tx_stopped(port)) {
            regs->control = control |= CR_TX_STOP;
            break;
        }
        else if (!uart_circ_empty(xmit)) {
            regs->control = control &= ~CR_TX_STOP;
            if (regs->status & SR_TX_FIFO_FULL) {
                regs->control = control |= CR_IE_TX_READY;
                break;
            }
            regs->tx_fifo = xmit->buf[xmit->tail] & 0xff;
            xmit->tail = (xmit->tail + 1) & (UART_XMIT_SIZE - 1);
            port->icount.tx++;
            tx_cnt++;
            ret = 1;
        }
        else {
            regs->control = control &= ~CR_TX_STOP;
            break;
        }
    }
    if (tx_cnt && uart_circ_chars_pending(xmit) < WAKEUP_CHARS) uart_write_wakeup(port);
    return ret;
}

static int axi_uart_receive(struct uart_port * port) {
    struct tty_port * tport = &port->state->port;
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    unsigned rx_cnt = 0;

    while (rx_cnt < MAX_CHARS_PER_INTERRUPT && (regs->status & SR_RX_FIFO_VALID)) {
        tty_insert_flip_char(tport, regs->rx_fifo, TTY_NORMAL);
        port->icount.rx++;
        rx_cnt++;
    }
    if (rx_cnt) tty_flip_buffer_push(tport);

    return rx_cnt > 0;
}

static irqreturn_t axi_uart_isr(int irq, void * dev_id) {
    struct uart_port * port = dev_id;
    irqreturn_t ret = IRQ_NONE;

    spin_lock(&port->lock);
    if (axi_uart_transmit(port)) ret = IRQ_HANDLED;
    if (axi_uart_receive(port)) ret = IRQ_HANDLED;
    spin_unlock(&port->lock);

    return ret;
}

static unsigned int axi_uart_tx_empty(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    return (regs->status & SR_TX_FIFO_EMPTY) != 0;
}

static unsigned int axi_uart_get_mctrl(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    unsigned ret = TIOCM_DSR | TIOCM_CAR;
    if (regs->status & SR_CTS) ret |= TIOCM_CTS;
    return ret;
}

static void axi_uart_set_mctrl(struct uart_port * port, unsigned int mctrl) {
}

static void axi_uart_stop_tx(struct uart_port * port) {
    axi_uart_transmit(port);
}

static void axi_uart_start_tx(struct uart_port * port) {
    axi_uart_transmit(port);
}

static void axi_uart_stop_rx(struct uart_port * port) {
    /* Called before port shutdown */
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    regs->control &= ~CR_IE_RX_READY;
}

static void axi_uart_break_ctl(struct uart_port *port, int ctl) {
}

static int axi_uart_startup(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;
    int ret;

    ret = request_irq(port->irq, axi_uart_isr, IRQF_TRIGGER_HIGH, DRIVER_NAME, port);
    if (ret) return ret;

    regs->control = CR_IE_RX_READY;

    return 0;
}

static void axi_uart_shutdown(struct uart_port * port) {
    struct uart_regs __iomem * regs = (struct uart_regs __iomem *)port->membase;

    regs->control = 0;
    free_irq(port->irq, port);
}

#if LINUX_VERSION_CODE < KERNEL_VERSION(6,1,0)
static void axi_uart_set_termios(struct uart_port * port, struct ktermios * termios, struct ktermios * old) {
#else
static void axi_uart_set_termios(struct uart_port * port, struct ktermios * termios, const struct ktermios * old) {
#endif
}

static const char * axi_uart_type(struct uart_port * port) {
    return DRIVER_NAME;
}

static void axi_uart_release_port(struct uart_port * port) {
    release_mem_region(port->mapbase, sizeof(struct uart_regs));
    iounmap(port->membase);
    port->membase = NULL;
}

static int axi_uart_request_port(struct uart_port * port) {
    pr_debug(DRIVER_NAME " console: port=%p; port->mapbase=%llx\n", port, (unsigned long long)port->mapbase);

    if (!request_mem_region(port->mapbase, sizeof(struct uart_regs), DRIVER_NAME)) {
        dev_err(port->dev, "Memory region busy\n");
        return -EBUSY;
    }

    port->membase = ioremap(port->mapbase, sizeof(struct uart_regs));
    if (!port->membase) {
        dev_err(port->dev, "Unable to map registers\n");
        release_mem_region(port->mapbase, sizeof(struct uart_regs));
        return -EBUSY;
    }

    return 0;
}

static void axi_uart_config_port(struct uart_port * port, int flags) {
    port->type = PORT_AXI_UART;
}

static int axi_uart_verify_port(struct uart_port * port, struct serial_struct * ser) {
    return 0;
}

static void axi_uart_pm(struct uart_port * port, unsigned int state, unsigned int oldstate) {
}

static const struct uart_ops axi_uart_ops = {
    .tx_empty = axi_uart_tx_empty,
    .set_mctrl = axi_uart_set_mctrl,
    .get_mctrl = axi_uart_get_mctrl,
    .stop_tx = axi_uart_stop_tx,
    .start_tx = axi_uart_start_tx,
    .stop_rx = axi_uart_stop_rx,
    .break_ctl = axi_uart_break_ctl,
    .startup = axi_uart_startup,
    .shutdown = axi_uart_shutdown,
    .set_termios = axi_uart_set_termios,
    .type = axi_uart_type,
    .release_port = axi_uart_release_port,
    .request_port = axi_uart_request_port,
    .config_port = axi_uart_config_port,
    .verify_port = axi_uart_verify_port,
    .pm = axi_uart_pm,
#ifdef CONFIG_CONSOLE_POLL
    .poll_get_char = axi_uart_get_poll_char,
    .poll_put_char = axi_uart_put_poll_char,
#endif
};

static int axi_uart_assign(struct device * dev, int id, u32 mapbase, void __iomem * membase, int irq) {
    struct uart_port * port;
    int rc;

    /* if id = -1; then scan for a free id and use that */
    if (id < 0) {
        for (id = 0; id < MAX_PORTS; id++) {
            if (axi_uart_ports[id].membase == NULL) break;
        }
    }
    if (id < 0 || id >= MAX_PORTS) {
        dev_err(dev, "%s%i too large\n", DEVICE_NAME, id);
        return -EINVAL;
    }

    port = &axi_uart_ports[id];

    if (port->mapbase && port->mapbase != mapbase) {
        dev_err(dev, "cannot assign to %s%i; it is already in use\n", DEVICE_NAME, id);
        return -EBUSY;
    }

    spin_lock_init(&port->lock);
    port->fifosize = 0; /* disable timeout in uart_wait_until_sent() */
#if LINUX_VERSION_CODE < KERNEL_VERSION(6,0,0)
    port->timeout = HZ / 50; /* must not be 0 to avoid interger overflow in uart_wait_until_sent() */
#endif
    port->regshift = 2; /* 2 means 32-bit registers */
    port->iotype = UPIO_MEM;
    port->iobase = 1; /* mark port in use */
    port->mapbase = mapbase;
    port->membase = membase;
    port->ops = &axi_uart_ops;
    port->irq = irq;
    port->flags = UPF_BOOT_AUTOCONF;
    port->dev = dev;
    port->line = id;

    dev_set_drvdata(dev, port);

    /* Register the port */
    rc = uart_add_one_port(&axi_uart_port_driver, port);
    if (rc) {
        dev_err(dev, DRIVER_NAME ": add port failed; err=%i\n", rc);
        port->mapbase = 0;
        dev_set_drvdata(dev, NULL);
        return rc;
    }

    return 0;
}

static int axi_uart_release(struct device * dev) {
    struct uart_port * port = dev_get_drvdata(dev);
    int rc = 0;

    if (port) {
        rc = uart_remove_one_port(&axi_uart_port_driver, port);
        dev_set_drvdata(dev, NULL);
        port->mapbase = 0;
    }

    return rc;
}

static int axi_uart_probe(struct platform_device * pdev) {
    struct resource * iomem;
    void __iomem * ioaddr;
    int irq, ret;
    int id = pdev->id;

#ifdef CONFIG_OF
    const __be32 * prop = of_get_property(pdev->dev.of_node, "port-number", NULL);
    if (prop) id = be32_to_cpup(prop);
#endif

    iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    ioaddr = devm_ioremap_resource(&pdev->dev, iomem);
    if (IS_ERR(ioaddr)) return PTR_ERR(ioaddr);

    irq = platform_get_irq(pdev, 0);
    if (irq <= 0) return -ENXIO;

    if (!axi_uart_port_driver.state) {
        ret = uart_register_driver(&axi_uart_port_driver);
        if (ret < 0) {
            dev_err(&pdev->dev, DRIVER_NAME ": Failed to register UART driver\n");
            return ret;
        }
    }

    ret = axi_uart_assign(&pdev->dev, id, iomem->start, ioaddr, irq);

    return ret;
}

static int axi_uart_remove(struct platform_device * pdev) {
    return axi_uart_release(&pdev->dev);
}

static int __maybe_unused axi_uart_suspend(struct device * dev) {
    return 0;
}

static int __maybe_unused axi_uart_resume(struct device * dev) {
    return 0;
}

static SIMPLE_DEV_PM_OPS(axi_uart_pm_ops, axi_uart_suspend, axi_uart_resume);

#ifdef CONFIG_OF
/* Match table for of_platform binding */
static const struct of_device_id axi_uart_of_match[] = {
    { .compatible = "riscv,axi-uart-1.0" },
{}
};
MODULE_DEVICE_TABLE(of, axi_uart_of_match);
#endif /* CONFIG_OF */

MODULE_ALIAS("platform:" DRIVER_NAME);

static struct platform_driver axi_uart_platform_driver = {
    .probe = axi_uart_probe,
    .remove = axi_uart_remove,
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .pm = &axi_uart_pm_ops,
#ifdef CONFIG_OF
        .of_match_table = of_match_ptr(axi_uart_of_match),
#endif
    },
};

static int __init axi_uart_init(void) {
    return platform_driver_register(&axi_uart_platform_driver);
}

static void __exit axi_uart_exit(void) {
    platform_driver_unregister(&axi_uart_platform_driver);
    if (axi_uart_port_driver.state) {
        uart_unregister_driver(&axi_uart_port_driver);
    }
}

module_init(axi_uart_init);
module_exit(axi_uart_exit);

MODULE_DESCRIPTION("FPGA AXI UART serial driver");
MODULE_AUTHOR("Eugene Tarassov");
MODULE_LICENSE("GPL");
