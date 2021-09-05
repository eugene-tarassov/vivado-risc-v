/* SPDX-License-Identifier: BSD-2-Clause */
/* Copyright (C) 2021 Eugene Tarassov */

#include <libfdt.h>
#include <sbi/riscv_asm.h>
#include <sbi/riscv_encoding.h>
#include <sbi/riscv_io.h>
#include <sbi/sbi_console.h>
#include <sbi/sbi_const.h>
#include <sbi/sbi_hart.h>
#include <sbi/sbi_platform.h>
#include <sbi_utils/fdt/fdt_domain.h>
#include <sbi_utils/fdt/fdt_fixup.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <sbi_utils/irqchip/fdt_irqchip.h>
#include <sbi_utils/serial/fdt_serial.h>
#include <sbi_utils/timer/fdt_timer.h>
#include <sbi_utils/ipi/fdt_ipi.h>

/* Linux kernel can support up to 32 HARTs */
#define MAX_HART_CNT 32

#define SR_RX_FIFO_VALID_DATA   (1 << 0) /* data in receive FIFO */
#define SR_RX_FIFO_FULL         (1 << 1) /* receive FIFO full    */
#define SR_TX_FIFO_EMPTY        (1 << 2) /* transmit FIFO empty  */
#define SR_TX_FIFO_FULL         (1 << 3) /* transmit FIFO full   */

struct axi_uart_regs {
    volatile uint32_t rx_fifo;
    volatile uint32_t tx_fifo;
    volatile uint32_t status;
    volatile uint32_t control;
};

static struct axi_uart_regs * regs = NULL;

void uart_putc(char ch) {
    if (regs == NULL) return;
    while (regs->status & SR_TX_FIFO_FULL) {}
    regs->tx_fifo = ch & 0xff;
}

int uart_getc(void) {
    if (regs == NULL) return -1;
    if (regs->status & SR_RX_FIFO_VALID_DATA) return regs->rx_fifo;
    return -1;
}

/* ---- Console ---- */

static struct sbi_console_device console_ops = {
    .name = "axi-uart",
    .console_putc = uart_putc,
    .console_getc = uart_getc
};

static const struct fdt_match console_match[] = {
    { .compatible = "xlnx,xps-uartlite-1.00.a" },
    { .compatible = "xlnx,opb-uartlite-1.00.b" },
    { .compatible = "riscv,axi-uart-1.0" },
    {},
};

static int console_init(void) {
    void * fdt = sbi_scratch_thishart_arg1_ptr();
    int coff = fdt_path_offset(fdt, "/chosen");
    if (coff >= 0) {
        int len = 0;
        const void * prop = fdt_getprop(fdt, coff, "stdout-path", &len);
        if (prop != NULL && len > 0) {
            int noff = fdt_path_offset(fdt, prop);
            if (noff >= 0 && fdt_match_node(fdt, noff, console_match) != NULL) {
                unsigned long reg_addr = 0, reg_size = 0;
                if (fdt_get_node_addr_size(fdt, noff, 0, &reg_addr, &reg_size) >= 0 && reg_addr != 0) {
                    regs = (struct axi_uart_regs *)reg_addr;
                    sbi_console_set_device(&console_ops);
                    return 0;
                }
            }
        }
    }

    return fdt_serial_init();
}

/* ---- Platform ---- */

const struct sbi_platform_operations platform_ops = {
    .console_init = console_init,
    .irqchip_init = fdt_irqchip_init,
    .irqchip_exit = fdt_irqchip_exit,
    .ipi_init = fdt_ipi_init,
    .ipi_exit = fdt_ipi_exit,
    .timer_init = fdt_timer_init,
    .timer_exit = fdt_timer_exit,
};

const struct sbi_platform platform = {
    .opensbi_version = OPENSBI_VERSION,
    .platform_version = SBI_PLATFORM_VERSION(0x0, 0x01),
    .name = "Vivado RISC-V",
    .features = SBI_PLATFORM_DEFAULT_FEATURES,
    .hart_count = MAX_HART_CNT,
    .hart_stack_size = SBI_PLATFORM_DEFAULT_HART_STACK_SIZE,
    .platform_ops_addr = (unsigned long)&platform_ops
};
