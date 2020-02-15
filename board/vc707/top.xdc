set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

# SYSCLK 200MHz
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVDS } [get_ports sys_diff_clock_clk_p]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVDS } [get_ports sys_diff_clock_clk_n]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets -of_objects [get_pins -hier clk_wiz_0/clk_in1]]
create_clock -period 5.000 -name sys_clock_bufds [get_pins -hier clk_wiz_0/clk_in1]

create_clock -period 12.5 [get_pins -hier jtag/TCK]

set jtag_clock [get_clocks -of_objects [get_pins -hier jtag/TCK]]
set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set ddrc_clock [get_clocks -of_objects [get_pins -hier mig_7series_0/ui_clk]]

set_clock_groups -asynchronous -group ${jtag_clock} -group ${main_clock} -group ${ddrc_clock}

set_max_delay -from ${main_clock} -to ${jtag_clock} -datapath_only 8.0
set_max_delay -from ${jtag_clock} -to ${main_clock} -datapath_only 8.0

set_max_delay -from ${main_clock} -to ${ddrc_clock} -datapath_only 8.0
set_max_delay -from ${ddrc_clock} -to ${main_clock} -datapath_only 8.0

set_false_path -through [get_pins -hier RocketChip/clock_ok]
set_false_path -through [get_pins -hier RocketChip/mem_ok]
set_false_path -through [get_pins -hier RocketChip/io_ok]
set_false_path -through [get_pins -hier RocketChip/sys_reset]
