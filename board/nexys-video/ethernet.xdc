#-----------------------------------------------------------
#              Ethernet / RGMII                            -
#-----------------------------------------------------------

#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS25 } [get_ports { eth_pme_b }]; #IO_L6P_T0_13 Sch=eth_pme_b
set_property -dict { PACKAGE_PIN AA16  IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_clock }]; #IO_L1N_T0_13 Sch=eth_mdc
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_data }]; #IO_L1P_T0_13 Sch=eth_mdio
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS25 } [get_ports { eth_mdio_int }]; #IO_L6N_T0_VREF_13 Sch=eth_int_b
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 16 } [get_ports { eth_mdio_reset }]; #IO_25_34 Sch=eth_mdio_reset
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS25 } [get_ports { rgmii_rxc }]; #IO_L13P_T2_MRCC_13 Sch=eth_rxck
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS25 } [get_ports { rgmii_rx_ctl }]; #IO_L10N_T1_13 Sch=eth_rxctl
set_property -dict { PACKAGE_PIN AB16  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rd[0] }]; #IO_L2P_T0_13 Sch=eth_rxd[0]
set_property -dict { PACKAGE_PIN AA15  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rd[1] }]; #IO_L4P_T0_13 Sch=eth_rxd[1]
set_property -dict { PACKAGE_PIN AB15  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rd[2] }]; #IO_L4N_T0_13 Sch=eth_rxd[2]
set_property -dict { PACKAGE_PIN AB11  IOSTANDARD LVCMOS25 } [get_ports { rgmii_rd[3] }]; #IO_L7P_T1_13 Sch=eth_rxd[3]
set_property -dict { PACKAGE_PIN AA14  IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_txc }]; #IO_L5N_T0_13 Sch=eth_txck
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_tx_ctl }]; #IO_L10P_T1_13 Sch=eth_txctl
set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_td[0] }]; #IO_L11N_T1_SRCC_13 Sch=eth_txd[0]
set_property -dict { PACKAGE_PIN W12   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_td[1] }]; #IO_L12N_T1_MRCC_13 Sch=eth_txd[1]
set_property -dict { PACKAGE_PIN W11   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_td[2] }]; #IO_L12P_T1_MRCC_13 Sch=eth_txd[2]
set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16 } [get_ports { rgmii_td[3] }]; #IO_L11P_T1_SRCC_13 Sch=eth_txd[3]

create_clock -period 8.000 -name rgmii_rx_clk [get_ports rgmii_rxc]

# Nexys Video board uses RTL8211E-VB phy, TXDLY off, RXDLY off, 2.5V signaling, HR bank (ODELAY not available).
# Note: max (setup) is measured from prev clock edge, min (hold) - from current clock edge.
# Data valid period, relative to the current clock edge, is [max-4.0ns .. min].
# With RXDLY off, the center of data valid period is in the middle between clock edges.
# Changing of the constraints require changes of IDELAY_VALUE in ethernet-nesys-video.v.
set_input_delay -add_delay -clock rgmii_rx_clk -max 4.60 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min 3.40 [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -max 4.60 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]
set_input_delay -add_delay -clock rgmii_rx_clk -min 3.40 -clock_fall [get_ports { rgmii_rd* rgmii_rx_ctl }]

# To see implemented RX timing, run from Vivado Tcl Console:
# report_timing -from [get_ports {rgmii_rd* rgmii_rx_ctl}] -rise_to rgmii_rx_clk -delay_type min_max -max_paths 10 -name rgmii_rx  -file rgmii_rx.txt
