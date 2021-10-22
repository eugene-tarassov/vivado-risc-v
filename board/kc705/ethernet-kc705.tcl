set files [list \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_gmii_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_gmii.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_sdr_out.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_sdr_in.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/gmii_phy_if.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/oddr.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_adapter.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_gmii_rx.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/axis_gmii_tx.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/lfsr.v"] \
  [file normalize "../../ethernet/ethernet.v"] \
]
add_files -norecurse -fileset $source_fileset $files

set files [list \
  [file normalize ../../board/${vivado_board_name}/ethernet.xdc] \
  [file normalize ../../ethernet/verilog-ethernet/lib/axis/syn/vivado/sync_reset.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/lib/axis/syn/vivado/axis_async_fifo.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/syn/vivado/eth_mac_fifo.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/syn/vivado/eth_mac_1g_gmii.tcl] \
  [file normalize ../../ethernet/verilog-ethernet/syn/vivado/gmii_phy_if.tcl] \
]
add_files -norecurse -fileset $constraint_fileset $files
