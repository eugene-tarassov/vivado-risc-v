set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Clock Signal
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports sys_clock];
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_ports sys_clock]]
create_clock -name sys_clk_pin -period 10.00 [get_ports sys_clock]

## Reset button
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports reset];
