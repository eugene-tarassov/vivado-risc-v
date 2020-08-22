# UART
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports usb_uart_txd]

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set uart_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out3]]

set_max_delay -datapath_only -from $uart_clock -to [get_ports usb_uart_txd] 10.0
set_max_delay -datapath_only -from [get_ports usb_uart_rxd] -to $uart_clock 10.0
set_max_delay -datapath_only -from $main_clock -through [get_pins -hier UART/async_resetn] 10.0
set_max_delay -datapath_only -from $uart_clock -through [get_pins -hier UART/interrupt] 10.0
