#-----------------------------------------------------------
#              Ethernet / GMII                            -
#-----------------------------------------------------------

set_property -dict { PACKAGE_PIN F9    IOSTANDARD LVCMOS33 } [get_ports { eth_a_mdio_clock }];
set_property -dict { PACKAGE_PIN H11   IOSTANDARD LVCMOS33 } [get_ports { eth_a_mdio_data }];
set_property -dict { PACKAGE_PIN J8    IOSTANDARD LVCMOS33 } [get_ports { eth_a_mdio_reset }];

set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rxc }];
set_property -dict { PACKAGE_PIN F8    IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rx_ctl }];
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rd[0] }];
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rd[1] }];
set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rd[2] }];
set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_rd[3] }];
set_property -dict { PACKAGE_PIN D11   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_txc }];
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_tx_ctl }];
set_property -dict { PACKAGE_PIN E12   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_td[0] }];
set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_td[1] }];
set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_td[2] }];
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { rgmii_a_td[3] }];

set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports { eth_b_mdio_clock }];
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports { eth_b_mdio_data }];
set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { eth_b_mdio_reset }];

set_property -dict { PACKAGE_PIN E10   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rxc }];
set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rx_ctl }];
set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rd[0] }];
set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rd[1] }];
set_property -dict { PACKAGE_PIN B10   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rd[2] }];
set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_rd[3] }];
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_txc }];
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_tx_ctl }];
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_td[0] }];
set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_td[1] }];
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_td[2] }];
set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { rgmii_b_td[3] }];

# SITLINV board uses RTL8211E-VB phy, TXDLY on, RXDLY on, 3.3V signaling, HR bank (ODELAY not available).
# Note: max (setup) is measured from prev clock edge, min (hold) - from current clock edge.
# Data valid period, relative to the current clock edge, is [max-4.0ns .. min].
# With RXDLY on, the center of data valid period is supposed to be at the clock edge, but it is set at -1.35ns offset.
# Changing of the constraints require changes of IDELAY_VALUE in ethernet-sitlinv-xc7k325t.v.

create_clock -period 8.000 -name rgmii_a_rx_clk [get_ports rgmii_a_rxc]
create_clock -period 8.000 -name rgmii_b_rx_clk [get_ports rgmii_b_rxc]

set_input_delay -add_delay -clock rgmii_a_rx_clk -max 2.00 [get_ports { rgmii_a_rd* rgmii_a_rx_ctl }]
set_input_delay -add_delay -clock rgmii_a_rx_clk -min 0.70 [get_ports { rgmii_a_rd* rgmii_a_rx_ctl }]
set_input_delay -add_delay -clock rgmii_a_rx_clk -max 2.00 -clock_fall [get_ports { rgmii_a_rd* rgmii_a_rx_ctl }]
set_input_delay -add_delay -clock rgmii_a_rx_clk -min 0.70 -clock_fall [get_ports { rgmii_a_rd* rgmii_a_rx_ctl }]

set_input_delay -add_delay -clock rgmii_b_rx_clk -max 2.00 [get_ports { rgmii_b_rd* rgmii_b_rx_ctl }]
set_input_delay -add_delay -clock rgmii_b_rx_clk -min 0.70 [get_ports { rgmii_b_rd* rgmii_b_rx_ctl }]
set_input_delay -add_delay -clock rgmii_b_rx_clk -max 2.00 -clock_fall [get_ports { rgmii_b_rd* rgmii_b_rx_ctl }]
set_input_delay -add_delay -clock rgmii_b_rx_clk -min 0.70 -clock_fall [get_ports { rgmii_b_rd* rgmii_b_rx_ctl }]

# To see implemented RX timing, run from Vivado Tcl Console:
# report_timing -from [get_ports {rgmii_b_rd* rgmii_b_rx_ctl}] -rise_to rgmii_b_rx_clk -delay_type min_max -max_paths 10 -name rgmii_b_rx  -file rgmii_b_rx.txt
