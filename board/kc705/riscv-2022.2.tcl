
################################################################
# This is a generated script based on design: riscv
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source riscv_script.tcl


# The design that will be created by this Tcl script contains the following
# module references:
# $rocket_module_name, mem_reset_control, ethernet, fan_control, sdc_controller, uart, ethernet_kc705

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg900-2
   set_property BOARD_PART xilinx.com:kc705:part0:1.6 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name riscv

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:xadc_wiz:3.3\
xilinx.com:ip:xlconcat:2.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\
$rocket_module_name\
mem_reset_control\
ethernet\
fan_control\
sdc_controller\
ethernet_kc705\
uart\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_riscv_mig_7series_0_0 { str_mig_prj_filepath } {
   global vivado_board_name
   global memory_size

   file mkdir [ file dirname "$str_mig_prj_filepath" ]

   if { $memory_size <= 0x40000000 } {
      set prj_name "DDR3-1Rx64-1GB"
   } elseif { $memory_size <= 0x80000000 } {
      set prj_name "DDR3-1Rx64-2GB"
   } elseif { $memory_size <= 0x100000000 } {
      set prj_name "DDR3-1Rx64-4GB"
   } else {
      set prj_name "DDR3-2Rx64-8GB"
   }

   file copy "../../board/${vivado_board_name}/${prj_name}.prj" "$str_mig_prj_filepath"
}
# End of write_mig_file_riscv_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: IO
proc create_hier_cell_IO { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_IO() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gmii_rtl:1.0 GMII

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart


  # Create pins
  create_bd_pin -dir I -type clk axi_clock
  create_bd_pin -dir I -type rst axi_reset
  create_bd_pin -dir I -type clk clock_100MHz
  create_bd_pin -dir I -type clk clock_125MHz
  create_bd_pin -dir O -from 11 -to 0 device_temp
  create_bd_pin -dir O eth_mdio_clock
  create_bd_pin -dir IO eth_mdio_data
  create_bd_pin -dir I eth_mdio_int
  create_bd_pin -dir O eth_mdio_reset
  create_bd_pin -dir O fan_en
  create_bd_pin -dir O -from 7 -to 0 interrupts
  create_bd_pin -dir I sdio_cd
  create_bd_pin -dir O sdio_clk
  create_bd_pin -dir IO sdio_cmd
  create_bd_pin -dir IO -from 3 -to 0 sdio_dat

  # Create instance: Ethernet, and set properties
  set block_name ethernet
  set block_cell_name Ethernet
  if { [catch {set Ethernet [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Ethernet eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: FanControl, and set properties
  set block_name fan_control
  set block_cell_name FanControl
  if { [catch {set FanControl [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FanControl eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: SD, and set properties
  set block_name sdc_controller
  set block_cell_name SD
  if { [catch {set SD [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SD eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.capabilies_reg {0x0001} \
 ] $SD

  # Create instance: UART, and set properties
  set block_name uart
  set block_cell_name UART
  if { [catch {set UART [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $UART eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: XADC, and set properties
  set XADC [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 XADC ]
  set_property -dict [ list \
   CONFIG.ADC_OFFSET_AND_GAIN_CALIBRATION {true} \
   CONFIG.ADC_OFFSET_CALIBRATION {true} \
   CONFIG.CHANNEL_ENABLE_VBRAM {true} \
   CONFIG.CHANNEL_ENABLE_VCCAUX {true} \
   CONFIG.CHANNEL_ENABLE_VCCINT {true} \
   CONFIG.CHANNEL_ENABLE_VP_VN {true} \
   CONFIG.ENABLE_TEMP_BUS {true} \
   CONFIG.SENSOR_OFFSET_AND_GAIN_CALIBRATION {true} \
   CONFIG.SENSOR_OFFSET_CALIBRATION {true} \
   CONFIG.SEQUENCER_MODE {Continuous} \
   CONFIG.TEMPERATURE_ALARM_RESET {50} \
   CONFIG.TEMPERATURE_ALARM_TRIGGER {60} \
   CONFIG.VCCAUX_ALARM {false} \
   CONFIG.VCCINT_ALARM {false} \
   CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
 ] $XADC

  # Create instance: ethernet_stream_0, and set properties
  set block_name ethernet_kc705
  set block_cell_name ethernet_stream_0
  if { [catch {set ethernet_stream_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ethernet_stream_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: io_axi_m, and set properties
  set io_axi_m [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 io_axi_m ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {3} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $io_axi_m

  # Create instance: io_axi_s, and set properties
  set io_axi_s [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 io_axi_s ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {3} \
   CONFIG.NUM_MI {4} \
   CONFIG.NUM_SI {1} \
 ] $io_axi_s

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net Ethernet_GMII [get_bd_intf_pins GMII] [get_bd_intf_pins ethernet_stream_0/GMII]
  connect_bd_intf_net -intf_net Ethernet_TX_AXIS [get_bd_intf_pins Ethernet/TX_AXIS] [get_bd_intf_pins ethernet_stream_0/TX_AXIS]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins Ethernet/M_AXI] [get_bd_intf_pins io_axi_m/S01_AXI]
  connect_bd_intf_net -intf_net UART_RS232 [get_bd_intf_pins uart] [get_bd_intf_pins UART/RS232]
  connect_bd_intf_net -intf_net ethernet_stream_0_RX_AXIS [get_bd_intf_pins Ethernet/RX_AXIS] [get_bd_intf_pins ethernet_stream_0/RX_AXIS]
  connect_bd_intf_net -intf_net io_axi_m [get_bd_intf_pins M00_AXI] [get_bd_intf_pins io_axi_m/M00_AXI]
  connect_bd_intf_net -intf_net io_axi_s [get_bd_intf_pins S00_AXI] [get_bd_intf_pins io_axi_s/S00_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M00_AXI [get_bd_intf_pins UART/S_AXI_LITE] [get_bd_intf_pins io_axi_s/M00_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M01_AXI [get_bd_intf_pins SD/S_AXI_LITE] [get_bd_intf_pins io_axi_s/M01_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M02_AXI [get_bd_intf_pins Ethernet/S_AXI_LITE] [get_bd_intf_pins io_axi_s/M02_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M03_AXI [get_bd_intf_pins XADC/s_axi_lite] [get_bd_intf_pins io_axi_s/M03_AXI]
  connect_bd_intf_net -intf_net sd_axi_m [get_bd_intf_pins SD/M_AXI] [get_bd_intf_pins io_axi_m/S00_AXI]

  # Create port connections
  connect_bd_net -net AXI_clock [get_bd_pins axi_clock] [get_bd_pins io_axi_m/aclk] [get_bd_pins io_axi_s/aclk]
  connect_bd_net -net AXI_reset [get_bd_pins axi_reset] [get_bd_pins Ethernet/async_resetn] [get_bd_pins FanControl/async_resetn] [get_bd_pins SD/async_resetn] [get_bd_pins UART/async_resetn] [get_bd_pins io_axi_m/aresetn] [get_bd_pins io_axi_s/aresetn]
  connect_bd_net -net Ethernet_interrupt [get_bd_pins Ethernet/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net Ethernet_mdio_clock [get_bd_pins eth_mdio_clock] [get_bd_pins Ethernet/mdio_clock]
  connect_bd_net -net Ethernet_mdio_data [get_bd_pins eth_mdio_data] [get_bd_pins Ethernet/mdio_data]
  connect_bd_net -net Ethernet_mdio_int [get_bd_pins eth_mdio_int] [get_bd_pins Ethernet/mdio_int]
  connect_bd_net -net Ethernet_mdio_reset [get_bd_pins eth_mdio_reset] [get_bd_pins Ethernet/mdio_reset]
  connect_bd_net -net Ethernet_reset [get_bd_pins Ethernet/reset] [get_bd_pins ethernet_stream_0/reset]
  connect_bd_net -net Ethernet_status [get_bd_pins Ethernet/status_vector] [get_bd_pins ethernet_stream_0/status_vector]
  connect_bd_net -net FanControl_resetn [get_bd_pins FanControl/resetn] [get_bd_pins XADC/s_axi_aresetn]
  connect_bd_net -net SD_interrupt [get_bd_pins SD/interrupt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net SD_sdio_cd [get_bd_pins sdio_cd] [get_bd_pins SD/sdio_cd]
  connect_bd_net -net SD_sdio_clk [get_bd_pins sdio_clk] [get_bd_pins SD/sdio_clk]
  connect_bd_net -net SD_sdio_cmd [get_bd_pins sdio_cmd] [get_bd_pins SD/sdio_cmd]
  connect_bd_net -net SD_sdio_dat [get_bd_pins sdio_dat] [get_bd_pins SD/sdio_dat]
  connect_bd_net -net UART_interrupt [get_bd_pins UART/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net clock_100MHz [get_bd_pins clock_100MHz] [get_bd_pins FanControl/clock] [get_bd_pins SD/clock] [get_bd_pins UART/clock] [get_bd_pins XADC/s_axi_aclk] [get_bd_pins io_axi_m/aclk1] [get_bd_pins io_axi_s/aclk1]
  connect_bd_net -net clock_125MHz [get_bd_pins clock_125MHz] [get_bd_pins Ethernet/clock] [get_bd_pins ethernet_stream_0/clock125] [get_bd_pins io_axi_m/aclk2] [get_bd_pins io_axi_s/aclk2]
  connect_bd_net -net device_temp [get_bd_pins device_temp] [get_bd_pins FanControl/device_temp] [get_bd_pins XADC/temp_out]
  connect_bd_net -net fan_pwm [get_bd_pins fan_en] [get_bd_pins FanControl/fan_pwm]
  connect_bd_net -net interrupts [get_bd_pins interrupts] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net temp_alarm [get_bd_pins FanControl/alarm] [get_bd_pins XADC/user_temp_alarm_out]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DDR
proc create_hier_cell_DDR { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DDR() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3_sdram


  # Create pins
  create_bd_pin -dir I -type clk axi_clock
  create_bd_pin -dir I -type rst axi_reset
  create_bd_pin -dir I -type clk clock_200MHz
  create_bd_pin -dir I clock_ok
  create_bd_pin -dir I -from 11 -to 0 device_temp
  create_bd_pin -dir O mem_ok
  create_bd_pin -dir I -type rst sys_reset

  # Create instance: axi_smc_1, and set properties
  set axi_smc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_1 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $axi_smc_1

  # Create instance: mem_reset_control_0, and set properties
  set block_name mem_reset_control
  set block_cell_name mem_reset_control_0
  if { [catch {set mem_reset_control_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mem_reset_control_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_a.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_riscv_mig_7series_0_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {ddr3_sdram} \
   CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_a.prj} \
 ] $mig_7series_0

  # Create interface connections
  connect_bd_intf_net -intf_net MEM_AXI4 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_smc_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins axi_smc_1/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net mig_7series_0_DDR3 [get_bd_intf_pins ddr3_sdram] [get_bd_intf_pins mig_7series_0/DDR3]

  # Create port connections
  connect_bd_net -net AXI_clock [get_bd_pins axi_clock] [get_bd_pins axi_smc_1/aclk]
  connect_bd_net -net AXI_reset [get_bd_pins axi_reset] [get_bd_pins axi_smc_1/aresetn]
  connect_bd_net -net clock_200MHz [get_bd_pins clock_200MHz] [get_bd_pins mem_reset_control_0/clock] [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net clock_ok [get_bd_pins clock_ok] [get_bd_pins mem_reset_control_0/clock_ok]
  connect_bd_net -net device_temp [get_bd_pins device_temp] [get_bd_pins mig_7series_0/device_temp_i]
  connect_bd_net -net mem_aresetn [get_bd_pins mem_reset_control_0/aresetn] [get_bd_pins mig_7series_0/aresetn]
  connect_bd_net -net mem_ui_clk_sync_rst [get_bd_pins mem_reset_control_0/ui_clk_sync_rst] [get_bd_pins mig_7series_0/ui_clk_sync_rst]
  connect_bd_net -net mem_init_calib_complete [get_bd_pins mem_reset_control_0/calib_complete] [get_bd_pins mig_7series_0/init_calib_complete]
  connect_bd_net -net mem_mmcm_locked [get_bd_pins mem_reset_control_0/mmcm_locked] [get_bd_pins mig_7series_0/mmcm_locked]
  connect_bd_net -net mem_ok [get_bd_pins mem_ok] [get_bd_pins mem_reset_control_0/mem_ok]
  connect_bd_net -net mem_reset [get_bd_pins mem_reset_control_0/mem_reset] [get_bd_pins mig_7series_0/sys_rst]
  connect_bd_net -net mem_ui_clk [get_bd_pins mem_reset_control_0/ui_clk] [get_bd_pins axi_smc_1/aclk1] [get_bd_pins mig_7series_0/ui_clk]
  connect_bd_net -net sys_reset [get_bd_pins sys_reset] [get_bd_pins mem_reset_control_0/sys_reset]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr3_sdram [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3_sdram ]

  set gmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gmii_rtl:1.0 gmii ]

  set rs232_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart ]

  set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_diff_clock


  # Create ports
  set LED0 [ create_bd_port -dir O LED0 ]
  set eth_mdio_clock [ create_bd_port -dir O eth_mdio_clock ]
  set eth_mdio_data [ create_bd_port -dir IO eth_mdio_data ]
  set eth_mdio_int [ create_bd_port -dir I eth_mdio_int ]
  set eth_mdio_reset [ create_bd_port -dir O eth_mdio_reset ]
  set fan_en [ create_bd_port -dir O fan_en ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set sdio_cd [ create_bd_port -dir I sdio_cd ]
  set sdio_clk [ create_bd_port -dir O sdio_clk ]
  set sdio_cmd [ create_bd_port -dir IO sdio_cmd ]
  set sdio_dat [ create_bd_port -dir IO -from 3 -to 0 sdio_dat ]

  # Create instance: DDR
  create_hier_cell_DDR [current_bd_instance .] DDR

  # Create instance: IO
  create_hier_cell_IO [current_bd_instance .] IO

  # Create instance: RocketChip, and set properties
  global rocket_module_name
  set RocketChip [create_bd_cell -type module -reference $rocket_module_name RocketChip]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.NUM_OUT_CLKS {4} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.USE_PHASE_ALIGNMENT {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 util_ds_buf_0 ]
  set_property -dict [ list \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {sys_diff_clock} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf_0

  # Create interface connections
  connect_bd_intf_net -intf_net DDR_ddr3_sdram [get_bd_intf_ports ddr3_sdram] [get_bd_intf_pins DDR/ddr3_sdram]
  connect_bd_intf_net -intf_net IO_GMII [get_bd_intf_ports gmii] [get_bd_intf_pins IO/GMII]
  connect_bd_intf_net -intf_net IO_UART [get_bd_intf_ports rs232_uart] [get_bd_intf_pins IO/uart]
  connect_bd_intf_net -intf_net MEM_AXI4 [get_bd_intf_pins DDR/S00_AXI] [get_bd_intf_pins RocketChip/MEM_AXI4]
  connect_bd_intf_net -intf_net io_axi_m [get_bd_intf_pins IO/M00_AXI] [get_bd_intf_pins RocketChip/DMA_AXI4]
  connect_bd_intf_net -intf_net io_axi_s [get_bd_intf_pins IO/S00_AXI] [get_bd_intf_pins RocketChip/IO_AXI4]
  connect_bd_intf_net -intf_net sys_diff_clock [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]

  # Create port connections
  connect_bd_net -net AXI_clock [get_bd_pins DDR/axi_clock] [get_bd_pins IO/axi_clock] [get_bd_pins RocketChip/clock] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net AXI_reset [get_bd_pins DDR/axi_reset] [get_bd_pins IO/axi_reset] [get_bd_pins RocketChip/aresetn]
  connect_bd_net -net IO_eth_mdio_clock [get_bd_ports eth_mdio_clock] [get_bd_pins IO/eth_mdio_clock]
  connect_bd_net -net IO_eth_mdio_data [get_bd_ports eth_mdio_data] [get_bd_pins IO/eth_mdio_data]
  connect_bd_net -net IO_eth_mdio_int [get_bd_ports eth_mdio_int] [get_bd_pins IO/eth_mdio_int]
  connect_bd_net -net IO_eth_mdio_reset [get_bd_ports eth_mdio_reset] [get_bd_pins IO/eth_mdio_reset]
  connect_bd_net -net IO_interrupts [get_bd_pins IO/interrupts] [get_bd_pins RocketChip/interrupts]
  connect_bd_net -net IO_sdio_cd [get_bd_ports sdio_cd] [get_bd_pins IO/sdio_cd]
  connect_bd_net -net IO_sdio_clk [get_bd_ports sdio_clk] [get_bd_pins IO/sdio_clk]
  connect_bd_net -net IO_sdio_cmd [get_bd_ports sdio_cmd] [get_bd_pins IO/sdio_cmd]
  connect_bd_net -net IO_sdio_dat [get_bd_ports sdio_dat] [get_bd_pins IO/sdio_dat]
  connect_bd_net -net clock_100MHz [get_bd_pins IO/clock_100MHz] [get_bd_pins clk_wiz_0/clk_out3]
  connect_bd_net -net clock_125MHz [get_bd_pins IO/clock_125MHz] [get_bd_pins clk_wiz_0/clk_out4]
  connect_bd_net -net clock_200MHz [get_bd_pins DDR/clock_200MHz] [get_bd_pins clk_wiz_0/clk_out2]
  connect_bd_net -net clock_ok [get_bd_pins DDR/clock_ok] [get_bd_pins RocketChip/clock_ok] [get_bd_pins RocketChip/io_ok] [get_bd_pins clk_wiz_0/locked]
  connect_bd_net -net device_temp [get_bd_pins DDR/device_temp] [get_bd_pins IO/device_temp]
  connect_bd_net -net fan_en [get_bd_ports fan_en] [get_bd_pins IO/fan_en]
  connect_bd_net -net mem_ok [get_bd_ports LED0] [get_bd_pins DDR/mem_ok] [get_bd_pins RocketChip/mem_ok]
  connect_bd_net -net reset [get_bd_ports reset] [get_bd_pins DDR/sys_reset] [get_bd_pins RocketChip/sys_reset]
  connect_bd_net -net sys_clock [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins util_ds_buf_0/IBUF_OUT]

  # Create address segments
  assign_bd_address -offset 0x60000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/SD/S_AXI_LITE/reg0] -force
  assign_bd_address -offset 0x60010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/UART/S_AXI_LITE/reg0] -force
  assign_bd_address -offset 0x60020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/Ethernet/S_AXI_LITE/reg0] -force
  assign_bd_address -offset 0x60030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/XADC/s_axi_lite/Reg] -force

  set addr_bits [get_property CONFIG.ADDR_WIDTH [get_bd_intf_pins RocketChip/DMA_AXI4]]
  set_property CONFIG.dma_addr_bits $addr_bits [get_bd_cells IO/Ethernet]
  set_property CONFIG.dma_addr_bits $addr_bits [get_bd_cells IO/SD]

  set addr_range [expr 1 << $addr_bits]
  assign_bd_address -offset 0x00000000 -range $addr_range -target_address_space [get_bd_addr_spaces RocketChip/MEM_AXI4] [get_bd_addr_segs DDR/mig_7series_0/memmap/memaddr] -force
  assign_bd_address -offset 0x00000000 -range $addr_range -target_address_space [get_bd_addr_spaces IO/Ethernet/M_AXI] [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] -force
  assign_bd_address -offset 0x00000000 -range $addr_range -target_address_space [get_bd_addr_spaces IO/SD/M_AXI] [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] -force

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""
