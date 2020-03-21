#include "common.h"

.section .text.start, "ax", @progbits
.globl _start
_start:
  la s0, _ram
  csrr a0, mhartid
  la a1, _dtb
  jr s0
_hart0_entry:
  li sp, BOOTROM_MEM_END
  call main
  j _hang

.section .text.hang, "ax", @progbits
.globl _hang
_hang:
  csrr a0, mhartid
  la a1, _dtb
  li s2, 0
  beq a0, s2, _hart0_entry
_hartx_loop:
  # write mtvec
  la t0, _ram
  csrw mtvec, t0
  # enable software interrupt
  csrwi mie, 0x8
  wfi
  # check for valid trap vector
  lw t1, 0(t0)
  beqz t1, _hartx_loop
  # jump to code in RAM
  ecall
  j _hartx_loop

.section .rodata.dtb, "a", @progbits
.globl _dtb
.align 5, 0
_dtb:
  .incbin DEVICE_TREE
