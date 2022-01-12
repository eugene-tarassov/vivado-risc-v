module riscv_wrapper (
    input wire clk_user_clk_n,
    input wire clk_user_clk_p,

    /* DDR4 */
    output wire ddr4_sdram_c0_act_n,
    output wire [16:0]ddr4_sdram_c0_adr,
    output wire [1:0]ddr4_sdram_c0_ba,
    output wire [1:0]ddr4_sdram_c0_bg,
    output wire ddr4_sdram_c0_ck_c,
    output wire ddr4_sdram_c0_ck_t,
    output wire ddr4_sdram_c0_cke,
    output wire ddr4_sdram_c0_cs_n,
    inout  wire [71:0]ddr4_sdram_c0_dq,
    inout  wire [17:0]ddr4_sdram_c0_dqs_c,
    inout  wire [17:0]ddr4_sdram_c0_dqs_t,
    output wire ddr4_sdram_c0_odt,
    output wire ddr4_sdram_c0_par,
    output wire ddr4_sdram_c0_reset_n,
    input  wire default_300mhz_clk0_clk_n,
    input  wire default_300mhz_clk0_clk_p,

    /* IIC */
    inout  wire iic_main_scl_io,
    inout  wire iic_main_sda_io,

    /* PCIe */
    input  wire [7:0]pci_express_x16_rxn,
    input  wire [7:0]pci_express_x16_rxp,
    output wire [7:0]pci_express_x16_txn,
    output wire [7:0]pci_express_x16_txp,
    input  wire pcie_perstn,
    input  wire pcie_refclk_clk_n,
    input  wire pcie_refclk_clk_p,
    input  wire resetn,

    /* UART */
    input  wire usb_uart_rxd,
    output wire usb_uart_txd,

    /* QSFP28 #0 */
    output wire         qsfp0_tx1_p,
    output wire         qsfp0_tx1_n,
    input  wire         qsfp0_rx1_p,
    input  wire         qsfp0_rx1_n,
    input  wire         qsfp0_mgt_refclk_1_p,
    input  wire         qsfp0_mgt_refclk_1_n,
    output wire         qsfp0_modsell,
    output wire         qsfp0_resetl,
    input  wire         qsfp0_modprsl,
    input  wire         qsfp0_intl,
    output wire         qsfp0_lpmode,
    output wire         qsfp0_refclk_reset,
    output wire [1:0]   qsfp0_fs
    );

wire iic_main_scl_i;
wire iic_main_scl_o;
wire iic_main_scl_t;

IOBUF iic_main_scl_iobuf (
    .I(iic_main_scl_o),
    .IO(iic_main_scl_io),
    .O(iic_main_scl_i),
    .T(iic_main_scl_t));

wire iic_main_sda_i;
wire iic_main_sda_o;
wire iic_main_sda_t;

IOBUF iic_main_sda_iobuf (
    .I(iic_main_sda_o),
    .IO(iic_main_sda_io),
    .O(iic_main_sda_i),
    .T(iic_main_sda_t));

// Ethernet phy initialization reset and clock
wire eth_clock_ok;
wire eth_clock;

// Ethernet GT user clock
wire eth_gt_user_clock;

wire [63:0 ]eth_rx_axis_tdata;
wire [7:0] eth_rx_axis_tkeep;
wire eth_rx_axis_tlast;
wire eth_rx_axis_tready;
wire eth_rx_axis_tuser;
wire eth_rx_axis_tvalid;
wire [15:0] eth_status;
wire [63:0] eth_tx_axis_tdata;
wire [7:0] eth_tx_axis_tkeep;
wire eth_tx_axis_tlast;
wire eth_tx_axis_tready;
wire eth_tx_axis_tuser;
wire eth_tx_axis_tvalid;

riscv riscv_i (
    .clk_user_clk_n(clk_user_clk_n),
    .clk_user_clk_p(clk_user_clk_p),
    .ddr4_sdram_c0_act_n(ddr4_sdram_c0_act_n),
    .ddr4_sdram_c0_adr(ddr4_sdram_c0_adr),
    .ddr4_sdram_c0_ba(ddr4_sdram_c0_ba),
    .ddr4_sdram_c0_bg(ddr4_sdram_c0_bg),
    .ddr4_sdram_c0_ck_c(ddr4_sdram_c0_ck_c),
    .ddr4_sdram_c0_ck_t(ddr4_sdram_c0_ck_t),
    .ddr4_sdram_c0_cke(ddr4_sdram_c0_cke),
    .ddr4_sdram_c0_cs_n(ddr4_sdram_c0_cs_n),
    .ddr4_sdram_c0_dq(ddr4_sdram_c0_dq),
    .ddr4_sdram_c0_dqs_c(ddr4_sdram_c0_dqs_c),
    .ddr4_sdram_c0_dqs_t(ddr4_sdram_c0_dqs_t),
    .ddr4_sdram_c0_odt(ddr4_sdram_c0_odt),
    .ddr4_sdram_c0_par(ddr4_sdram_c0_par),
    .ddr4_sdram_c0_reset_n(ddr4_sdram_c0_reset_n),
    .default_300mhz_clk0_clk_n(default_300mhz_clk0_clk_n),
    .default_300mhz_clk0_clk_p(default_300mhz_clk0_clk_p),
    .eth_clock_ok(eth_clock_ok),
    .eth_clock(eth_clock),
    .eth_gt_user_clock(eth_gt_user_clock),
    .eth_rx_axis_tdata(eth_rx_axis_tdata),
    .eth_rx_axis_tkeep(eth_rx_axis_tkeep),
    .eth_rx_axis_tlast(eth_rx_axis_tlast),
    .eth_rx_axis_tready(eth_rx_axis_tready),
    .eth_rx_axis_tuser(eth_rx_axis_tuser),
    .eth_rx_axis_tvalid(eth_rx_axis_tvalid),
    .eth_status(eth_status),
    .eth_tx_axis_tdata(eth_tx_axis_tdata),
    .eth_tx_axis_tkeep(eth_tx_axis_tkeep),
    .eth_tx_axis_tlast(eth_tx_axis_tlast),
    .eth_tx_axis_tready(eth_tx_axis_tready),
    .eth_tx_axis_tuser(eth_tx_axis_tuser),
    .eth_tx_axis_tvalid(eth_tx_axis_tvalid),
    .iic_main_scl_i(iic_main_scl_i),
    .iic_main_scl_o(iic_main_scl_o),
    .iic_main_scl_t(iic_main_scl_t),
    .iic_main_sda_i(iic_main_sda_i),
    .iic_main_sda_o(iic_main_sda_o),
    .iic_main_sda_t(iic_main_sda_t),
    .pci_express_x16_rxn(pci_express_x16_rxn),
    .pci_express_x16_rxp(pci_express_x16_rxp),
    .pci_express_x16_txn(pci_express_x16_txn),
    .pci_express_x16_txp(pci_express_x16_txp),
    .pcie_perstn(pcie_perstn),
    .pcie_refclk_clk_n(pcie_refclk_clk_n),
    .pcie_refclk_clk_p(pcie_refclk_clk_p),
    .resetn(resetn),
    .usb_uart_rxd(usb_uart_rxd),
    .usb_uart_txd(usb_uart_txd));

ethernet_u250 ethernet_u250_i (
    .clock_ok(eth_clock_ok),
    .clock(eth_clock),

    .eth_gt_user_clock(eth_gt_user_clock),

    /* Ethernet #0 AXI Stream */
    .eth0_rx_axis_tdata(eth_rx_axis_tdata),
    .eth0_rx_axis_tkeep(eth_rx_axis_tkeep),
    .eth0_rx_axis_tlast(eth_rx_axis_tlast),
    .eth0_rx_axis_tready(eth_rx_axis_tready),
    .eth0_rx_axis_tuser(eth_rx_axis_tuser),
    .eth0_rx_axis_tvalid(eth_rx_axis_tvalid),
    .eth0_status(eth_status),
    .eth0_tx_axis_tdata(eth_tx_axis_tdata),
    .eth0_tx_axis_tkeep(eth_tx_axis_tkeep),
    .eth0_tx_axis_tlast(eth_tx_axis_tlast),
    .eth0_tx_axis_tready(eth_tx_axis_tready),
    .eth0_tx_axis_tuser(eth_tx_axis_tuser),
    .eth0_tx_axis_tvalid(eth_tx_axis_tvalid),

    /* QSFP28 #0 */
    .qsfp0_tx1_p(qsfp0_tx1_p),
    .qsfp0_tx1_n(qsfp0_tx1_n),
    .qsfp0_rx1_p(qsfp0_rx1_p),
    .qsfp0_rx1_n(qsfp0_rx1_n),
    .qsfp0_mgt_refclk_1_p(qsfp0_mgt_refclk_1_p),
    .qsfp0_mgt_refclk_1_n(qsfp0_mgt_refclk_1_n),
    .qsfp0_modsell(qsfp0_modsell),
    .qsfp0_resetl(qsfp0_resetl),
    .qsfp0_modprsl(qsfp0_modprsl),
    .qsfp0_intl(qsfp0_intl),
    .qsfp0_lpmode(qsfp0_lpmode),
    .qsfp0_refclk_reset(qsfp0_refclk_reset),
    .qsfp0_fs(qsfp0_fs)

);

endmodule
