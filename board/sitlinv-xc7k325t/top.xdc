set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property DCI_CASCADE {32 34} [get_iobanks 33]

# SYSCLK 200MHz
set_property -dict { PACKAGE_PIN AB11 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN AC11 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_n]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_pins -hier clk_wiz_0/clk_in1]]
create_clock -period 5.000 -name sys_clock_bufds [get_pins -hier clk_wiz_0/clk_in1]

# CPU reset button, active LOW
set_property -dict { PACKAGE_PIN AC16 IOSTANDARD LVCMOS15 } [get_ports reset]

# DDR OK LED
set_property -dict { PACKAGE_PIN AA2 IOSTANDARD LVCMOS15 } [get_ports LED0]

# set_property -dict { PACKAGE_PIN AD5  IOSTANDARD LVCMOS15 } [get_ports LED1]
# set_property -dict { PACKAGE_PIN W10  IOSTANDARD LVCMOS15 } [get_ports LED2]
# set_property -dict { PACKAGE_PIN Y10  IOSTANDARD LVCMOS15 } [get_ports LED3]
# set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS15 } [get_ports LED4]
# set_property -dict { PACKAGE_PIN W11  IOSTANDARD LVCMOS15 } [get_ports LED5]
# set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS15 } [get_ports LED6]
# set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVCMOS15 } [get_ports LED7]
