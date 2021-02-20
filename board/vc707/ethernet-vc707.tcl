set files [list \
  [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g_fifo.v"] \
]
add_files -norecurse -fileset $source_fileset $files
