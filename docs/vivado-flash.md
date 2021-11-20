## Using Vivado GUI to program the FPGA flash memory
- Open Vivado
```
source /opt/Xilinx/Vivado/2021.1/settings64.sh
make CONFIG=rocket64b2 BOARD=nexys-video bitstream vivado-gui
```
- Open the hardware manager and open the target board
- Select Tools - Add Configuration Memory Device
- Select the following device:
  - Nexys A7 100T: Spansion s25fl128sxxxxxx0
  - Nexys Video: Spansion s25fl256sxxxxxx0
  - Genesys 2: Spansion s25fl256sxxxxxx0
  - KC705: Micron 28f00ap30t
  - VC707: Micron mt28gu01gaax1e
- Add configuration file:
  - Nexys A7 100T: workspace/rocket64b1/nexys-a7-100t-riscv.mcs
  - Nexys Video: workspace/rocket64b2/nexys-video-riscv.mcs
  - Genesys 2: workspace/rocket64b2/genesys2-riscv.mcs
  - KC705: workspace/rocket64b2/kc705-riscv.mcs
  - VC707: workspace/rocket64b2/vc707-riscv.mcs
- Press Ok. Flashing will take a couple of minutes.
- Right click on the FPGA device - Boot from Configuration Memory Device (or press the program button on the board)

See the board and Vivado docs for more details.
