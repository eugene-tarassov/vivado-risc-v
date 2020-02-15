# SDIO
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_clk }]; #IO_L12P_T1_MRCC_14 Sch=sd_cclk
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_cmd }]; #IO_L12N_T1_MRCC_14 Sch=sd_cmd
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[0] }]; #IO_L14N_T2_SRCC_14 Sch=sd_d[0]
set_property -dict { PACKAGE_PIN T21   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[1] }]; #IO_L4P_T0_D04_14 Sch=sd_d[1]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sd_d[2]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[3] }]; #IO_L18N_T2_A11_D27_14 Sch=sd_d[3]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { sdio_reset }]; #IO_L11N_T1_SRCC_14 Sch=sd_reset
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { sdio_cd }]; #IO_L20N_T3_A07_D23_14 Sch=sd_cd

set sdio_clock [get_clocks -of_objects [get_pins -hier clk_wiz_1/clk_out1]]
set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]

set_clock_groups -asynchronous -group $sdio_clock -group $main_clock

set_max_delay -from $main_clock -to $sdio_clock -datapath_only 8.0
set_max_delay -from $sdio_clock -to $main_clock -datapath_only 8.0

set_max_delay -from $sdio_clock -to [get_ports sdio_*] -datapath_only 10.0
set_max_delay -from [get_ports sdio_cmd] -to $sdio_clock -datapath_only 10.0
set_max_delay -from [get_ports sdio_dat*] -to $sdio_clock -datapath_only 10.0

set_false_path -through [get_pins -hier SD/async_resetn]
set_false_path -through [get_pins -hier SD/int_cmd]
set_false_path -through [get_pins -hier SD/int_data]
