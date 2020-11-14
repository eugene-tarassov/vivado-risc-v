# If there is no project opened, create a project
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project ${vivado_board_name}-riscv vivado-${vivado_board_name}-riscv -part ${xilinx_part}
   set_property BOARD_PART ${vivado_board_part} [current_project]
}

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set source_fileset [get_filesets sources_1]
set files [list \
 [file normalize "rocket.vhdl"] \
 [file normalize "srams.v"] \
 [file normalize "system-${vivado_board_name}.v"] \
 [file normalize "../../uart/uart.v"] \
 [file normalize "../../sdc/sd_defines.h"] \
 [file normalize "../../sdc/axi_sd_fifo.v"] \
 [file normalize "../../sdc/axi_sd_fifo_filler.v"] \
 [file normalize "../../sdc/axi_sdc_controller.v"] \
 [file normalize "../../sdc/sd_cmd_master.v"] \
 [file normalize "../../sdc/sd_cmd_serial_host.v"] \
 [file normalize "../../sdc/sd_data_master.v"] \
 [file normalize "../../sdc/sd_data_serial_host.v"] \
 [file normalize "../../sdc/sd_data_xfer_trig.v"] \
 [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_adapter.v"] \
 [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo.v"] \
 [file normalize "../../ethernet/verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v"] \
 [file normalize "../../ethernet/verilog-ethernet/rtl/axis_gmii_rx.v"] \
 [file normalize "../../ethernet/verilog-ethernet/rtl/axis_gmii_tx.v"] \
 [file normalize "../../ethernet/verilog-ethernet/rtl/eth_mac_1g.v"] \
 [file normalize "../../ethernet/verilog-ethernet/rtl/lfsr.v"] \
 [file normalize "../../ethernet/ethernet.v"] \
 [file normalize "../../vhdl-wrapper/src/net/largest/riscv/vhdl/bscan2jtag.vhdl"] \
 [file normalize "../../board/${vivado_board_name}/ethernet-${vivado_board_name}.v"] \
]
add_files -norecurse -fileset $source_fileset $files

source ../../board/${vivado_board_name}/ethernet-${vivado_board_name}.tcl

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set constraint_fileset [get_filesets constrs_1]
# Note: top.xdc must be first - other files depend on clocks defined in top.xdc
set files [list \
 [file normalize ../../board/${vivado_board_name}/top.xdc] \
 [file normalize ../../board/${vivado_board_name}/sdc.xdc] \
 [file normalize ../../board/${vivado_board_name}/uart.xdc] \
 [file normalize ../../board/${vivado_board_name}/ethernet.xdc] \
 [file normalize ../../board/timing-constraints.tcl] \
]
add_files -norecurse -fileset $constraint_fileset $files

# Set file properties

set file_obj [get_files -of_objects $source_fileset [list "*/*.vhdl"]]
set_property -name "file_type" -value "VHDL" -objects $file_obj

set file_obj [get_files -of_objects $constraint_fileset [list "*/*.xdc"]]
set_property -name "file_type" -value "XDC" -objects $file_obj
set_property -name "used_in" -value "implementation" -objects $file_obj
set_property -name "used_in_synthesis" -value "0" -objects $file_obj

set file_obj [get_files -of_objects $constraint_fileset [list "*/*.tcl"]]
set_property -name "file_type" -value "TCL" -objects $file_obj
set_property -name "used_in" -value "implementation" -objects $file_obj
set_property -name "used_in_synthesis" -value "0" -objects $file_obj

# Create block design
set current_vivado_version [version -short]
source ../../board/${vivado_board_name}/riscv-${current_vivado_version}.tcl

if { [llength [get_bd_intf_pins -quiet RocketChip/JTAG]] == 1 } {
  create_bd_cell -type module -reference bscan2jtag JTAG
  connect_bd_intf_net -intf_net JTAG [get_bd_intf_pins JTAG/JTAG] [get_bd_intf_pins RocketChip/JTAG]
  create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 BSCAN
  set_property -dict [list CONFIG.C_DEBUG_MODE {7} CONFIG.C_USER_SCAN_CHAIN {1} CONFIG.C_NUM_BS_MASTER {1}] [get_bd_cells BSCAN]
  connect_bd_intf_net -intf_net BSCAN [get_bd_intf_pins BSCAN/m0_bscan] [get_bd_intf_pins JTAG/S_BSCAN]
}

set_property CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $riscv_clock_frequency [get_bd_cells clk_wiz_0]
validate_bd_design

regenerate_bd_layout
save_bd_design

make_wrapper -files [get_files riscv.bd] -top
add_files -norecurse [file normalize vivado-${vivado_board_name}-riscv/${vivado_board_name}-riscv.srcs/sources_1/bd/riscv/hdl/riscv_wrapper.v ]
set_property top riscv_wrapper $source_fileset
update_compile_order -fileset $source_fileset

