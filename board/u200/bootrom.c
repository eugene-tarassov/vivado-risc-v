#include <stdint.h>
#include <stdlib.h>

#include "common.h"
#include "kprintf.h"

// Does nothing, waits for JTAG debugger.

extern unsigned char _fbss[];
extern unsigned char _ebss[];

int main(void) {
    uint64_t * bss = (uint64_t *)_fbss;
    while (bss < (uint64_t *)_ebss) *bss++ = 0;

    kprintf("\nRISC-V %d, Boot ROM: JTAG\n", __riscv_xlen);
    while (1) {
        asm volatile ("wfi");
    }

    return 0;
}
