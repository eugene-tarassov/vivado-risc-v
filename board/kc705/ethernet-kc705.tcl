set files [list \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_gmii_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_gmii.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_sdr_out.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_sdr_in.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/gmii_phy_if.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/oddr.v"] \
]
add_files -norecurse -fileset $source_fileset $files
