
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
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source riscv_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# rocket, ethernet, sdc_controller, ethernet_nexys_video, synchronizer, synchronizer

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a200tsbg484-1
   set_property BOARD_PART digilentinc.com:nexys_video:part0:1.1 [current_project]
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
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
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
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:mig_7series:4.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_uartlite:2.0\
xilinx.com:ip:xlconcat:2.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
rocket\
ethernet\
sdc_controller\
ethernet_nexys_video\
synchronizer\
synchronizer\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}


##################################################################
# MIG PRJ FILE TCL PROCs
##################################################################

proc write_mig_file_riscv_mig_7series_0_0 { str_mig_prj_filepath } {

   file mkdir [ file dirname "$str_mig_prj_filepath" ]
   set mig_prj_file [open $str_mig_prj_filepath  w+]

   puts $mig_prj_file {﻿<?xml version="1.0" encoding="UTF-8" standalone="no" ?>}
   puts $mig_prj_file {<Project NoOfControllers="1">}
   puts $mig_prj_file {  <!-- IMPORTANT: This is an internal file that has been generated by the MIG software. Any direct editing or changes made to this file may result in unpredictable behavior or data corruption. It is strongly advised that users do not edit the contents of this file. Re-run the MIG GUI with the required settings if any of the options provided below need to be altered. -->}
   puts $mig_prj_file {  <ModuleName>riscv_mig_7series_0_1</ModuleName>}
   puts $mig_prj_file {  <dci_inouts_inputs>1</dci_inouts_inputs>}
   puts $mig_prj_file {  <dci_inputs>1</dci_inputs>}
   puts $mig_prj_file {  <Debug_En>OFF</Debug_En>}
   puts $mig_prj_file {  <DataDepth_En>1024</DataDepth_En>}
   puts $mig_prj_file {  <LowPower_En>ON</LowPower_En>}
   puts $mig_prj_file {  <XADC_En>Enabled</XADC_En>}
   puts $mig_prj_file {  <TargetFPGA>xc7a200t-sbg484/-1</TargetFPGA>}
   puts $mig_prj_file {  <Version>4.2</Version>}
   puts $mig_prj_file {  <SystemClock>No Buffer</SystemClock>}
   puts $mig_prj_file {  <ReferenceClock>Use System Clock</ReferenceClock>}
   puts $mig_prj_file {  <SysResetPolarity>ACTIVE HIGH</SysResetPolarity>}
   puts $mig_prj_file {  <BankSelectionFlag>FALSE</BankSelectionFlag>}
   puts $mig_prj_file {  <InternalVref>1</InternalVref>}
   puts $mig_prj_file {  <dci_hr_inouts_inputs>50 Ohms</dci_hr_inouts_inputs>}
   puts $mig_prj_file {  <dci_cascade>0</dci_cascade>}
   puts $mig_prj_file {  <Controller number="0">}
   puts $mig_prj_file {    <MemoryDevice>DDR3_SDRAM/Components/MT41K256M16XX-125</MemoryDevice>}
   puts $mig_prj_file {    <TimePeriod>2500</TimePeriod>}
   puts $mig_prj_file {    <VccAuxIO>1.8V</VccAuxIO>}
   puts $mig_prj_file {    <PHYRatio>4:1</PHYRatio>}
   puts $mig_prj_file {    <InputClkFreq>200</InputClkFreq>}
   puts $mig_prj_file {    <UIExtraClocks>0</UIExtraClocks>}
   puts $mig_prj_file {    <MMCM_VCO>800</MMCM_VCO>}
   puts $mig_prj_file {    <MMCMClkOut0> 1.000</MMCMClkOut0>}
   puts $mig_prj_file {    <MMCMClkOut1>1</MMCMClkOut1>}
   puts $mig_prj_file {    <MMCMClkOut2>1</MMCMClkOut2>}
   puts $mig_prj_file {    <MMCMClkOut3>1</MMCMClkOut3>}
   puts $mig_prj_file {    <MMCMClkOut4>1</MMCMClkOut4>}
   puts $mig_prj_file {    <DataWidth>16</DataWidth>}
   puts $mig_prj_file {    <DeepMemory>1</DeepMemory>}
   puts $mig_prj_file {    <DataMask>1</DataMask>}
   puts $mig_prj_file {    <ECC>Disabled</ECC>}
   puts $mig_prj_file {    <Ordering>Normal</Ordering>}
   puts $mig_prj_file {    <BankMachineCnt>4</BankMachineCnt>}
   puts $mig_prj_file {    <CustomPart>FALSE</CustomPart>}
   puts $mig_prj_file {    <NewPartName></NewPartName>}
   puts $mig_prj_file {    <RowAddress>15</RowAddress>}
   puts $mig_prj_file {    <ColAddress>10</ColAddress>}
   puts $mig_prj_file {    <BankAddress>3</BankAddress>}
   puts $mig_prj_file {    <MemoryVoltage>1.5V</MemoryVoltage>}
   puts $mig_prj_file {    <C0_MEM_SIZE>536870912</C0_MEM_SIZE>}
   puts $mig_prj_file {    <UserMemoryAddressMap>BANK_ROW_COLUMN</UserMemoryAddressMap>}
   puts $mig_prj_file {    <PinSelection>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M2" SLEW="" VCCAUX_IO="" name="ddr3_addr[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L5" SLEW="" VCCAUX_IO="" name="ddr3_addr[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="N5" SLEW="" VCCAUX_IO="" name="ddr3_addr[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="N4" SLEW="" VCCAUX_IO="" name="ddr3_addr[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="P2" SLEW="" VCCAUX_IO="" name="ddr3_addr[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="P6" SLEW="" VCCAUX_IO="" name="ddr3_addr[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M5" SLEW="" VCCAUX_IO="" name="ddr3_addr[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M3" SLEW="" VCCAUX_IO="" name="ddr3_addr[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M1" SLEW="" VCCAUX_IO="" name="ddr3_addr[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L6" SLEW="" VCCAUX_IO="" name="ddr3_addr[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="P1" SLEW="" VCCAUX_IO="" name="ddr3_addr[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="N3" SLEW="" VCCAUX_IO="" name="ddr3_addr[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="N2" SLEW="" VCCAUX_IO="" name="ddr3_addr[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="M6" SLEW="" VCCAUX_IO="" name="ddr3_addr[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="R1" SLEW="" VCCAUX_IO="" name="ddr3_addr[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L3" SLEW="" VCCAUX_IO="" name="ddr3_ba[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="K6" SLEW="" VCCAUX_IO="" name="ddr3_ba[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L4" SLEW="" VCCAUX_IO="" name="ddr3_ba[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="K3" SLEW="" VCCAUX_IO="" name="ddr3_cas_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="P4" SLEW="" VCCAUX_IO="" name="ddr3_ck_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="P5" SLEW="" VCCAUX_IO="" name="ddr3_ck_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="J6" SLEW="" VCCAUX_IO="" name="ddr3_cke[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="G3" SLEW="" VCCAUX_IO="" name="ddr3_dm[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="F1" SLEW="" VCCAUX_IO="" name="ddr3_dm[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="G2" SLEW="" VCCAUX_IO="" name="ddr3_dq[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="F3" SLEW="" VCCAUX_IO="" name="ddr3_dq[10]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="D2" SLEW="" VCCAUX_IO="" name="ddr3_dq[11]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="C2" SLEW="" VCCAUX_IO="" name="ddr3_dq[12]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="A1" SLEW="" VCCAUX_IO="" name="ddr3_dq[13]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="E2" SLEW="" VCCAUX_IO="" name="ddr3_dq[14]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="B1" SLEW="" VCCAUX_IO="" name="ddr3_dq[15]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H4" SLEW="" VCCAUX_IO="" name="ddr3_dq[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H5" SLEW="" VCCAUX_IO="" name="ddr3_dq[2]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="J1" SLEW="" VCCAUX_IO="" name="ddr3_dq[3]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="K1" SLEW="" VCCAUX_IO="" name="ddr3_dq[4]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H3" SLEW="" VCCAUX_IO="" name="ddr3_dq[5]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="H2" SLEW="" VCCAUX_IO="" name="ddr3_dq[6]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="J5" SLEW="" VCCAUX_IO="" name="ddr3_dq[7]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="E3" SLEW="" VCCAUX_IO="" name="ddr3_dq[8]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="B2" SLEW="" VCCAUX_IO="" name="ddr3_dq[9]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="J2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="D1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_n[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="K2" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="DIFF_SSTL15" PADName="E1" SLEW="" VCCAUX_IO="" name="ddr3_dqs_p[1]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="K4" SLEW="" VCCAUX_IO="" name="ddr3_odt[0]"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="J4" SLEW="" VCCAUX_IO="" name="ddr3_ras_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="LVCMOS15" PADName="G1" SLEW="" VCCAUX_IO="" name="ddr3_reset_n"/>}
   puts $mig_prj_file {      <Pin IN_TERM="" IOSTANDARD="SSTL15" PADName="L1" SLEW="" VCCAUX_IO="" name="ddr3_we_n"/>}
   puts $mig_prj_file {    </PinSelection>}
   puts $mig_prj_file {    <System_Control>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="sys_rst"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="init_calib_complete"/>}
   puts $mig_prj_file {      <Pin Bank="Select Bank" PADName="No connect" name="tg_compare_error"/>}
   puts $mig_prj_file {    </System_Control>}
   puts $mig_prj_file {    <TimingParameters>}
   puts $mig_prj_file {      <Parameters tcke="5" tfaw="40" tras="35" trcd="13.75" trefi="7.8" trfc="260" trp="13.75" trrd="7.5" trtp="7.5" twtr="7.5"/>}
   puts $mig_prj_file {    </TimingParameters>}
   puts $mig_prj_file {    <mrBurstLength name="Burst Length">8 - Fixed</mrBurstLength>}
   puts $mig_prj_file {    <mrBurstType name="Read Burst Type and Length">Sequential</mrBurstType>}
   puts $mig_prj_file {    <mrCasLatency name="CAS Latency">6</mrCasLatency>}
   puts $mig_prj_file {    <mrMode name="Mode">Normal</mrMode>}
   puts $mig_prj_file {    <mrDllReset name="DLL Reset">No</mrDllReset>}
   puts $mig_prj_file {    <mrPdMode name="DLL control for precharge PD">Slow Exit</mrPdMode>}
   puts $mig_prj_file {    <emrDllEnable name="DLL Enable">Enable</emrDllEnable>}
   puts $mig_prj_file {    <emrOutputDriveStrength name="Output Driver Impedance Control">RZQ/7</emrOutputDriveStrength>}
   puts $mig_prj_file {    <emrMirrorSelection name="Address Mirroring">Disable</emrMirrorSelection>}
   puts $mig_prj_file {    <emrCSSelection name="Controller Chip Select Pin">Disable</emrCSSelection>}
   puts $mig_prj_file {    <emrRTT name="RTT (nominal) - On Die Termination (ODT)">RZQ/6</emrRTT>}
   puts $mig_prj_file {    <emrPosted name="Additive Latency (AL)">0</emrPosted>}
   puts $mig_prj_file {    <emrOCD name="Write Leveling Enable">Disabled</emrOCD>}
   puts $mig_prj_file {    <emrDQS name="TDQS enable">Enabled</emrDQS>}
   puts $mig_prj_file {    <emrRDQS name="Qoff">Output Buffer Enabled</emrRDQS>}
   puts $mig_prj_file {    <mr2PartialArraySelfRefresh name="Partial-Array Self Refresh">Full Array</mr2PartialArraySelfRefresh>}
   puts $mig_prj_file {    <mr2CasWriteLatency name="CAS write latency">5</mr2CasWriteLatency>}
   puts $mig_prj_file {    <mr2AutoSelfRefresh name="Auto Self Refresh">Enabled</mr2AutoSelfRefresh>}
   puts $mig_prj_file {    <mr2SelfRefreshTempRange name="High Temparature Self Refresh Rate">Normal</mr2SelfRefreshTempRange>}
   puts $mig_prj_file {    <mr2RTTWR name="RTT_WR - Dynamic On Die Termination (ODT)">Dynamic ODT off</mr2RTTWR>}
   puts $mig_prj_file {    <PortInterface>AXI</PortInterface>}
   puts $mig_prj_file {    <AXIParameters>}
   puts $mig_prj_file {      <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>}
   puts $mig_prj_file {      <C0_S_AXI_ADDR_WIDTH>29</C0_S_AXI_ADDR_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_DATA_WIDTH>128</C0_S_AXI_DATA_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_ID_WIDTH>2</C0_S_AXI_ID_WIDTH>}
   puts $mig_prj_file {      <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>}
   puts $mig_prj_file {    </AXIParameters>}
   puts $mig_prj_file {  </Controller>}
   puts $mig_prj_file {</Project>}

   close $mig_prj_file
}
# End of write_mig_file_riscv_mig_7series_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: IO
proc create_hier_cell_IO { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_IO() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 RGMII

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart


  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir I clock_200MHz
  create_bd_pin -dir O -from 7 -to 0 interrupts
  create_bd_pin -dir O mmcm_locked
  create_bd_pin -dir I sdio_cd
  create_bd_pin -dir O -type clk sdio_clk
  create_bd_pin -dir IO sdio_cmd
  create_bd_pin -dir IO -from 3 -to 0 sdio_dat
  create_bd_pin -dir O -type rst sdio_reset
  create_bd_pin -dir I sys_reset

  # Create instance: Ethernet, and set properties
  set block_name ethernet
  set block_cell_name Ethernet
  if { [catch {set Ethernet [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Ethernet eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.burst_size_bits {4} \
 ] $Ethernet

  # Create instance: SD, and set properties
  set block_name sdc_controller
  set block_cell_name SD
  if { [catch {set SD [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SD eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.sdio_card_detect_level {0} \
 ] $SD

  # Create instance: io_axi_s, and set properties
  set io_axi_s [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 io_axi_s ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $io_axi_s

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.C_BAUDRATE {115200} \
   CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {112.316} \
   CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT2_JITTER {107.523} \
   CONFIG.CLKOUT2_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {107.523} \
   CONFIG.CLKOUT3_PHASE_ERROR {89.971} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT3_REQUESTED_PHASE {90.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT2_PHASE {90.000} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.RESET_PORT {reset} \
   CONFIG.RESET_TYPE {ACTIVE_HIGH} \
 ] $clk_wiz_1

  # Create instance: ethernet_nexys_video_0, and set properties
  set block_name ethernet_nexys_video
  set block_cell_name ethernet_nexys_video_0
  if { [catch {set ethernet_nexys_video_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ethernet_nexys_video_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: io_axi_m, and set properties
  set io_axi_m [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 io_axi_m ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $io_axi_m

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

  # Create instance: synchronizer_0, and set properties
  set block_name synchronizer
  set block_cell_name synchronizer_0
  if { [catch {set synchronizer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $synchronizer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: synchronizer_1, and set properties
  set block_name synchronizer
  set block_cell_name synchronizer_1
  if { [catch {set synchronizer_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $synchronizer_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins RGMII] [get_bd_intf_pins ethernet_nexys_video_0/RGMII]
  connect_bd_intf_net -intf_net Ethernet_TX_AXIS [get_bd_intf_pins Ethernet/TX_AXIS] [get_bd_intf_pins ethernet_nexys_video_0/TX_AXIS]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins Ethernet/M_AXI] [get_bd_intf_pins io_axi_m/S01_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M00_AXI [get_bd_intf_pins SD/S_AXI_LITE] [get_bd_intf_pins io_axi_s/M00_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M01_AXI [get_bd_intf_pins io_axi_s/M01_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
  connect_bd_intf_net -intf_net io_axi_s_M02_AXI [get_bd_intf_pins Ethernet/S_AXI_LITE] [get_bd_intf_pins io_axi_s/M02_AXI]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_pins uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net ethernet_nexys_video_0_RX_AXIS [get_bd_intf_pins Ethernet/RX_AXIS] [get_bd_intf_pins ethernet_nexys_video_0/RX_AXIS]
  connect_bd_intf_net -intf_net io_axi_m [get_bd_intf_pins M00_AXI] [get_bd_intf_pins io_axi_m/M00_AXI]
  connect_bd_intf_net -intf_net sd_axi_m [get_bd_intf_pins SD/M_AXI] [get_bd_intf_pins io_axi_m/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins io_axi_s/S00_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]

  # Create port connections
  connect_bd_net -net Ethernet_interrupt [get_bd_pins Ethernet/interrupt] [get_bd_pins synchronizer_0/dinp]
  connect_bd_net -net Ethernet_reset [get_bd_pins Ethernet/reset] [get_bd_pins ethernet_nexys_video_0/reset]
  connect_bd_net -net SD_interrupt [get_bd_pins SD/interrupt] [get_bd_pins synchronizer_1/dinp]
  connect_bd_net -net SD_sdio_cmd [get_bd_pins sdio_cmd] [get_bd_pins SD/sdio_cmd]
  connect_bd_net -net SD_sdio_dat [get_bd_pins sdio_dat] [get_bd_pins SD/sdio_dat]
  connect_bd_net -net SD_sdio_reset [get_bd_pins sdio_reset] [get_bd_pins SD/sdio_reset]
  connect_bd_net -net axi_uartlite_0_interrupt [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net clk_wiz_1_clk_out3 [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins ethernet_nexys_video_0/clock125_90]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins mmcm_locked] [get_bd_pins clk_wiz_1/locked]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins ACLK] [get_bd_pins io_axi_s/ACLK] [get_bd_pins io_axi_s/M01_ACLK] [get_bd_pins io_axi_s/S00_ACLK] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins io_axi_m/ACLK] [get_bd_pins io_axi_m/M00_ACLK] [get_bd_pins smartconnect_0/aclk] [get_bd_pins synchronizer_0/clock] [get_bd_pins synchronizer_1/clock]
  connect_bd_net -net clock_200MHz [get_bd_pins clock_200MHz] [get_bd_pins clk_wiz_1/clk_in1] [get_bd_pins ethernet_nexys_video_0/clock200]
  connect_bd_net -net eth_ref_clk [get_bd_pins Ethernet/clock] [get_bd_pins io_axi_s/M02_ACLK] [get_bd_pins clk_wiz_1/clk_out2] [get_bd_pins ethernet_nexys_video_0/clock125] [get_bd_pins io_axi_m/S01_ACLK]
  connect_bd_net -net ethernet_0_resetn [get_bd_pins Ethernet/resetn] [get_bd_pins io_axi_s/M02_ARESETN] [get_bd_pins io_axi_m/S01_ARESETN]
  connect_bd_net -net ethernet_nexys_video_0_status_vector [get_bd_pins Ethernet/status_vector] [get_bd_pins ethernet_nexys_video_0/status_vector]
  connect_bd_net -net reset_1 [get_bd_pins sys_reset] [get_bd_pins clk_wiz_1/reset]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_pins ARESETN] [get_bd_pins Ethernet/async_resetn] [get_bd_pins SD/async_resetn] [get_bd_pins io_axi_s/ARESETN] [get_bd_pins io_axi_s/M01_ARESETN] [get_bd_pins io_axi_s/S00_ARESETN] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins io_axi_m/ARESETN] [get_bd_pins io_axi_m/M00_ARESETN] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net sd_ref_clk [get_bd_pins SD/clock] [get_bd_pins io_axi_s/M00_ACLK] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins io_axi_m/S00_ACLK]
  connect_bd_net -net sdc_reset [get_bd_pins SD/resetn] [get_bd_pins io_axi_s/M00_ARESETN] [get_bd_pins io_axi_m/S00_ARESETN]
  connect_bd_net -net sdio_cd [get_bd_pins sdio_cd] [get_bd_pins SD/sdio_cd]
  connect_bd_net -net sdio_clk [get_bd_pins sdio_clk] [get_bd_pins SD/sdio_clk]
  connect_bd_net -net synchronizer_0_dout [get_bd_pins synchronizer_0/dout] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net synchronizer_1_dout [get_bd_pins synchronizer_1/dout] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins interrupts] [get_bd_pins xlconcat_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: DDR
proc create_hier_cell_DDR { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_DDR() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
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
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk clock_200MHz
  create_bd_pin -dir O init_calib_complete
  create_bd_pin -dir I -type rst sys_reset

  # Create instance: axi_smc_1, and set properties
  set axi_smc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_1 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $axi_smc_1

  # Create instance: mig_7series_0, and set properties
  set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0 ]

  # Generate the PRJ File for MIG
  set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
  set str_mig_file_name mig_b.prj
  set str_mig_file_path ${str_mig_folder}/${str_mig_file_name}

  write_mig_file_riscv_mig_7series_0_0 $str_mig_file_path

  set_property -dict [ list \
   CONFIG.BOARD_MIG_PARAM {ddr3_sdram} \
   CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.XML_INPUT_FILE {mig_b.prj} \
 ] $mig_7series_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins ddr3_sdram] [get_bd_intf_pins mig_7series_0/DDR3]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins axi_smc_1/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
  connect_bd_intf_net -intf_net cpu_0_MEM_AXI4 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_smc_1/S00_AXI]

  # Create port connections
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins aclk] [get_bd_pins axi_smc_1/aclk]
  connect_bd_net -net clock_200MHz [get_bd_pins clock_200MHz] [get_bd_pins mig_7series_0/sys_clk_i]
  connect_bd_net -net mig_7series_0_init_calib_complete [get_bd_pins init_calib_complete] [get_bd_pins mig_7series_0/init_calib_complete]
  connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins axi_smc_1/aclk1] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins mig_7series_0/aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net reset_1 [get_bd_pins sys_reset] [get_bd_pins mig_7series_0/sys_rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins axi_smc_1/aresetn] [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]

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
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ddr3_sdram [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3_sdram ]

  set rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii ]

  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]


  # Create ports
  set eth_rst_b [ create_bd_port -dir O eth_rst_b ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set sdio_cd [ create_bd_port -dir I sdio_cd ]
  set sdio_clk [ create_bd_port -dir O sdio_clk ]
  set sdio_cmd [ create_bd_port -dir IO sdio_cmd ]
  set sdio_dat [ create_bd_port -dir IO -from 3 -to 0 sdio_dat ]
  set sdio_reset [ create_bd_port -dir O -type rst sdio_reset ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]

  # Create instance: DDR
  create_hier_cell_DDR [current_bd_instance .] DDR

  # Create instance: IO
  create_hier_cell_IO [current_bd_instance .] IO

  # Create instance: RocketChip, and set properties
  set block_name rocket
  set block_cell_name RocketChip
  if { [catch {set RocketChip [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $RocketChip eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {151.636} \
   CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.0} \
   CONFIG.CLKOUT2_JITTER {114.829} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {125.247} \
   CONFIG.CLKOUT3_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT3_USED {false} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
   CONFIG.CLK_IN2_BOARD_INTERFACE {Custom} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.RESET_BOARD_INTERFACE {Custom} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create interface connections
  connect_bd_intf_net -intf_net DDR_ddr3_sdram [get_bd_intf_ports ddr3_sdram] [get_bd_intf_pins DDR/ddr3_sdram]
  connect_bd_intf_net -intf_net IO_RGMII_0 [get_bd_intf_ports rgmii] [get_bd_intf_pins IO/RGMII]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins IO/S00_AXI] [get_bd_intf_pins RocketChip/IO_AXI4]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins IO/uart]
  connect_bd_intf_net -intf_net cpu_0_MEM_AXI4 [get_bd_intf_pins DDR/S00_AXI] [get_bd_intf_pins RocketChip/MEM_AXI4]
  connect_bd_intf_net -intf_net io_axi_m [get_bd_intf_pins IO/M00_AXI] [get_bd_intf_pins RocketChip/DMA_AXI4]

  # Create port connections
  connect_bd_net -net DDR_init_calib_complete [get_bd_pins DDR/init_calib_complete] [get_bd_pins RocketChip/mem_ok]
  connect_bd_net -net IO_interrupts [get_bd_pins IO/interrupts] [get_bd_pins RocketChip/interrupts]
  connect_bd_net -net IO_mmcm_locked [get_bd_pins IO/mmcm_locked] [get_bd_pins RocketChip/io_ok]
  connect_bd_net -net IO_sdio_cmd [get_bd_ports sdio_cmd] [get_bd_pins IO/sdio_cmd]
  connect_bd_net -net IO_sdio_dat [get_bd_ports sdio_dat] [get_bd_pins IO/sdio_dat]
  connect_bd_net -net IO_sdio_reset [get_bd_ports sdio_reset] [get_bd_pins IO/sdio_reset]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins RocketChip/clock_ok] [get_bd_pins clk_wiz_0/locked]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins DDR/aclk] [get_bd_pins IO/ACLK] [get_bd_pins RocketChip/clock] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net clock_200MHz [get_bd_pins DDR/clock_200MHz] [get_bd_pins IO/clock_200MHz] [get_bd_pins clk_wiz_0/clk_out2]
  connect_bd_net -net reset_1 [get_bd_pins DDR/sys_reset] [get_bd_pins IO/sys_reset] [get_bd_pins RocketChip/sys_reset] [get_bd_pins clk_wiz_0/reset] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net reset_2 [get_bd_ports reset] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_ports eth_rst_b] [get_bd_pins DDR/aresetn] [get_bd_pins IO/ARESETN] [get_bd_pins RocketChip/aresetn]
  connect_bd_net -net sdio_cd [get_bd_ports sdio_cd] [get_bd_pins IO/sdio_cd]
  connect_bd_net -net sdio_clk [get_bd_ports sdio_clk] [get_bd_pins IO/sdio_clk]
  connect_bd_net -net sys_clock [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x60000000 [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/SD/S_AXI_LITE/reg0] SEG_SD_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x60010000 [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x60020000 [get_bd_addr_spaces RocketChip/IO_AXI4] [get_bd_addr_segs IO/Ethernet/S_AXI_LITE/reg0] SEG_ethernet_0_reg0
  create_bd_addr_seg -range 0x20000000 -offset 0x80000000 [get_bd_addr_spaces RocketChip/MEM_AXI4] [get_bd_addr_segs DDR/mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces IO/Ethernet/M_AXI] [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] SEG_RocketChip_reg0
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces IO/SD/M_AXI] [get_bd_addr_segs RocketChip/DMA_AXI4/reg0] SEG_RISCV_reg0


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


