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
xsdb% stop
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
Alternatively, you can call the script `../scripts/debugger_download_load_program.sh`

## "Coremark" and "Dhrystone" CPU benchmarking programs

These compile same way as "Hello World" program but from within `bare-metal/coremark` or `bare-metal/dhrystone` .

These also run on any 64-bit or 32-bit Rocket flavor.

There are two parameters you can adjust per program.

For both programs, within `bare-metal/common.mk` :

`FPGA_CPU_CLK_FREQ`: defaults to 100MHz, but set this to whatever frequency you're clocking your CPU .

And then program-specfic iterations. First for Coremark, within `bare-metal/coremark/Makefile`:

`ITERATIONS`: 5000 by default, which should be sufficient for all permutations of RocketConfig + Board + ClkFreq.

Coremark requires runtime > 10 secs, so increase ITERATIONS if your CPU is somehow too fast.

Secondly, for Dhrystone, within `bare-metal/dhrystone/Makefile`:

`DHRY_ITERS`: 3000000 by default, which should be sufficient for all permutations of RocketConfig + Board + ClkFreq.

Best not to decrease this too much, as Dhrystone won't print a result if it deems the runtime wasn't long enough.
