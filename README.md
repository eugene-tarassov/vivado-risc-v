# vivado-risc-v

# Xilinx Vivado block designs for FPGA RISC-V SoC running Debian Linux distro.

This repository contains FPGA prototype of fully functional [RISC-V](https://riscv.org/) Linux server
with networking, online Linux package repository and daily package updates.
It includes scripts and sources to generate RISC-V SoC HDL, Xilinx Vivado project, FPGA bitstream, and bootable SD card.
The SD card contains [Berkeley Boot Loader (aka RISC-V Proxy Kernel)](https://github.com/riscv/riscv-pk), [U-Boot](https://github.com/u-boot/u-boot), [Linux kernel](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/) and Debian root FS.
Linux package repositories and regular updates are provided by [Debian](https://wiki.debian.org/RISC-V).
Over 90% of packages of the whole Debian collection are available for download.

Also can be used to run bare-metal or RTOS software.

The project is used as a reference design to validate RISC-V support in [Eclipse TCF](https://wiki.eclipse.org/TCF/RISC-V).

Latest Xilinx tools (Ver. 2020.1+) support debugging of RISC-V software over JTAG.

# Prerequisites

## Hardware
[Xilinx VC707](https://www.xilinx.com/products/boards-and-kits/ek-v7-vc707-g.html) or
[Digilent Genesys 2](https://reference.digilentinc.com/reference/programmable-logic/genesys-2/start) or
[Digilent Nexys Video](https://reference.digilentinc.com/reference/programmable-logic/nexys-video/start) board.

VC707 allows to prototype more powerful system: 2X cores (4 vs 2),
2X memory (1GB vs 512MB), 2X CPU clock frequency (100MHz vs 50MHz).

Nexys Video is several times less expensive, academic discount is avaialble.

Genesys 2 is as fast as VC707, but has slightly smaller FPGA.

## Workstation
[Ubuntu 20 LTS](https://ubuntu.com/download/desktop) machine is recommended.
sudo access required.

## Software
[Vitis 2020.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/2020-2.html) or
[Vitis 2020.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/2020-1.html) or
[Vitis 2019.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vitis/2019-2.html).
Vitis installation includes Vivado Design Suite – there is no need to install Vivado separately.

Nexys Video is supported by free version of Vivado. VC707 and Genesys 2 requires Vivado license.

If using Nexys Video or Genesys 2, install [Vivado Board Files for Digilent FPGA Boards](https://github.com/Digilent/vivado-boards).

# Usage

## Checkout the repository, install required packages and update submodules
```
sudo apt install git make
git clone https://github.com/eugene-tarassov/vivado-risc-v.git
cd vivado-risc-v
make apt-install
make update-submodules
```

## Build FPGA bitstream
```
source /opt/Xilinx/Vivado/2020.2/settings64.sh
make CONFIG=rocket64b2 BOARD=nexys-video bitstream
```
For VC707, use `BOARD=vc707`

For Genesys 2 use `BOARD=genesys2`

Available CONFIG values:
* 64-bit big RISC-V cores, Linux capable:
  * `rocket64b2` - 2 cores
  * `rocket64b2l2` - 2 cores with 512KB level 2 cache
  * `rocket64b2gem` - 2 cores with 512KB level 2 cache and Gemmini accelerator
  * `rocket64b4l2w` - 4 cores with 512KB level 2 cache and wide 256-bit memory bus
  * `rocket64b4` - 4 cores
  * `rocket64b8` - 8 cores
  * `rocket64x1` - 2-wide superscalar Medium BOOM, 1 core
  * `rocket64y1` - 3-wide superscalar Large BOOM, 1 core
  * `rocket64z1` - 4-wide superscalar Mega BOOM, 1 core, added for completeness - too big for supported boards
* 32-bit small RISC-V cores, Linux not supported:
  * `rocket32s1` - 1 core
  * `rocket32s2` - 2 cores
  * `rocket32s4` - 4 cores
  * `rocket32s8` - 8 cores
  * `rocket32s16` - 16 cores

## Prepare the SD card
Use USB SD card reader to connect SD card to the workstation, and run:
```
./mk-sd-card
```
The script looks for USB memory device and asks confirmation before using it.
Make sure to confirm right SD card device - all old data will be erased.

## Program the FPGA flash memory
- Open Vivado
```
source /opt/Xilinx/Vivado/2020.2/settings64.sh
make CONFIG=rocket64b2 BOARD=nexys-video vivado-gui
```
- Open the hardware manager and open the target board
- Select Tools - Add Configuration Memory Device
- Select the following device:
  - Nexys Video: Spansion s25fl256xxxxxx0
  - Genesys 2: Spansion s25fl256xxxxxx0
  - VC707: Micron mt28gu01gaaxle
- Add configuration file:
  - Nexys Video: workspace/rocket64b2/nexys-video-riscv.mcs
  - Genesys 2: workspace/rocket64b2/genesys2-riscv.mcs
  - VC707: workspace/rocket64b2/vc707-riscv.mcs
- Press Ok. Flashing will take a couple of minutes.
- Right click on the FPGA device - Boot from Configuration Memory Device (or press the program button on the board)

See the board and Vivado docs for more details.

## Linux login

Host name: debian

User login and password: debian debian

Root login and password: root root

You can login over UART console:
```
sudo miniterm /dev/ttyUSB0 115200
```
or, after Linux boot, over SSH:
```
ssh debian@debian
```

## Modding the design: adding a peripheral device

### Use Vivado Block Design to add an IP

Open Vivado:
```
source /opt/Xilinx/Vivado/2020.2/settings64.sh
make CONFIG=rocket64b2 BOARD=nexys-video vivado-gui
```
The IO block in the design is the best place to add device controllers, like GPIO.
See AXI Uartlite as an example, connect your IP to AXI interconnect and interrupts.
Validate and synthesize the design, but don't build bitstream yet - device tree and RISC-V HDL need to be updated first.

Close Vivado.

### Check the device driver is enabled in patches/linux.config

For example, for Xilinx GPIO, the config should contain line:
```
CONFIG_GPIO_XILINX=y
```

If necessary, change config, then rebuild Linux kernel and bootloader:
```
make linux bbl
./mk-sd-image -r debian-riscv64-boot
```
Copy debian-riscv64-boot/extlinux directory to the SD card.

Note: don't change files in the project submodules: linux-stable, u-boot, riscv-pk or rocket-chip.
Such changes are lost when the project is rebuilt.

For details on Xilinx drivers, see [Linux Drivers](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841873/Linux%2BDrivers).

### Edit bootrom/bootrom.dts

Add device description in the "soc {...}" section.
For example, GPIO description can look like this:
```
        gpio: gpio@60030000 {
            #gpio-cells = <2>;
            compatible = "xlnx,xps-gpio-1.00.a";
            gpio-controller ;
            interrupt-parent = <&L2>;
            interrupts = <4>;
            reg = < 0x60030000 0x10000 >;
            xlnx,all-inputs = <0x0>;
            xlnx,dout-default = <0x0>;
            xlnx,gpio-width = <0x8>;
            xlnx,interrupt-present = <0x1>;
            xlnx,is-dual = <0>;
            xlnx,tri-default = <0xffffffff>;
        };
```
Make sure the description matches your design. In particular, check addresses and interrupt numbers.

### Rebuild FPGA bitstream
```
make CONFIG=rocket64b2 BOARD=nexys-video bitstream
```
Program the FPGA or the board flash memory.

# Prebuilt images

Prebuilt FPGA bitstream and SD card image are available in the [releases area](https://github.com/eugene-tarassov/vivado-risc-v/releases).

# Notes

Rocket Chip is used as RISC-V implementation: [UC Berkeley Architecture Research - Rocket Chip Generator](https://bar.eecs.berkeley.edu/projects/rocket_chip.html).
Rocket Chip is configured to include virtual memory, instruction and data caches, coherent interconnect, floating point, and all the relevant infrastructure.
See [rocket.scala](https://github.com/eugene-tarassov/vivado-risc-v/blob/master/src/main/scala/rocket.scala) for Rocket Chip configuration classes.

RISC-V SoC in this repo contains bootrom, which differ from original Rocket Chip bootrom.
The modified bootrom contains SD card boot loader and extended device tree.

RISC-V SoC in this repo contains DDR, UART, SD and Ethernet controllers.
DDR is provided by Vivado. UART, SD and Ethernet are open source Verilog.

SD controller implements SD HS (High Speed) specs, 25MB/s read/write speed.

Ethernet controller is based on [Verilog Ethernet Components](https://github.com/alexforencich/verilog-ethernet) project,
which is a collection of Ethernet-related components for gigabit, 10G, and 25G packet processing.

Linux kernel and U-Boot use device tree, which is stored in RISC-V bootrom in FPGA.
So, same SD card should boot OK on any board or RISC-V configuration.

Nexys Video board can be configured to [load FPGA bitstream from SD card](https://reference.digilentinc.com/reference/programmable-logic/nexys-video/reference-manual#usb_host_and_micro_sd_programming).

The device tree contains Ethernet MAC address, which is not unique.
It might be necessary to rebuild bitstream with different MAC, see Makefile for details.

If not using provided SD card image: the bootrom loads and executes boot.elf file from SD card DOS partition.
boot.elf is regular executable ELF, it can contain any software suitable for RISC-V RV64 M mode.
In case of Linux boot, boot.elf contains Berkeley Boot Loader and U-Boot.

The Makefile creates Vivado project directory, e.g. workspace/rocket64b2/vivado-nexys-video-riscv.
You can open the project in Vivado GUI to see RISC-V SoC structure, make changes, add peripherals, rebuild the bitstream.
The SoC occupies about 60% of FPGA, leaving plenty of space for experiments and developing additional hardware.

RISC-V SoC in this repo uses BSCAN block to support both RISC-V debugging and FPGA access over same JTAG cable.