# SDIO
set_property -dict { PACKAGE_PIN V22 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_clk }];
set_property -dict { PACKAGE_PIN W24 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_cmd }];
set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[0] }];
set_property -dict { PACKAGE_PIN V21 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[1] }];
set_property -dict { PACKAGE_PIN W21 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[2] }];
set_property -dict { PACKAGE_PIN W23 IOSTANDARD LVCMOS33 IOB TRUE } [get_ports { sdio_dat[3] }];

# CD is connected to DATA3
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports { sdio_cd }];
