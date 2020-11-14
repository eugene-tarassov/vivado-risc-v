# UART
set_property -dict {PACKAGE_PIN AU36 IOSTANDARD LVCMOS18} [get_ports rs232_uart_txd]
set_property -dict {PACKAGE_PIN AU33 IOSTANDARD LVCMOS18} [get_ports rs232_uart_rxd]
set_property -dict {PACKAGE_PIN AT32 IOSTANDARD LVCMOS18} [get_ports rs232_uart_ctsn]
set_property -dict {PACKAGE_PIN AR34 IOSTANDARD LVCMOS18} [get_ports rs232_uart_rtsn]
