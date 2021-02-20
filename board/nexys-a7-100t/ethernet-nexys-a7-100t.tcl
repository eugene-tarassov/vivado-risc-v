set files [list \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_mii_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_mii.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_sdr_in.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/mii_phy_if.v"] \
]
add_files -norecurse -fileset $source_fileset $files
