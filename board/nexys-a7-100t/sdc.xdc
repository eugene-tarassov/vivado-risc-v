# SDIO
set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_clk }];
set_property -dict { PACKAGE_PIN C1  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_cmd }];
set_property -dict { PACKAGE_PIN C2  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[0] }];
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[1] }];
set_property -dict { PACKAGE_PIN F1  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[2] }];
set_property -dict { PACKAGE_PIN D2  IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[3] }];
set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports { sdio_reset }];
set_property -dict { PACKAGE_PIN A1  IOSTANDARD LVCMOS33 } [get_ports { sdio_cd }];
