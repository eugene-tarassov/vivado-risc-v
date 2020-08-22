# UART
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS33} [get_ports usb_uart_txd]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd]

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set uart_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out3]]

set_max_delay -datapath_only -from $uart_clock -to [get_ports usb_uart_txd] 10.0
set_max_delay -datapath_only -from [get_ports usb_uart_rxd] -to $uart_clock 10.0
set_max_delay -datapath_only -from $main_clock -through [get_pins -hier UART/async_resetn] 10.0
set_max_delay -datapath_only -from $uart_clock -through [get_pins -hier UART/interrupt] 10.0
