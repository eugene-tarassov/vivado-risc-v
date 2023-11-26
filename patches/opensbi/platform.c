/* SPDX-License-Identifier: BSD-2-Clause */
/* Copyright (C) 2021-2023 Eugene Tarassov */

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

static u32 generic_hart_index2id[SBI_HARTMASK_MAX_BITS] = { 0 };

const struct sbi_platform_operations platform_ops = {
    .console_init = console_init,
    .irqchip_init = fdt_irqchip_init,
    .irqchip_exit = fdt_irqchip_exit,
    .ipi_init = fdt_ipi_init,
    .ipi_exit = fdt_ipi_exit,
    .timer_init = fdt_timer_init,
    .timer_exit = fdt_timer_exit,
};

struct sbi_platform platform = {
    .opensbi_version = OPENSBI_VERSION,
    .platform_version = SBI_PLATFORM_VERSION(0x0, 0x01),
    .name = "Vivado RISC-V",
    .features = SBI_PLATFORM_DEFAULT_FEATURES,
    .hart_count = SBI_HARTMASK_MAX_BITS,
    .hart_index2id = generic_hart_index2id,
    .hart_stack_size = SBI_PLATFORM_DEFAULT_HART_STACK_SIZE,
    .heap_size = SBI_PLATFORM_DEFAULT_HEAP_SIZE(0),
    .platform_ops_addr = (unsigned long)&platform_ops
};

unsigned long fw_platform_init(unsigned long arg0, unsigned long arg1,
    unsigned long arg2, unsigned long arg3, unsigned long arg4) {
    void * fdt = (void *)arg1;

    int root_offset = fdt_path_offset(fdt, "/");
    if (root_offset >= 0) {
        int len = 0;
        const char * model = fdt_getprop(fdt, root_offset, "model", &len);
        if (model) sbi_strncpy(platform.name, model, sizeof(platform.name) - 1);

        int cpu_offset = 0;
        int cpus_offset = fdt_path_offset(fdt, "/cpus");
        if (cpus_offset >= 0) {
            uint32_t hartid = 0;
            uint32_t hart_count = 0;
            fdt_for_each_subnode(cpu_offset, fdt, cpus_offset) {
                if (fdt_parse_hart_id(fdt, cpu_offset, &hartid)) continue;
                if (SBI_HARTMASK_MAX_BITS <= hartid) continue;
                if (!fdt_node_is_enabled(fdt, cpu_offset)) continue;
                generic_hart_index2id[hart_count++] = hartid;
            }
            platform.hart_count = hart_count;
            platform.heap_size = SBI_PLATFORM_DEFAULT_HEAP_SIZE(hart_count);
        }
    }

    /* Return original FDT pointer */
    return arg1;
}
