OUTPUT_ARCH("riscv")
ENTRY(_hang)

MEMORY {
  error_mem (rw)   : ORIGIN = 0x00003000, LENGTH = 0x00001000
  maskrom_mem (rx) : ORIGIN = 0x00010000, LENGTH = 0x00010000
  memory_mem (rwx) : ORIGIN = 0x80000000, LENGTH = 0x00002000
}

PHDRS {
  text PT_LOAD;
}

SECTIONS {
  PROVIDE(_ram = ORIGIN(memory_mem));

  .text 0x00010000 : {
    *(.text.start)
    . = 0x0040;
    *(.text.hang)
    . = 0x0080;
    *(.rodata.dtb)
    *(.text.unlikely .text.unlikely.*)
    *(.text .text.* .gnu.linkonce.t.*)
    *(.rodata .rodata.* .gnu.linkonce.r.*)
    *(.srodata .srodata.*)
  } >maskrom_mem  :text
  ASSERT(SIZEOF(.text) <= 0x10000, "BootROM .text section must be less than 0x10000 bytes")

  .data (INFO) : {
    /* This section must be empty */
    *(.data .data.* .gnu.linkonce.d.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    *(.tohost)
  }
  ASSERT(SIZEOF(.data) == 0, "BootROM .data section must be empty")

  .bss 0x80000000 (NOLOAD) : {
    . += 8; /* Trap vector */
    PROVIDE(_fbss = .);
    PROVIDE(__global_pointer$ = . + 0x7C0);
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.bss .bss.* .gnu.linkonce.b.*)
    . = ALIGN(8);
    PROVIDE(_ebss = .);
  } >memory_mem
  ASSERT(SIZEOF(.bss) <= 0x1000, "BootROM .bss section must be less than 0x1000 bytes")

  .note (INFO) : {
    *(.note .note.*)
    *(.eh_frame)
  }
}
