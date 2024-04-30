# UART
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports usb_uart_txd]
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd]
