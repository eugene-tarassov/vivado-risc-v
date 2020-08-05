#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------
set_property PACKAGE_PIN AH8  [get_ports sgmii_mgt_clk_clk_p]
set_property PACKAGE_PIN AH7  [get_ports sgmii_mgt_clk_clk_n]
set_property PACKAGE_PIN AN2  [get_ports sgmii_txp]
set_property PACKAGE_PIN AN1  [get_ports sgmii_txn]
set_property PACKAGE_PIN AM7  [get_ports sgmii_rxn]
set_property PACKAGE_PIN AM8  [get_ports sgmii_rxp]
set_property -dict { PACKAGE_PIN AH31 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_clock]
set_property -dict { PACKAGE_PIN AK33 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_data]
set_property -dict { PACKAGE_PIN AJ33 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_reset]
set_property -dict { PACKAGE_PIN AL31 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_int]

set eth_tx_clock [get_clocks -of_objects [get_pins -hier gtxe2_i/TXOUTCLK]]
set eth_rx_clock [get_clocks -of_objects [get_pins -hier gtxe2_i/RXOUTCLK]]
set eth_userclk2 [get_clocks -of_objects [get_pins -hier bufg_userclk2/O]]

set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]
set eth_main_clock [get_clocks -of_objects [get_pins -hier Ethernet/clock]]

set_max_delay -from $main_clock -through [get_pins -hier Ethernet/async_resetn] -datapath_only 10.0
set_max_delay -from $eth_main_clock -through [get_pins -hier Ethernet/interrupt] -datapath_only 10.0
