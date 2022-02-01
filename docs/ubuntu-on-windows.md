# Running RISC-V tools on Windows

RocketChip generator and Linux/U-Boot/OpenSBI builds can run on Windows under WSL (Windows Subsystem for Linux) and Ubuntu terminal.

# Ubuntu on Windows 10

Ubuntu 20 LTS terminal is freely available for Windows 10, see [ubuntu.com/tutorials/ubuntu-on-windows](https://ubuntu.com/tutorials/ubuntu-on-windows) for installation instructions.

Make sure you install WSL 2, not WSL 1. Check the version by running wsl command in Windows cmd shell:
```
C:\Users\eugene>wsl --list --verbose
  NAME                   STATE           VERSION
  Ubuntu-20.04           Running         2
```
WSL 1 does not supprt loop device, which is needed to build SD card image.
If necessary, run WSL conversion:
```
C:\Users\eugene>wsl --set-version Ubuntu-20.04 2
Conversion in progress, this may take a few minutes...
For information on key differences with WSL 2 please visit https://aka.ms/wsl2
Conversion complete.
```

Linux apps, like git, require Windows drives under WSL to be mounted with the metadata option:
```
sudo mount -t drvfs D: /mnt/d -o metadata
```

Windows has [maximum file path length limitation 260 characters](https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=cmd).
Don't use /home to store risc-v repo, the directory has very long Windows path, the repo will hit path length limitation.
The best approach is to use separate drive, mount it with metadata option, and clone the repo at the drive root:
```
sudo mount -t drvfs D: /mnt/d -o metadata
cd /mbt/d
sudo apt install git make
git clone https://github.com/eugene-tarassov/vivado-risc-v.git
cd vivado-risc-v
make apt-install
make update-submodules
```

# Using Windows version of Vivado

It is also possible to generate RISC-V RTL using Ubuntu terminal, but use Windows version of Vivado to do the rest, e.g.:
```
make CONFIG=rocket64b2 BOARD=vc707 vivado-tcl
```
Launch Vivado GUI, go to Tcl Console and run the Tcl script to create Vivado project:
```
source d:/vivado-risc-v/workspace/rocket64b2/system-vc707.tcl
```
Use the Vivado GUI to build bitstream, program FPGA, make changes, etc.
