#-----------------------------------------------------------
#              Ethernet / RGMII                            -
#-----------------------------------------------------------

set_property -dict { PACKAGE_PIN AF12  IOSTANDARD LVCMOS15 } [get_ports { eth_mdio_clock }];
set_property -dict { PACKAGE_PIN AG12  IOSTANDARD LVCMOS15 } [get_ports { eth_mdio_data }];
set_property -dict { PACKAGE_PIN AK16  IOSTANDARD LVCMOS18 } [get_ports { eth_mdio_int }];
set_property -dict { PACKAGE_PIN AH24  IOSTANDARD LVCMOS33 } [get_ports { eth_mdio_reset }];
set_property -dict { PACKAGE_PIN AG10  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rxc }];
set_property -dict { PACKAGE_PIN AH11  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rx_ctl }];
set_property -dict { PACKAGE_PIN AJ14  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rd[0] }];
set_property -dict { PACKAGE_PIN AH14  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rd[1] }];
set_property -dict { PACKAGE_PIN AK13  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rd[2] }];
set_property -dict { PACKAGE_PIN AJ13  IOSTANDARD LVCMOS15 } [get_ports { rgmii_rd[3] }];
set_property -dict { PACKAGE_PIN AE10  IOSTANDARD LVCMOS15 } [get_ports { rgmii_txc }];
set_property -dict { PACKAGE_PIN AK14  IOSTANDARD LVCMOS15 } [get_ports { rgmii_tx_ctl }];
set_property -dict { PACKAGE_PIN AJ12  IOSTANDARD LVCMOS15 } [get_ports { rgmii_td[0] }];
set_property -dict { PACKAGE_PIN AK11  IOSTANDARD LVCMOS15 } [get_ports { rgmii_td[1] }];
set_property -dict { PACKAGE_PIN AJ11  IOSTANDARD LVCMOS15 } [get_ports { rgmii_td[2] }];
set_property -dict { PACKAGE_PIN AK10  IOSTANDARD LVCMOS15 } [get_ports { rgmii_td[3] }];

create_clock -period 8.000 -name rgmii_rx_clk [get_ports rgmii_rxc]

# Genesys 2 board uses RTL8211E-VL phy, TXDLY off, RXDLY on, 1.8V signaling, HP bank (ODELAY available).
# Note: max (setup) is measured from prev clock edge, min (hold) - from current clock edge.
# Data valid period, relative to the current clock edge, is [max-4.0ns .. min].
# With RXDLY on, the center of data valid period is supposed to be at the clock edge, but it is set at -1.35ns offset.
# This offset is not required by RGMII specs, but tests show it improves stability on Genesys 2 board.
# Changing of the constraints require changes of IDELAY_VALUE in ethernet-genesys2.v.
set_input_delay -add_delay -clock rgmii_rx_clk -max 2.00 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min 0.70 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -max 2.00 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min 0.70 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]

# To see implemented RX timing, run from Vivado Tcl Console:
# report_timing -from [get_ports {rgmii_rd* rgmii_rx_ctl}] -rise_to rgmii_rx_clk -delay_type min_max -max_paths 10 -name rgmii_rx  -file rgmii_rx.txt
