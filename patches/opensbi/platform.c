/* SPDX-License-Identifier: BSD-2-Clause */
/* Copyright (C) 2021-2023 Eugene Tarassov */

#include <libfdt.h>
#include <sbi/riscv_asm.h>
#include <sbi/riscv_encoding.h>
#include <sbi/riscv_io.h>
#include <sbi/sbi_console.h>
#include <sbi/sbi_heap.h>
#include <sbi/sbi_const.h>
#include <sbi/sbi_hart.h>
#include <sbi/sbi_platform.h>
#include <sbi/sbi_string.h>
#include <sbi/sbi_system.h>
#include <sbi/sbi_tlb.h>
#include <sbi_utils/fdt/fdt_domain.h>
#include <sbi_utils/fdt/fdt_driver.h>
#include <sbi_utils/fdt/fdt_fixup.h>
#include <sbi_utils/fdt/fdt_helper.h>
#include <sbi_utils/fdt/fdt_pmu.h>
#include <sbi_utils/ipi/fdt_ipi.h>
#include <sbi_utils/irqchip/fdt_irqchip.h>
#include <sbi_utils/irqchip/imsic.h>
#include <sbi_utils/mpxy/fdt_mpxy.h>
#include <sbi_utils/serial/fdt_serial.h>
#include <sbi_utils/timer/fdt_timer.h>

#define SR_RX_FIFO_VALID        (1 << 0) /* data in receive FIFO */
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
    if (regs->status & SR_RX_FIFO_VALID) return regs->rx_fifo;
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

static int match_node(const void * fdt, int off, const struct fdt_match * match) {
    unsigned i;
    for (i = 0; match[i].compatible != NULL; i++) {
        if (fdt_node_check_compatible(fdt, off, match[i].compatible) == 0) return 1;
    }
    return 0;
}

static int console_init(const void * fdt) {
    int coff = fdt_path_offset(fdt, "/chosen");
    if (coff >= 0) {
        int len = 0;
        const void * prop = fdt_getprop(fdt, coff, "stdout-path", &len);
        if (prop != NULL && len > 0) {
            int noff = fdt_path_offset(fdt, prop);
            if (noff >= 0 && match_node(fdt, noff, console_match)) {
                unsigned long reg_addr = 0, reg_size = 0;
                if (fdt_get_node_addr_size(fdt, noff, 0, &reg_addr, &reg_size) >= 0 && reg_addr != 0) {
                    regs = (struct axi_uart_regs *)reg_addr;
                    sbi_console_set_device(&console_ops);
                    return 0;
                }
            }
        }
    }

    /* chosen/stdout-path is not a compatible device */
    return fdt_serial_init(fdt);
}

/* ---- Platform ---- */

/* List of platform override modules generated at compile time */
extern const struct fdt_driver * const platform_override_modules[];

static u32 fw_platform_calculate_heap_size(u32 hart_count) {
    u32 heap_size;

    heap_size = SBI_PLATFORM_DEFAULT_HEAP_SIZE(hart_count);

    /* For TLB fifo */
    heap_size += SBI_TLB_INFO_SIZE * (hart_count) * (hart_count);

    return BIT_ALIGN(heap_size, HEAP_BASE_ALIGN);
}

static u32 fw_platform_get_heap_size(const void * fdt, u32 hart_count) {
    int chosen_offset, config_offset, len;
    const fdt32_t * val;

    /* Get the heap size from device tree */
    chosen_offset = fdt_path_offset(fdt, "/chosen");
    if (chosen_offset < 0)
        goto default_config;

    config_offset = fdt_node_offset_by_compatible(fdt, chosen_offset, "opensbi,config");
    if (config_offset < 0)
        goto default_config;

    val = (fdt32_t *)fdt_getprop(fdt, config_offset, "heap-size", &len);
    if (len > 0 && val)
        return BIT_ALIGN(fdt32_to_cpu(*val), HEAP_BASE_ALIGN);

default_config:
    return fw_platform_calculate_heap_size(hart_count);
}

extern struct sbi_platform platform;
static bool platform_has_mlevel_imsic = false;
static u32 generic_hart_index2id[SBI_HARTMASK_MAX_BITS] = { 0 };

/*
 * The fw_platform_init() function is called very early on the boot HART
 * OpenSBI reference firmwares so that platform specific code get chance
 * to update "platform" instance before it is used.
 *
 * The arguments passed to fw_platform_init() function are boot time state
 * of A0 to A4 register. The "arg0" will be boot HART id and "arg1" will
 * be address of FDT passed by previous booting stage.
 *
 * The return value of fw_platform_init() function is the FDT location. If
 * FDT is unchanged (or FDT is modified in-place) then fw_platform_init()
 * can always return the original FDT location (i.e. 'arg1') unmodified.
 */
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
            unsigned long cbom_block_size = 0;
            unsigned long tmp = 0;
            fdt_for_each_subnode(cpu_offset, fdt, cpus_offset) {
                if (fdt_parse_hart_id(fdt, cpu_offset, &hartid)) continue;
                if (SBI_HARTMASK_MAX_BITS <= hartid) continue;
                if (!fdt_node_is_enabled(fdt, cpu_offset)) continue;
                generic_hart_index2id[hart_count++] = hartid;
                if (fdt_parse_cbom_block_size(fdt, cpu_offset, &tmp)) continue;
                cbom_block_size = MAX(tmp, cbom_block_size);
            }
            platform.hart_count = hart_count;
            platform.heap_size = fw_platform_get_heap_size(fdt, hart_count);
            platform_has_mlevel_imsic = fdt_check_imsic_mlevel(fdt);
            platform.cbom_block_size = cbom_block_size;
        }
    }

    /* Return original FDT pointer */
    return arg1;
}

static int nascent_init(void) {
    if (platform_has_mlevel_imsic)
        imsic_local_irqchip_init();
    return 0;
}

static int early_init(bool cold_boot) {
    const void * fdt = fdt_get_address();

    if (console_init(fdt) < 0) return -1;
    fdt_driver_init_all(fdt, fdt_early_drivers);
    return 0;
}

static int final_init(bool cold_boot) {
#if 0
    void * fdt = fdt_get_address_rw();

    fdt_cpu_fixup(fdt);
    fdt_fixups(fdt);
    fdt_domain_fixup(fdt);
#endif
    return 0;
}

static int extensions_init(struct sbi_hart_features * hfeatures) {
    /* Parse the ISA string from FDT and enable the listed extensions */
    return fdt_parse_isa_extensions(fdt_get_address(), current_hartid(),
        hfeatures->extensions);
}

static int domains_init(void) {
    const void * fdt = fdt_get_address();
    int offset, ret;

    ret = fdt_domains_populate(fdt);
    if (ret < 0)
        return ret;

    offset = fdt_path_offset(fdt, "/chosen");

    if (offset >= 0) {
        offset = fdt_node_offset_by_compatible(fdt, offset, "opensbi,config");
        if (offset >= 0 &&
            fdt_get_property(fdt, offset, "system-suspend-test", NULL))
            sbi_system_suspend_test_enable();
    }

    return 0;
}

static u64 tlbr_flush_limit(void) {
    return SBI_PLATFORM_TLB_RANGE_FLUSH_LIMIT_DEFAULT;
}

static u32 tlb_num_entries(void) {
    return sbi_hart_count();
}

static int pmu_init(void) {
    int rc;

    rc = fdt_pmu_setup(fdt_get_address());
    if (rc && rc != SBI_ENOENT)
        return rc;

    return 0;
}

static uint64_t pmu_xlate_to_mhpmevent(uint32_t event_idx, uint64_t data) {
    uint64_t evt_val = 0;

    /* data is valid only for raw events and is equal to event selector */
    if (event_idx == SBI_PMU_EVENT_RAW_IDX ||
        event_idx == SBI_PMU_EVENT_RAW_V2_IDX)
        evt_val = data;
    else {
        /**
         * Generic platform follows the SBI specification recommendation
         * i.e. zero extended event_idx is used as mhpmevent value for
         * hardware general/cache events if platform does't define one.
         */
        evt_val = fdt_pmu_get_select_value(event_idx);
        if (!evt_val)
            evt_val = (uint64_t)event_idx;
    }

    return evt_val;
}

static int mpxy_init(void) {
    const void * fdt = fdt_get_address();

    return fdt_mpxy_init(fdt);
}

const struct sbi_platform_operations platform_ops = {
    .nascent_init = nascent_init,
    .early_init = early_init,
    .final_init = final_init,
    .extensions_init = extensions_init,
    .domains_init = domains_init,
    .irqchip_init = fdt_irqchip_init,
    .ipi_init = fdt_ipi_init,
    .pmu_init = pmu_init,
    .pmu_xlate_to_mhpmevent = pmu_xlate_to_mhpmevent,
    .get_tlbr_flush_limit = tlbr_flush_limit,
    .get_tlb_num_entries = tlb_num_entries,
    .timer_init = fdt_timer_init,
    .mpxy_init = mpxy_init,
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
