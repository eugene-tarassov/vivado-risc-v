#include <time.h>
#include <timer.h>
#include <stdint.h>

extern uint32_t read_mcycle();

clock_t clock() {
    uint32_t cycles = read_mcycle();
    clock_t mics = cycles / FPGA_CPU_CLK_FREQ;
    return mics;
}
