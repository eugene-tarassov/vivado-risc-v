set_property BITSTREAM.CONFIG.UNUSEDPIN pulldown [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

create_clock -period 10 [get_pins -hier {*BSCAN*/TCK}]
create_clock -period 10 [get_pins -hier {*BSCAN*/DRCK}]
create_clock -period 10 [get_pins -hier {*BSCAN*/UPDATE}]

#set jtag_clock [get_clocks -of_objects [get_pins -hier {*BSCAN*/TCK *BSCAN*/DRCK *BSCAN*/UPDATE}]]
set jtag_clock [get_clocks -of_objects [get_pins -hier {*BSCAN*/TCK}]]
set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set ddrc_clock [get_clocks -of_objects [get_pins -hier mig_7series_0/ui_clk]]

set_clock_groups -asynchronous -group $jtag_clock -group $main_clock -group $ddrc_clock

set_max_delay 8 -from $main_clock -to [get_ports lcd_*] -datapath_only
set_max_delay 8 -from $main_clock -to [get_ports led_*] -datapath_only
set_max_delay 8 -from [get_ports dip_switches_*] -to $main_clock -datapath_only

set_max_delay -from $main_clock -to $jtag_clock -datapath_only 8.0
set_max_delay -from $jtag_clock -to $main_clock -datapath_only 8.0

set_max_delay -from $main_clock -to $ddrc_clock -datapath_only 8.0
set_max_delay -from $ddrc_clock -to $main_clock -datapath_only 8.0

