set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type2 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-2 [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property CFGBVS VCCO [current_design]

set_property DCI_CASCADE {32 34} [get_iobanks 33]

# SYSCLK 200MHz
set_property -dict { PACKAGE_PIN AD12 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN AD11 IOSTANDARD DIFF_SSTL15 } [get_ports sys_diff_clock_clk_n]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_pins -hier clk_wiz_0/clk_in1]]
create_clock -period 5.000 -name sys_clock_bufds [get_pins -hier clk_wiz_0/clk_in1]

# CPU reset button
set_property -dict { PACKAGE_PIN AB7 IOSTANDARD LVCMOS15 } [get_ports reset]

# DDR OK LED
set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS15 } [get_ports LED0]

# Cooling fan
set_property -dict { PACKAGE_PIN L26 IOSTANDARD LVCMOS25 } [get_ports fan_en]
#set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS25 } [get_ports fan_tach]
