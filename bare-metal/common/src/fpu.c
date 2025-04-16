#include <fpu.h>
#include <stdint.h>

// necessary for enabling the FPU in baremetal
void enable_fpu() {
    uint64_t mstatus;
    asm volatile ("csrr %0, mstatus" : "=r"(mstatus));
    mstatus |= (1 << 13); // FS = 01 (Initial)
    asm volatile ("csrw mstatus, %0" :: "r"(mstatus));
}

