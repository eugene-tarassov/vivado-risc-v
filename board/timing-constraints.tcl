#------------------ RocketChip

set main_clock [get_clocks -of_objects [get_pins -hier RocketChip/clock]]
set main_clock_period [get_property -min PERIOD $main_clock]

set_false_path -through [get_pins -hier RocketChip/clock_ok]
set_false_path -through [get_pins -hier RocketChip/mem_ok]
set_false_path -through [get_pins -hier RocketChip/io_ok]
set_false_path -through [get_pins -hier RocketChip/sys_reset]

#------------------ Ethernet adapter

if { [llength [get_pins -quiet -hier Ethernet/clock]] } {
  set eth_clock [get_clocks -of_objects [get_pins -hier Ethernet/clock]]
  set eth_clock_period [get_property -min PERIOD $eth_clock]

  set_max_delay -from $eth_clock -to $main_clock -datapath_only $main_clock_period
  set_max_delay -from $main_clock -to $eth_clock -datapath_only $eth_clock_period

  if { [llength [get_ports -quiet eth_mdio_data]] } {
    set_max_delay -from $eth_clock -to [get_ports {eth_mdio_clock eth_mdio_data eth_mdio_reset}] -datapath_only 40.0
    set_max_delay -from [get_ports eth_mdio_data] -to $eth_clock -datapath_only 40.0
    set_min_delay -from [get_ports eth_mdio_data] -to $eth_clock 0.0
  }

  if { [llength [get_ports -quiet eth_mdio_int]] } {
    set_max_delay -from [get_ports eth_mdio_int] -to $eth_clock -datapath_only 40.0
    set_min_delay -from [get_ports eth_mdio_int] -to $eth_clock 0.0
  }

  if { [llength [get_pins -quiet -hier Ethernet/async_resetn]] } {
    set_max_delay -from $main_clock -through [get_pins -hier Ethernet/async_resetn] -datapath_only 10.0
    set_max_delay -from $eth_clock -through [get_pins -hier Ethernet/interrupt] -datapath_only 10.0
  }
}

#------------------ SD card controller

if { [llength [get_ports -quiet sdio_dat*]] } {
  set sdio_clock [get_clocks -of_objects [get_pins -hier SD/clock]]
  set sdio_clock_period [get_property -min PERIOD $sdio_clock]

  set_max_delay -from $sdio_clock -to $main_clock -datapath_only $main_clock_period
  set_max_delay -from $main_clock -to $sdio_clock -datapath_only $sdio_clock_period

  set_max_delay -from $sdio_clock -to [get_ports {sdio_clk sdio_cmd sdio_dat*}] -datapath_only 8.0
  set_max_delay -from [get_ports {sdio_cmd sdio_dat*}] -to $sdio_clock -datapath_only 8.0
  set_min_delay -from [get_ports {sdio_cmd sdio_dat*}] -to $sdio_clock 0.0

  if { [llength [get_ports -quiet sdio_reset]] } {
    set_max_delay -from $sdio_clock -to [get_ports sdio_reset] -datapath_only 100.0
    set_min_delay -from $sdio_clock -to [get_ports sdio_reset] 0.0
  }
  if { [llength [get_ports -quiet sdio_cd]] } {
    set_max_delay -from [get_ports sdio_cd] -to $sdio_clock -datapath_only 100.0
    set_min_delay -from [get_ports sdio_cd] -to $sdio_clock 0.0
  }
  if { [llength [get_ports -quiet sdio_wp]] } {
    set_max_delay -from [get_ports sdio_wp] -to $sdio_clock -datapath_only 100.0
    set_min_delay -from [get_ports sdio_wp] -to $sdio_clock 0.0
  }

  set_max_delay -from $main_clock -through [get_pins -hier SD/async_resetn] -datapath_only 10.0
  set_max_delay -from $sdio_clock -through [get_pins -hier SD/interrupt] -datapath_only 10.0
}

#------------------ Fan controller

if { [llength [get_pins -quiet -hier FanControl/clock]] } {
  set fan_ctrl_clock [get_clocks -of_objects [get_pins -hier FanControl/clock]]
  set_max_delay -from $fan_ctrl_clock -to [get_ports fan_en] -datapath_only 100.0
  set_max_delay -from $main_clock -through [get_pins -hier FanControl/async_resetn] -datapath_only 10.0
}

#------------------ UART

if { [llength [get_ports -quiet usb_uart_*]] } {
  set uart_clock [get_clocks -of_objects [get_pins -hier UART/clock]]
  set uart_clock_period [get_property -min PERIOD $uart_clock]
  set_max_delay -from $uart_clock -to [get_ports usb_uart_txd] -datapath_only 100.0
  set_max_delay -from [get_ports usb_uart_rxd] -to $uart_clock -datapath_only 100.0
  set_min_delay -from [get_ports usb_uart_rxd] -to $uart_clock 0.0
  set_max_delay -from $main_clock -through [get_pins -hier UART/async_resetn] -datapath_only 100.0
  set_max_delay -from $uart_clock -through [get_pins -hier UART/interrupt] -datapath_only 100.0
  set_max_delay -from $main_clock -to $uart_clock -datapath_only $uart_clock_period
  set_max_delay -from $uart_clock -to $main_clock -datapath_only $main_clock_period
}

if { [llength [get_ports -quiet rs232_uart_*]] } {
  set uart_clock [get_clocks -of_objects [get_pins -hier UART/clock]]
  set uart_clock_period [get_property -min PERIOD $uart_clock]
  set_max_delay -from $uart_clock -to [get_ports {rs232_uart_rtsn rs232_uart_txd}] -datapath_only 100.0
  set_max_delay -from [get_ports {rs232_uart_ctsn rs232_uart_rxd}] -to $uart_clock -datapath_only 100.0
  set_min_delay -from [get_ports {rs232_uart_ctsn rs232_uart_rxd}] -to $uart_clock 0.0
  set_max_delay -from $main_clock -through [get_pins -hier UART/async_resetn] -datapath_only 100.0
  set_max_delay -from $uart_clock -through [get_pins -hier UART/interrupt] -datapath_only 100.0
  set_max_delay -from $main_clock -to $uart_clock -datapath_only $uart_clock_period
  set_max_delay -from $uart_clock -to $main_clock -datapath_only $main_clock_period
}

#------------------ JTAG

set tck_pin ""
if { [llength [get_pins -quiet -hier jtag/TCK]] } {
  # RISC-V Debug Module is connected directly to the FPGA JTAG (aka BSCAN)
  set tck_pin [get_pins -hier jtag/TCK]
} elseif { [llength [get_pins -quiet -hier SERIES7_BSCAN*/TCK]] } {
  # Debug Bridge is used for debugging
  set tck_pin [get_pins -hier SERIES7_BSCAN*/TCK]
}

if { $tck_pin != "" } {
  if { ! [llength [get_clocks -quiet -of_objects $tck_pin]] } {
    create_clock -name jtag_clock -period 15.000 $tck_pin
  }
  set jtag_clock [get_clocks -of_objects $tck_pin]
  set jtag_clock_period [get_property -min PERIOD $jtag_clock]

  set_max_delay -reset_path -from $main_clock -to $jtag_clock -datapath_only $jtag_clock_period
  set_max_delay -reset_path -from $jtag_clock -to $main_clock -datapath_only $main_clock_period
  if { [llength [get_pins -quiet -hier jtag/TDO]] } {
    set_max_delay -from $jtag_clock -to [get_pins -hier jtag/TDO] [expr $jtag_clock_period / 2]
  }
}

#------------------ DDR SDRAM controllers

foreach ddrmc_inst [get_cells -quiet -hier {mig_7series_*}] {
  set_false_path -through [get_pins $ddrmc_inst/sys_rst]
  set ddrc_clock [get_clocks -of_objects [get_pins $ddrmc_inst/ui_clk]]
  set ddrc_clock_period [get_property -min PERIOD $ddrc_clock]
  set_max_delay -from $main_clock -to $ddrc_clock -datapath_only $ddrc_clock_period
  set_max_delay -from $ddrc_clock -to $main_clock -datapath_only $main_clock_period
}

foreach ddrmc_rst_inst [get_cells -quiet -hier -filter {(ORIG_REF_NAME == mem_reset_control || REF_NAME == mem_reset_control)}] {
  set_false_path -through [get_pins $ddrmc_rst_inst/clock_ok]
  set_false_path -through [get_pins $ddrmc_rst_inst/sys_reset]
  set_false_path -through [get_pins $ddrmc_rst_inst/mmcm_locked]
  set_false_path -through [get_pins $ddrmc_rst_inst/calib_complete]
  set_false_path -through [get_pins $ddrmc_rst_inst/ui_clk_sync_rst]
  set_false_path -through [get_pins $ddrmc_rst_inst/aresetn_reg_reg\[0\]/D]
}

foreach ddrmc_inst [get_cells -quiet -hier {ddr4_*}] {
  set_false_path -through [get_pins $ddrmc_inst/sys_rst]
  set_false_path -through [get_pins $ddrmc_inst/c0_init_calib_complete]
  set ddrc_clock [get_clocks -of_objects [get_pins $ddrmc_inst/c0_ddr4_ui_clk]]
  set ddrc_clock_period [get_property -min PERIOD $ddrc_clock]
  set_max_delay -from $main_clock -to $ddrc_clock -datapath_only $ddrc_clock_period
  set_max_delay -from $ddrc_clock -to $main_clock -datapath_only $main_clock_period
}

#------------------ IIC

if { [llength [get_pins -quiet -hier IIC/s_axi_aclk]] } {
  set iic_clock [get_clocks -of_objects [get_pins -hier IIC/s_axi_aclk]]
  set iic_clock_period [get_property -min PERIOD $iic_clock]
  set_max_delay -from $iic_clock -through [get_pins -hier IIC/iic2intc_irpt] -datapath_only 10.0
  set_max_delay -from $iic_clock -to [get_ports {iic_main_scl_io iic_main_sda_io}] -datapath_only 40.0
  set_max_delay -from [get_ports {iic_main_scl_io iic_main_sda_io}] -to $iic_clock -datapath_only 40.0
  set_min_delay -from [get_ports {iic_main_scl_io iic_main_sda_io}] -to $iic_clock 0.0
  set_max_delay -from $main_clock -to $iic_clock -datapath_only $iic_clock_period
  set_max_delay -from $iic_clock -to $main_clock -datapath_only $main_clock_period
}

#------------------ PCIe

if { [llength [get_pins -quiet -hier qdma_0/axi_aclk]] } {
  set pcie_clock [get_clocks -of_objects [get_pins -hier qdma_0/axi_aclk]]
  set pcie_clock_period [get_property -min PERIOD $pcie_clock]
  set_max_delay -from $main_clock -to $pcie_clock -datapath_only $pcie_clock_period
  set_max_delay -from $uart_clock -to $pcie_clock -datapath_only $pcie_clock_period
  set_max_delay -from $iic_clock -to $pcie_clock -datapath_only $pcie_clock_period
  set_max_delay -from $pcie_clock -to $main_clock -datapath_only $main_clock_period
  set_max_delay -from $pcie_clock -to $uart_clock -datapath_only $uart_clock_period
  set_max_delay -from $pcie_clock -to $iic_clock -datapath_only $iic_clock_period
  set_max_delay -from [get_ports pcie_perstn] -to $pcie_clock -datapath_only 40.0
}
