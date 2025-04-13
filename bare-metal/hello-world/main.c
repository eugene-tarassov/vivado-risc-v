#include <stdint.h>
#include <stdlib.h>

#include "common.h"
#include "kprintf.h"
#include "timer.h"

int main(void) {
    kprintf("\n");
    for (;;) {
        kprintf("Hello World!\n");
        usleep(1000000);
    }
    return 0;
}
