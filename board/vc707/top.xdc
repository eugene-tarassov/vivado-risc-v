set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property CONFIG_MODE BPI16 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

# SYSCLK 200MHz
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVDS } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVDS } [get_ports sys_diff_clock_clk_n]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_pins -hier clk_wiz_0/clk_in1]]
create_clock -period 5.000 -name sys_clock_bufds [get_pins -hier clk_wiz_0/clk_in1]

# Reset
set_property -dict { PACKAGE_PIN AV40 IOSTANDARD LVCMOS18 } [get_ports reset]

# Cooling fan
set_property -dict { PACKAGE_PIN BA37 IOSTANDARD LVCMOS18 } [get_ports fan_en]
#set_property -dict { PACKAGE_PIN BB37 IOSTANDARD LVCMOS18 } [get_ports fan_tach]
