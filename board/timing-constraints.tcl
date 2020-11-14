#------------------ RocketChip

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]

set_false_path -through [get_pins -hier RocketChip/clock_ok]
set_false_path -through [get_pins -hier RocketChip/mem_ok]
set_false_path -through [get_pins -hier RocketChip/io_ok]
set_false_path -through [get_pins -hier RocketChip/sys_reset]

#------------------ Ethernet adapter

if { [llength [get_pins -quiet -hier ethernet_stream_0/clock]] > 0 } {
  set eth_clock [get_clocks -of_objects [get_pins -hier ethernet_stream_0/clock]]
} else {
  set eth_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out4]]
}

set_max_delay -from $eth_clock -to $main_clock -datapath_only 10.0
set_max_delay -from $main_clock -to $eth_clock -datapath_only 10.0

set_max_delay -from $eth_clock -to [get_ports {eth_mdio_clock eth_mdio_data eth_mdio_reset}] -datapath_only 40.0
set_max_delay -from [get_ports {eth_mdio_data eth_mdio_int}] -to $eth_clock -datapath_only 40.0

set_max_delay -from $main_clock -through [get_pins -hier Ethernet/async_resetn] -datapath_only 10.0
set_max_delay -from $eth_clock -through [get_pins -hier Ethernet/interrupt] -datapath_only 10.0

if { [llength [get_clocks rgmii_rx_clk]] > 0 } {
  set_max_delay -from $eth_clock -to rgmii_rx_clk -datapath_only 7.0
  set_max_delay -from rgmii_rx_clk -to $eth_clock -datapath_only 7.0
}

#------------------ SD card controller

set sdio_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out3]]

set_max_delay -from $sdio_clock -to $main_clock -datapath_only 12.0
set_max_delay -from $main_clock -to $sdio_clock -datapath_only 12.0

set_max_delay -from $sdio_clock -to [get_ports {sdio_clk sdio_cmd sdio_dat*}] -datapath_only 8.0
set_max_delay -from [get_ports {sdio_cmd sdio_dat*}]  -to $sdio_clock -datapath_only 8.0

if { [llength [get_ports -quiet sdio_reset]] > 0 } {
  set_max_delay -from $sdio_clock -to [get_ports sdio_reset] -datapath_only 100.0
}
if { [llength [get_ports -quiet sdio_cd]] > 0 } {
  set_max_delay -from [get_ports sdio_cd] -to $sdio_clock -datapath_only 100.0
}

set_max_delay -from $main_clock -through [get_pins -hier SD/async_resetn] -datapath_only 10.0
set_max_delay -from $sdio_clock -through [get_pins -hier SD/interrupt] -datapath_only 10.0

#------------------ UART

set uart_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out3]]

if { [llength [get_ports -quiet usb_uart_*]] > 0 } {
  set_max_delay -datapath_only -from $uart_clock -to [get_ports usb_uart_txd] 100.0
  set_max_delay -datapath_only -from [get_ports usb_uart_rxd] -to $uart_clock 100.0
  set_max_delay -datapath_only -from $main_clock -through [get_pins -hier UART/async_resetn] 100.0
  set_max_delay -datapath_only -from $uart_clock -through [get_pins -hier UART/interrupt] 100.0
}

if { [llength [get_ports -quiet rs232_uart_*]] > 0 } {
  set_max_delay -datapath_only -from $uart_clock -to [get_ports rs232_uart_rtsn] 100.0
  set_max_delay -datapath_only -from $uart_clock -to [get_ports rs232_uart_txd] 100.0
  set_max_delay -datapath_only -from [get_ports rs232_uart_ctsn] -to $uart_clock 100.0
  set_max_delay -datapath_only -from [get_ports rs232_uart_rxd] -to $uart_clock 100.0
  set_max_delay -datapath_only -from $main_clock -through [get_pins -hier UART/async_resetn] 100.0
  set_max_delay -datapath_only -from $uart_clock -through [get_pins -hier UART/interrupt] 100.0
}

#------------------ JTAG

set tck_pin ""
if { [llength [get_pins -quiet -hier jtag/TCK]] > 0 } {
  # RISC-V Debug Module is connected directly to the FPGA JTAG (aka BSCAN)
  set tck_pin [get_pins -hier jtag/TCK]
} elseif { [llength [get_pins -quiet -hier SERIES7_BSCAN*/TCK]] > 0 } {
  # Debug Bridge is used for debugging
  set tck_pin [get_pins -hier SERIES7_BSCAN*/TCK]
}

if { $tck_pin != "" } {
  create_clock -period 15.000 $tck_pin
  set jtag_clock [get_clocks -of_objects $tck_pin]

  set_max_delay -reset_path -from $main_clock -to $jtag_clock -datapath_only 12.0
  set_max_delay -reset_path -from $jtag_clock -to $main_clock -datapath_only 12.0
}

#------------------ DDR RAM controller

set ddrc_clock [get_clocks -of_objects [get_pins -hier mig_7series_0/ui_clk]]

set_max_delay -from $main_clock -to $ddrc_clock -datapath_only 10.0
set_max_delay -from $ddrc_clock -to $main_clock -datapath_only 10.0

# Workaround for what appears to be incorrect constraint in MIG
set_max_delay -from $main_clock -to [get_clocks { clk_pll_i* }] -datapath_only 8.0

set_max_delay -from $main_clock -through [get_pins -hier mig_7series_0/aresetn] -datapath_only 10.0
