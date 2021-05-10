set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property CFGBVS VCCO [current_design]

set_property DCI_CASCADE {32 34} [get_iobanks 33]

# SYSCLK 200MHz
set_property -dict { PACKAGE_PIN AD12 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN AD11 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_n]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_pins -hier clk_wiz_0/clk_in1]]
create_clock -period 5.000 -name sys_clock_bufds [get_pins -hier clk_wiz_0/clk_in1]

# Reset button
set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS15 } [get_ports reset];

set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS15 } [get_ports LED0];
