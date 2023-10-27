#-----------------------------------------------------------
#              Ethernet / RMII                            -
#-----------------------------------------------------------

set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { eth_mdio_clock }];
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { eth_mdio_data }];
set_property -dict { PACKAGE_PIN B8  IOSTANDARD LVCMOS33 } [get_ports { eth_mdio_int }];
set_property -dict { PACKAGE_PIN B3  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 16 } [get_ports { eth_mdio_reset }];

set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33 } [get_ports { rmii_rxd[0] }];
set_property -dict { PACKAGE_PIN D10  IOSTANDARD LVCMOS33 } [get_ports { rmii_rxd[1] }];
set_property -dict { PACKAGE_PIN C10  IOSTANDARD LVCMOS33 } [get_ports { rmii_rx_er }];

set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS33 } [get_ports { rmii_txd[0] }];
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports { rmii_txd[1] }];
set_property -dict { PACKAGE_PIN B9   IOSTANDARD LVCMOS33 } [get_ports { rmii_tx_en }];

set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { rmii_crs_dv }];
set_property -dict { PACKAGE_PIN D5  IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { eth_ref_clock }];


set rmii_clk [create_clock -period 20.000 -name rmii_clk [get_ports eth_ref_clock]]
set eth_clock [get_clocks -of_objects [get_pins -hier Ethernet/clock]]
set_max_delay -from $eth_clock -to $rmii_clk -datapath_only 18.000
set_max_delay -from $rmii_clk -to $eth_clock -datapath_only 18.000

set_input_delay -clock rmii_clk -max 14.000 [get_ports { rmii_rxd* rmii_crs_dv rmii_rx_er }]
set_input_delay -clock rmii_clk -min  5.000 [get_ports { rmii_rxd* rmii_crs_dv rmii_rx_er }]
set_output_delay -clock rmii_clk -max 6.000 [get_ports { rmii_txd* rmii_tx_en }]
set_output_delay -clock rmii_clk -min 0.000 [get_ports { rmii_txd* rmii_tx_en }]
