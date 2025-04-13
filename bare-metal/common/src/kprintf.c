#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#include "kprintf.h"

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

void kputc(char ch) {
    struct uart_regs * regs = (struct uart_regs *)0x60010000;
    while (regs->status & SR_TX_FIFO_FULL) {}
    regs->tx_fifo = ch & 0xff;
}

void kputs(const char * s) {
    while (*s) kputc(*s++);
    kputc('\r');
    kputc('\n');
}

void kprintf(const char * fmt, ...) {
    va_list vl;
    int is_format = 0;
    int is_long = 0;
    int is_char = 0;
    char c;

    va_start(vl, fmt);
    while ((c = *fmt++) != '\0') {
        if (is_format) {
            switch (c) {
            case 'l':
                is_long = 1;
                continue;
            case 'h':
                is_char = 1;
                continue;
            case 'x': {
                unsigned long n;
                long i;
                if (is_long) {
                    n = va_arg(vl, unsigned long);
                    i = (sizeof(unsigned long) << 3) - 4;
                }
                else {
                    n = va_arg(vl, unsigned int);
                    i = is_char ? 4 : (sizeof(unsigned int) << 3) - 4;
                }
                for (; i >= 0; i -= 4) {
                    long d;
                    d = (n >> i) & 0xF;
                    kputc(d < 10 ? '0' + d : 'a' + d - 10);
                }
                break;
            }
            case 'd': {
                char buf[32];
                long n;
                long i = sizeof(buf);
                if (is_long) {
                    n = va_arg(vl, long);
                }
                else {
                    n = va_arg(vl, int);
                }
                if (n < 0) {
                    kputc('-');
                    n = -n;
                }
                while (i > 0) {
                    buf[--i] = n % 10 + '0';
                    n = n / 10;
                    if (n == 0) break;
                }
                while (i < sizeof(buf)) kputc(buf[i++]);
                break;
            }
            case 'u': {
                char buf[32];
                unsigned long n;
                long i = sizeof(buf);
                if (is_long) {
                    n = va_arg(vl, unsigned long);
                }
                else {
                    n = va_arg(vl, unsigned int);
                }
                while (i > 0) {
                    buf[--i] = n % 10 + '0';
                    n = n / 10;
                    if (n == 0) break;
                }
                while (i < sizeof(buf)) kputc(buf[i++]);
                break;
            }
            case 'f': {
                double f = va_arg(vl, double);
                if (f < 0) {
                    kputc('-');
                    f = -f;
                }
                long whole = (long)f;
                long frac = (long)((f - whole) * 1000000);
                // Print whole part
                char buf[32];
                int i = sizeof(buf);
                if (whole == 0) {
                    kputc('0');
                } else {
                    while (whole > 0 && i > 0) {
                        buf[--i] = '0' + (whole % 10);
                        whole /= 10;
                    }
                    while (i < sizeof(buf)) kputc(buf[i++]);
                }
                kputc('.');
                // Print fractional part with leading zeros
                int zeros = 6;
                long temp = frac;
                while (temp > 0 && zeros > 0) {
                    temp /= 10;
                    zeros--;
                }
                while (zeros-- > 0) kputc('0');
                i = sizeof(buf);
                if (frac == 0) {
                    kputc('0');
                } else {
                    while (frac > 0 && i > 0) {
                        buf[--i] = '0' + (frac % 10);
                        frac /= 10;
                    }
                    while (i < sizeof(buf)) kputc(buf[i++]);
                }
                break;
            }
            case 's': {
                const char * s = va_arg(vl, const char *);
                while (*s) kputc(*s++);
                break;
            }
            case 'c':
                kputc(va_arg(vl, int));
                break;
            }
            is_format = 0;
            is_long = 0;
            is_char = 0;
        }
        else if (c == '%') {
            is_format = 1;
        }
        else if (c == '\n') {
            kputc('\r');
            kputc('\n');
        }
        else {
            kputc(c);
        }
    }
    va_end(vl);
}
