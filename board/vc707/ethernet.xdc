#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------
set_property PACKAGE_PIN AH8  [get_ports sgmii_mgt_clk_clk_p]
set_property PACKAGE_PIN AH7  [get_ports sgmii_mgt_clk_clk_n]
set_property PACKAGE_PIN AN2  [get_ports sgmii_txp]
set_property PACKAGE_PIN AN1  [get_ports sgmii_txn]
set_property PACKAGE_PIN AM7  [get_ports sgmii_rxn]
set_property PACKAGE_PIN AM8  [get_ports sgmii_rxp]
#set_property PACKAGE_PIN AH31 [get_ports mdc]
#set_property PACKAGE_PIN AK33 [get_ports mdio]
#set_property PACKAGE_PIN AJ33 [get_ports phy_resetn]
#set_property PACKAGE_PIN AL31 [get_ports eint]

#set_property IOSTANDARD LVCMOS18 [get_ports mdc]
#set_property IOSTANDARD LVCMOS18 [get_ports mdio]
#set_property IOSTANDARD LVCMOS18 [get_ports phy_resetn]
#set_property IOSTANDARD LVCMOS18 [get_ports eint]

set eth_tx_clock [get_clocks -of_objects [get_pins -hier gtxe2_i/TXOUTCLK]]
set eth_rx_clock [get_clocks -of_objects [get_pins -hier gtxe2_i/RXOUTCLK]]
set eth_userclk2 [get_clocks -of_objects [get_pins -hier bufg_userclk2/O]]
set main_clock [get_clocks -of_objects [get_pins -hier clk_wiz_0/clk_out1]]

set_clock_groups -asynchronous -group ${eth_tx_clock} -group ${eth_rx_clock} -group ${eth_userclk2} -group ${main_clock}

set_max_delay -from ${main_clock} -to ${eth_tx_clock} -datapath_only 6.0
set_max_delay -from ${main_clock} -to ${eth_rx_clock} -datapath_only 6.0
set_max_delay -from ${main_clock} -to ${eth_userclk2} -datapath_only 6.0
set_max_delay -from ${eth_tx_clock} -to ${main_clock} -datapath_only 6.0
set_max_delay -from ${eth_rx_clock} -to ${main_clock} -datapath_only 6.0
set_max_delay -from ${eth_userclk2} -to ${main_clock} -datapath_only 6.0
set_max_delay -from ${eth_rx_clock} -to ${eth_tx_clock} -datapath_only 6.0

set_false_path -through [get_pins -hier Ethernet/async_resetn]
set_false_path -through [get_pins -hier Ethernet/interrupt]
