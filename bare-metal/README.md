# Examples of simple RISC-V bare-metal programs

The bootrom loads and executes boot.elf file from SD card DOS partition.
boot.elf is regular executable ELF, it can contain any software suitable for RISC-V M mode.

## "Hello World" program

Runs on any RISC-V 64-bit or 32-bit configuration.
Outputs "Hello World!" message using UART.

64-bit RISC-V:
```
cd bare-metal/hello-world
make clean all
```

32-bit RISC-V, use 32-bit compiler:
```
cd bare-metal/hello-world
make CROSS_COMPILE=../../workspace/gcc/riscv/bin/riscv32-unknown-elf- CFLAGS='-march=rv32imac -mabi=ilp32' clean all
```

Copy boot.elf to the SD card, insert the card into SD slot on the board, press reset button.

## Using debugger to download and run the program

boot.elf can be downloaded directly into RISC-V memory and started using Xilinx debugger - xsdb:

```
xsdb% connect
tcfchan#0
xsdb% targets -set -filter {name =~ "Hart #0*"}
xsdb% dow -clear boot.elf
Downloading Program -- boot.elf
        section, .text: 0x80000000 - 0x8000b05f
        section, .data: 0x8000b060 - 0x8000b06f
        section, .bss: 0x8000b070 - 0x8000ffbf
100%    0MB   0.4MB/s  00:00
Setting PC to Program Start Address 0x80000008
Successfully downloaded boot.elf
xsdb% con
Info: Hart #0 (target 3) Running
xsdb%
```
