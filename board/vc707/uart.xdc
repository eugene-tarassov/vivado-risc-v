# UART
set_property -dict {PACKAGE_PIN AU36 IOSTANDARD LVCMOS18} [get_ports rs232_uart_txd]
set_property -dict {PACKAGE_PIN AU33 IOSTANDARD LVCMOS18} [get_ports rs232_uart_rxd]
set_property -dict {PACKAGE_PIN AT32 IOSTANDARD LVCMOS18} [get_ports rs232_uart_ctsn]
set_property -dict {PACKAGE_PIN AR34 IOSTANDARD LVCMOS18} [get_ports rs232_uart_rtsn]

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set uart_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out2]]

set_max_delay -datapath_only -from $uart_clock -to [get_ports rs232_uart_rtsn] 10.0
set_max_delay -datapath_only -from $uart_clock -to [get_ports rs232_uart_txd] 10.0
set_max_delay -datapath_only -from [get_ports rs232_uart_ctsn] -to $uart_clock 10.0
set_max_delay -datapath_only -from [get_ports rs232_uart_rxd] -to $uart_clock 10.0
set_max_delay -datapath_only -from $main_clock -through [get_pins -hier UART/async_resetn] 10.0
set_max_delay -datapath_only -from $uart_clock -through [get_pins -hier UART/interrupt] 10.0
