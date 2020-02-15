# vivado-risc-v

# Xilinx Vivado block designs for FPGA RISC-V SoC running Debian Linux distro.

This repository helps to create RISC-V SoC HDL, Vivado project, FPGA bitstream and bootable SD card.
The SD card contains Berkeley boot loader, U-Boot, 5.4 Linux kernel and Debian root FS.
Linux package repositories and regular updates are provided by Debian.

Also can be used to run bare-metal or RTOS.

# Prerequisites

## Hardware
Xilinx VC707 or Digilent Nexys Video board.
VC707 allows to prototype more powerful system: 2X core (4 vs 2),
2X memory (1GB vs 512MB), 2X CPU clock frequency (100MHz vs 50MHz).
Nexys Video is several time less expensive, especially with academic pricing.

## Workstation
Ubuntu 18 LTS machine is recommended.
sudo access required.

## Software
Vivado 2019.1. Nexys Video is supported by free version of Vivado. VC707 requires Vivado license.

# Usage
```
sudo apt update
sudo apt install git make gcc-riscv64-linux-gnu
git clone https://github.com/eugene-tarassov/vivado-risc-v.git
cd vivado-risc-v
make update-submodules
source /opt/Xilinx/Vivado/2019.1/settings64.sh
make CONFIG=rocket64b2 BOARD=nexys-video bitstream
make linux bbl
```
Use USB SD card reader to connect SD card to the workstation, and run:
```
./mk-sd-card
```
The script looks for USB memory device and asks confirmation before using it.
Make sure to confirm right SD card devices - all old data will be erased.
