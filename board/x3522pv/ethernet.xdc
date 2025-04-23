# QSFP28 Interfaces
set_property -dict {LOC K4 } [get_ports qsfp0_rx1_p] ;
set_property -dict {LOC K3 } [get_ports qsfp0_rx1_n] ;
set_property -dict {LOC J7 } [get_ports qsfp0_tx1_p] ;
set_property -dict {LOC J6 } [get_ports qsfp0_tx1_n] ;
set_property -dict {LOC P9 } [get_ports qsfp0_mgt_refclk_1_p] ;
set_property -dict {LOC P8 } [get_ports qsfp0_mgt_refclk_1_n] ;

# 161.1328125 MHz MGT reference clock
create_clock -period 6.206 -name qsfp0_mgt_refclk_1 [get_ports qsfp0_mgt_refclk_1_p]
