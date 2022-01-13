#include "common.h"

.section .text.start, "ax", @progbits
.globl _start
_start:
  li sp, BOOT_MEM_END
  call main
_hang:
  wfi
  j _hang
