# SDIO
set_property -dict { PACKAGE_PIN AB23  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_clk }];
set_property -dict { PACKAGE_PIN AB22  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_cmd }];
set_property -dict { PACKAGE_PIN AC20  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_dat[0] }];
set_property -dict { PACKAGE_PIN AA23  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_dat[1] }];
set_property -dict { PACKAGE_PIN AA22  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_dat[2] }];
set_property -dict { PACKAGE_PIN AC21  IOSTANDARD LVCMOS25 IOB TRUE } [get_ports { sdio_dat[3] }];
set_property -dict { PACKAGE_PIN AA21  IOSTANDARD LVCMOS25 } [get_ports { sdio_cd }];
#set_property -dict { PACKAGE_PIN Y21   IOSTANDARD LVCMOS25 } [get_ports { sdio_wp }];
# Note: card detect does not work on KC705 due to error in the KC705 schematics
