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
# Note: max (setup) is measured from prev clock edge, min (hold) - from current clock edge
# Data valid period, relative to current edge, is max-4.0ns .. min
set_input_delay -add_delay -clock rgmii_rx_clk -max  2.80 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min  1.30 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -max  2.80 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min  1.30 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]

#report_timing -rise_from [get_ports {rgmii_rd* rgmii_rx_ctl}] -delay_type min_max -max_paths 100 -name rgmii_rx_rise  -file rgmii_rx_rise.txt
#report_timing -fall_from [get_ports {rgmii_rd* rgmii_rx_ctl}] -delay_type min_max -max_paths 100 -name rgmii_rx_fall  -file rgmii_rx_fall.txt

#create_generated_clock -name rgmii_tx_clk -source [get_pins -hier clk_wiz_1/clk_out2] -divide_by 1 [get_ports rgmii_txc]
#set_output_delay -add_delay -clock rgmii_tx_clk -max  1.40 [get_ports { rgmii_td* rgmii_tx_ctl }]
#set_output_delay -add_delay -clock rgmii_tx_clk -min -1.40 [get_ports { rgmii_td* rgmii_tx_ctl }]
#set_output_delay -add_delay -clock rgmii_tx_clk -max  1.40 -clock_fall [get_ports { rgmii_td* rgmii_tx_ctl }]
#set_output_delay -add_delay -clock rgmii_tx_clk -min -1.40 -clock_fall [get_ports { rgmii_td* rgmii_tx_ctl }]

#report_timing -rise_from [get_ports {rgmii_td* rgmii_tx_ctl}] -delay_type min_max -max_paths 100 -name rgmii_tx_rise  -file rgmii_tx_rise.txt
#report_timing -fall_from [get_ports {rgmii_td* rgmii_tx_ctl}] -delay_type min_max -max_paths 100 -name rgmii_tx_fall  -file rgmii_tx_fall.txt
