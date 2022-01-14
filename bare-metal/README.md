# Examples of simple RISC-V bare-metal programs

The bootrom loads and executes boot.elf file from SD card DOS partition.
boot.elf is regular executable ELF, it can contain any software suitable for RISC-V RV64 M mode.

## "Hello World" program

Runs on any RISC-V 64-bit configuration.
Outputs "Hello World!" message using UART.

Usage:
```
cd bare-metal/hello-world
make clean all
```
Copy boot.elf to the SD card.