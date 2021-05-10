# UART
set_property -dict {PACKAGE_PIN K24 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports rs232_uart_txd]
set_property -dict {PACKAGE_PIN L27 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports rs232_uart_rtsn]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS25} [get_ports rs232_uart_rxd]
set_property -dict {PACKAGE_PIN K23 IOSTANDARD LVCMOS25} [get_ports rs232_uart_ctsn]
