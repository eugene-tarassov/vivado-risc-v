# UART
set_property -dict {PACKAGE_PIN D4  IOSTANDARD LVCMOS33} [get_ports rs232_uart_txd]
set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS33} [get_ports rs232_uart_rxd]
set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS33} [get_ports rs232_uart_ctsn]
set_property -dict {PACKAGE_PIN D3  IOSTANDARD LVCMOS33} [get_ports rs232_uart_rtsn]
