#ifndef FPU_H
#define FPU_H

// necessary for enabling the FPU in baremetal
static inline void enable_fpu() {
    uint64_t mstatus;
    asm volatile ("csrr %0, mstatus" : "=r"(mstatus));
    mstatus |= (1 << 13); // FS = 01 (Initial)
    asm volatile ("csrw mstatus, %0" :: "r"(mstatus));
}

#endif
