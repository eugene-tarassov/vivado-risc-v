# SDIO
set_property -dict { PACKAGE_PIN AN30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_clk}]
set_property -dict { PACKAGE_PIN AP30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_cmd}]
set_property -dict { PACKAGE_PIN AR30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[0]}]
set_property -dict { PACKAGE_PIN AU31  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[1]}]
set_property -dict { PACKAGE_PIN AV31  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[2]}]
set_property -dict { PACKAGE_PIN AT30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[3]}]
set_property -dict { PACKAGE_PIN AP32  IOSTANDARD LVCMOS18 } [get_ports {sdio_cd}]
# Note: card detect does not work on VC707 due to an error in VC707 schematics

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set sdio_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out2]]

set_max_delay -from $sdio_clock -to [get_ports sdio_*] -datapath_only 8.0
set_max_delay -from [get_ports sdio_cmd]  -to $sdio_clock -datapath_only 8.0
set_max_delay -from [get_ports sdio_dat*] -to $sdio_clock -datapath_only 8.0
set_max_delay -from [get_ports sdio_cd]   -to $sdio_clock -datapath_only 8.0

set_max_delay -from $main_clock -through [get_pins -hier SD/async_resetn] -datapath_only 10.0
set_max_delay -from $sdio_clock -through [get_pins -hier SD/interrupt] -datapath_only 10.0
