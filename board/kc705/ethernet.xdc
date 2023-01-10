#-----------------------------------------------------------
#              Ethernet / GMII                            -
#-----------------------------------------------------------

set_property -dict { PACKAGE_PIN R23   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_clock }];
set_property -dict { PACKAGE_PIN J21   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_data }];
set_property -dict { PACKAGE_PIN N30   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_int }];
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_reset }];

set_property -dict { PACKAGE_PIN R30   IOSTANDARD LVCMOS25 } [get_ports { gmii_crs }];
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS25 } [get_ports { gmii_col }];
set_property -dict { PACKAGE_PIN U27   IOSTANDARD LVCMOS25 } [get_ports { gmii_rx_clk }];
set_property -dict { PACKAGE_PIN V26   IOSTANDARD LVCMOS25 } [get_ports { gmii_rx_er }];
set_property -dict { PACKAGE_PIN R28   IOSTANDARD LVCMOS25 } [get_ports { gmii_rx_dv }];
set_property -dict { PACKAGE_PIN U30   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[0] }];
set_property -dict { PACKAGE_PIN U25   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[1] }];
set_property -dict { PACKAGE_PIN T25   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[2] }];
set_property -dict { PACKAGE_PIN U28   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[3] }];
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[4] }];
set_property -dict { PACKAGE_PIN T27   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[5] }];
set_property -dict { PACKAGE_PIN T26   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[6] }];
set_property -dict { PACKAGE_PIN T28   IOSTANDARD LVCMOS25 } [get_ports { gmii_rxd[7] }];
set_property -dict { PACKAGE_PIN M28   IOSTANDARD LVCMOS25 } [get_ports { gmii_tx_clk }];
set_property -dict { PACKAGE_PIN K30   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_gtx_clk }];
set_property -dict { PACKAGE_PIN N29   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_tx_er }];
set_property -dict { PACKAGE_PIN M27   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_tx_en }];
set_property -dict { PACKAGE_PIN N27   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[0] }];
set_property -dict { PACKAGE_PIN N25   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[1] }];
set_property -dict { PACKAGE_PIN M29   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[2] }];
set_property -dict { PACKAGE_PIN L28   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[3] }];
set_property -dict { PACKAGE_PIN J26   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[4] }];
set_property -dict { PACKAGE_PIN K26   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[5] }];
set_property -dict { PACKAGE_PIN L30   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[6] }];
set_property -dict { PACKAGE_PIN J28   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { gmii_txd[7] }];

set gmii_rx_clk [create_clock -period 8.000 -name gmii_rx_clk [get_ports gmii_rx_clk]]
set gmii_tx_clk [create_clock -period 40.000 -name gmii_tx_clk [get_ports gmii_tx_clk]]

set eth_clock [get_clocks -of_objects [get_pins -hier Ethernet/clock]]
set eth_clock_period [get_property -min PERIOD $eth_clock]
set rx_clock_period [get_property -min PERIOD $gmii_rx_clk]
set tx_clock_period [get_property -min PERIOD $gmii_tx_clk]

set_max_delay -from $eth_clock -to $gmii_tx_clk -datapath_only $tx_clock_period
set_max_delay -from $gmii_tx_clk -to $eth_clock -datapath_only $eth_clock_period

set_max_delay -from $eth_clock -to $gmii_rx_clk -datapath_only $rx_clock_period
set_max_delay -from $gmii_rx_clk -to $eth_clock -datapath_only $eth_clock_period

# KC705 board uses Marvell Alaska 88E1111 PHY, 2.5V signaling

# To see implemented RX timing, run from Vivado Tcl Console:
# report_timing -from [get_ports {gmii_rxd* gmii_rx_er gmii_rx_dv}] -rise_to gmii_rx_clk -delay_type min_max -max_paths 10 -name gmii_rx  -file gmii_rx.txt
