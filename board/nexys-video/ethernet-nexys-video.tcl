set files [list \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_rgmii_fifo.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_rgmii.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/ssio_ddr_in.v"] \
  [file normalize "../../ethernet/rgmii_phy_if.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/iddr.v"] \
  [file normalize "../../ethernet/verilog-ethernet/rtl/oddr.v"] \
]
add_files -norecurse -fileset $source_fileset $files
