#ifndef _SDBOOT_KPRINTF_H
#define _SDBOOT_KPRINTF_H

#include <stdint.h>

#define SR_TX_FIFO_FULL         (1 << 3) /* transmit FIFO full */
#define SR_TX_FIFO_EMPTY        (1 << 2) /* transmit FIFO empty */
#define SR_RX_FIFO_VALID_DATA   (1 << 0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1 << 1) /* receive FIFO full */

#define ULITE_CONTROL_RST_TX    0x01
#define ULITE_CONTROL_RST_RX    0x02

struct uartlite {
    volatile uint32_t rx_fifo;
    volatile uint32_t tx_fifo;
    volatile uint32_t status;
    volatile uint32_t control;
};

static inline void kputc(char ch) {
    struct uartlite * regs = (struct uartlite *)0x60010000;
    while (regs->status & SR_TX_FIFO_FULL) {}
    regs->tx_fifo = ch & 0xff;
}

extern void kputs(const char *);
extern void kprintf(const char *, ...);

#ifdef DEBUG
#define dprintf(s, ...) kprintf((s), ##__VA_ARGS__)
#define dputs(s)    kputs((s))
#else
#define dprintf(s, ...) do { } while (0)
#define dputs(s)    do { } while (0)
#endif

#endif /* _SDBOOT_KPRINTF_H */
