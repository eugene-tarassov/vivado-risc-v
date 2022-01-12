set files [list \
  [file normalize "../../board/${vivado_board_name}/riscv_wrapper.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_10g.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_10g_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_rx.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_tx.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_rx_if.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_tx_if.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_rx_ber_mon.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_rx_frame_sync.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_phy_10g_rx_watchdog.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_xgmii_rx_32.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_xgmii_rx_64.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_xgmii_tx_32.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_xgmii_tx_64.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/xgmii_baser_dec_64.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/xgmii_baser_enc_64.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/sync_reset.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_adapter.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/lfsr.v"] \
  [file normalize "../../ethernet/ethernet.v"] \
]
add_files -norecurse -fileset $source_fileset $files

set files [list \
  [file normalize ../../board/${vivado_board_name}/ethernet.xdc] \
  [file normalize ../../ethernet/verilog-ethernet/lib/axis/syn/vivado/sync_reset.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/lib/axis/syn/vivado/axis_async_fifo.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/syn/vivado/eth_mac_fifo.tcl] \
]
add_files -norecurse -fileset $constraint_fileset $files

create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwizard_ultrascale_0]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X1Y44} \
    CONFIG.TX_MASTER_CHANNEL {X1Y44} \
    CONFIG.RX_MASTER_CHANNEL {X1Y44} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X1Y44 clk1} \
    CONFIG.TX_REFCLK_SOURCE {X1Y44 clk1} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwizard_ultrascale_0]
