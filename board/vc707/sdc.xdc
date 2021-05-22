# SDIO
set_property -dict { PACKAGE_PIN AN30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_clk}]
set_property -dict { PACKAGE_PIN AP30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_cmd}]
set_property -dict { PACKAGE_PIN AR30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[0]}]
set_property -dict { PACKAGE_PIN AU31  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[1]}]
set_property -dict { PACKAGE_PIN AV31  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[2]}]
set_property -dict { PACKAGE_PIN AT30  IOSTANDARD LVCMOS18  IOB TRUE } [get_ports {sdio_dat[3]}]
set_property -dict { PACKAGE_PIN AP32  IOSTANDARD LVCMOS18 } [get_ports {sdio_cd}]
# Note: card detect does not work on VC707 due to error in the VC707 schematics
