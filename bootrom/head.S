#include "common.h"

#define MIP_MSIP (1 << 3)

.section .text.start, "ax", @progbits
.globl _start
_start:
  csrr a0, mhartid
  la a1, _dtb
  la s0, _ram
  jr s0
_start_bootrom:
  # a0 - hart ID
  # a1 - Device Tree
  # s0 - start of RAM and trap vector
  sw s2, 0(s0) # clear trap vector
  li sp, BOOTROM_MEM_END
  call main
  j _hang

.section .text.hang, "ax", @progbits
.globl _hang
_hang:
  csrr a0, mhartid
  la a1, _dtb
  la s0, _ram
  beqz a0, _start_bootrom
_hartx_loop:
  # write mtvec
  csrw mtvec, s0
  # enable software interrupt
  csrwi mie, MIP_MSIP
  wfi
  # only start if interrupt request is set
  csrr a2, mip
  andi a2, a2, MIP_MSIP
  beqz a2, _hartx_loop
  # jump to code in RAM
  ecall
  j _hartx_loop

.section .rodata.dtb, "a", @progbits
.globl _dtb
.align 5, 0
_dtb:
  .incbin DEVICE_TREE
