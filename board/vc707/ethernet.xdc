#-----------------------------------------------------------
#              Ethernet / SGMII                            -
#-----------------------------------------------------------

# SGMII GTX Transceiver Clock 125MHz
set_property PACKAGE_PIN AH8  [get_ports sgmii_mgt_clk_clk_p]
set_property PACKAGE_PIN AH7  [get_ports sgmii_mgt_clk_clk_n]
create_clock -period 8.000 -name sgmii_mgt_clock [get_ports sgmii_mgt_clk_clk_p]

set_property PACKAGE_PIN AN2  [get_ports sgmii_txp]
set_property PACKAGE_PIN AN1  [get_ports sgmii_txn]
set_property PACKAGE_PIN AM8  [get_ports sgmii_rxp]
set_property PACKAGE_PIN AM7  [get_ports sgmii_rxn]

set_property -dict { PACKAGE_PIN AH31 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_clock]
set_property -dict { PACKAGE_PIN AK33 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_data]
set_property -dict { PACKAGE_PIN AJ33 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_reset]
set_property -dict { PACKAGE_PIN AL31 IOSTANDARD LVCMOS18 } [get_ports eth_mdio_int]
