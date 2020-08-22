// See LICENSE for license details.

#include <string.h>
#include "uart.h"
#include "fdt.h"

#define SR_RX_FIFO_VALID_DATA   (1 << 0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1 << 1) /* receive FIFO full */
#define SR_TX_FIFO_EMPTY        (1 << 2) /* transmit FIFO empty */
#define SR_TX_FIFO_FULL         (1 << 3) /* transmit FIFO full */

struct uart_regs {
    volatile uint32_t rx_fifo;
    volatile uint32_t tx_fifo;
    volatile uint32_t status;
    volatile uint32_t control;
};

volatile uint32_t * uart;
static struct uart_regs * regs = NULL;

void uart_putchar(uint8_t ch) {
    if (regs == NULL) return;
    while (regs->status & SR_TX_FIFO_FULL) {}
    regs->tx_fifo = ch & 0xff;
}

int uart_getchar(void) {
    if (regs == NULL) return -1;
    if (regs->status & SR_RX_FIFO_VALID_DATA) return regs->rx_fifo;
    return -1;
}

struct uart_scan {
    int compat;
    uint64_t reg;
};

static void uart_open(const struct fdt_scan_node *node, void *extra) {
    struct uart_scan *scan = (struct uart_scan *)extra;
    memset(scan, 0, sizeof(*scan));
}

static void uart_prop(const struct fdt_scan_prop *prop, void *extra) {
    struct uart_scan *scan = (struct uart_scan *)extra;
    if (!strcmp(prop->name, "compatible") && !strcmp((const char*)prop->value, "xlnx,xps-uartlite-1.00.a")) {
        scan->compat = 1;
    }
    else if (!strcmp(prop->name, "reg")) {
        fdt_get_address(prop->node->parent, prop->value, &scan->reg);
    }
}

static void uart_done(const struct fdt_scan_node *node, void *extra) {
    struct uart_scan *scan = (struct uart_scan *)extra;
    if (!scan->compat || !scan->reg || uart) return;
    uart = (void *)(uintptr_t)scan->reg;
    regs = (struct uart_regs *)uart;
}

void query_uart(uintptr_t fdt) {
    struct fdt_cb cb;
    struct uart_scan scan;

    memset(&cb, 0, sizeof(cb));
    cb.open = uart_open;
    cb.prop = uart_prop;
    cb.done = uart_done;
    cb.extra = &scan;

    fdt_scan(fdt, &cb);
}
