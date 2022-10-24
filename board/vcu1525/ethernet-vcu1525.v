/*

Copyright (c) 2021-2022 Eugene Tarassov
Copyright (c) 2014-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

module ethernet_vcu1525 #(
    // Timestamping configuration (port)
    parameter PTP_TS_ENABLE = 0,
    parameter TX_PTP_TS_FIFO_DEPTH = 32,
    parameter RX_PTP_TS_FIFO_DEPTH = 32

) (

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
    input wire clock,

    input wire clock_ok,

    output wire eth_gt_user_clock,

    output wire [15:0] eth0_status,

    /* ETH0 AXIS */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TDATA" *)
    input wire [63:0] eth0_tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TKEEP" *)
    input wire [7:0] eth0_tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TVALID" *)
    input wire eth0_tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TREADY" *)
    output wire eth0_tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TLAST" *)
    input wire eth0_tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TUSER" *)
    input wire eth0_tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TDATA" *)
    output wire [63:0] eth0_rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TKEEP" *)
    output wire [7:0] eth0_rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TVALID" *)
    output wire eth0_rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TREADY" *)
    input wire eth0_rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TLAST" *)
    output wire eth0_rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TUSER" *)
    output wire eth0_rx_axis_tuser,

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

// PTP configuration
localparam PTP_TS_WIDTH = 96;
localparam PTP_TAG_WIDTH = 16;
localparam PTP_PERIOD_NS_WIDTH = 4;
localparam PTP_OFFSET_NS_WIDTH = 32;
localparam PTP_FNS_WIDTH = 32;
localparam PTP_PERIOD_NS = 4'd4;
localparam PTP_PERIOD_FNS = 32'd0;
localparam PTP_USE_SAMPLE_CLOCK = 0;
localparam IF_PTP_PERIOD_NS = 6'h6;
localparam IF_PTP_PERIOD_FNS = 16'h6666;

// Interface configuration (port)
localparam ENABLE_PADDING = 1;
localparam ENABLE_DIC = 1;
localparam MIN_FRAME_LENGTH = 64;
localparam TX_FIFO_DEPTH = 4096;
localparam RX_FIFO_DEPTH = 4096;

// Ethernet interface configuration
localparam XGMII_DATA_WIDTH = 64;
localparam XGMII_CTRL_WIDTH = XGMII_DATA_WIDTH/8;
localparam AXIS_ETH_DATA_WIDTH = XGMII_DATA_WIDTH;
localparam AXIS_ETH_KEEP_WIDTH = AXIS_ETH_DATA_WIDTH/8;
localparam AXIS_ETH_SYNC_DATA_WIDTH = AXIS_ETH_DATA_WIDTH;
localparam AXIS_ETH_TX_USER_WIDTH = (PTP_TS_ENABLE ? PTP_TAG_WIDTH : 0) + 1;
localparam AXIS_ETH_RX_USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1;
localparam AXIS_ETH_STATUS_WIDTH = 16;

// Internal 125 MHz clock
wire clk_125mhz_int = clock;
reg rst_125mhz_int = 1;
reg [9:0] reset_timer_reg = 0;
wire rst_refclk_int;

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~clock_ok),
    .out(rst_refclk_int)
);

always @(posedge clk_125mhz_int) begin
    if (rst_refclk_int) begin reset_timer_reg <= 0; rst_125mhz_int <= 1; end
    else if (&reset_timer_reg) rst_125mhz_int <= 0;
    else reset_timer_reg <= reset_timer_reg + 1;
end


// XGMII 10G PHY
assign qsfp0_modsell = 1'b0;
assign qsfp0_resetl = 1'b1;
assign qsfp0_lpmode = 1'b0;
assign qsfp0_refclk_reset = rst_refclk_int;
assign qsfp0_fs = 2'b10;

wire                         rx_rst;
wire [XGMII_DATA_WIDTH-1:0]  qsfp0_txd_1;
wire [XGMII_CTRL_WIDTH-1:0]  qsfp0_txc_1;
wire [XGMII_DATA_WIDTH-1:0]  qsfp0_rxd_1;
wire [XGMII_CTRL_WIDTH-1:0]  qsfp0_rxc_1;
wire [6:0]                   qsfp0_rx_error_count_1;

wire qsfp0_rx_block_lock_1;

wire qsfp_gtpowergood;

wire qsfp0_mgt_refclk_1;

wire sfp_gt_txclkout;

// Internal 156.25 MHz clock
wire tx_clk;
wire tx_rst;

wire sfp_gt_rxclkout;
wire rx_clk;

wire gt_reset_tx_done;
wire gt_reset_rx_done;

wire gt_txprgdivresetdone;
wire gt_txpmaresetdone;
wire gt_rxprgdivresetdone;
wire gt_rxpmaresetdone;

wire gt_tx_reset = ~((&gt_txprgdivresetdone) & (&gt_txpmaresetdone));
wire gt_rx_reset = ~&gt_rxpmaresetdone;

reg gt_userclk_tx_active = 1'b0;
reg gt_userclk_rx_active = 1'b0;

IBUFDS_GTE4 ibufds_gte4_qsfp0_mgt_refclk_1_inst (
    .I             (qsfp0_mgt_refclk_1_p),
    .IB            (qsfp0_mgt_refclk_1_n),
    .CEB           (1'b0),
    .O             (qsfp0_mgt_refclk_1),
    .ODIV2         ()
);

BUFG_GT bufg_gt_tx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (gt_tx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (sfp_gt_txclkout),
    .O       (tx_clk)
);

always @(posedge tx_clk, posedge gt_tx_reset) begin
    if (gt_tx_reset) begin
        gt_userclk_tx_active <= 1'b0;
    end else begin
        gt_userclk_tx_active <= 1'b1;
    end
end

BUFG_GT bufg_gt_rx_usrclk_inst (
    .CE      (1'b1),
    .CEMASK  (1'b0),
    .CLR     (gt_rx_reset),
    .CLRMASK (1'b0),
    .DIV     (3'd0),
    .I       (sfp_gt_rxclkout),
    .O       (rx_clk)
);

always @(posedge rx_clk, posedge gt_rx_reset) begin
    if (gt_rx_reset) begin
        gt_userclk_rx_active <= 1'b0;
    end else begin
        gt_userclk_rx_active <= 1'b1;
    end
end

sync_reset #(
    .N(4)
)
sync_reset_156mhz_inst (
    .clk(tx_clk),
    .rst(~gt_reset_tx_done),
    .out(tx_rst)
);

wire [5:0] qsfp0_gt_txheader_1;
wire [63:0] qsfp0_gt_txdata_1;
wire qsfp0_gt_rxgearboxslip_1;
wire [5:0] qsfp0_gt_rxheader_1;
wire [1:0] qsfp0_gt_rxheadervalid_1;
wire [63:0] qsfp0_gt_rxdata_1;
wire [1:0] qsfp0_gt_rxdatavalid_1;

assign qsfp0_gt_txheader_1[5:2] = 0;

gtwizard_ultrascale_0
qsfp0_gt1_inst (
    .gtwiz_userclk_tx_active_in(gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(rst_125mhz_int),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(1'b0),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(gt_reset_rx_done),

    .gtrefclk00_in(qsfp0_mgt_refclk_1),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in(qsfp0_rx1_n),
    .gtyrxp_in(qsfp0_rx1_p),

    .rxusrclk_in(rx_clk),
    .rxusrclk2_in(rx_clk),

    .gtwiz_userdata_tx_in(qsfp0_gt_txdata_1),
    .txheader_in(qsfp0_gt_txheader_1),
    .txsequence_in(1'b0),

    .txusrclk_in(tx_clk),
    .txusrclk2_in(tx_clk),

    .gtpowergood_out(qsfp_gtpowergood),

    .gtytxn_out(qsfp0_tx1_n),
    .gtytxp_out(qsfp0_tx1_p),

    .rxgearboxslip_in(qsfp0_gt_rxgearboxslip_1),
    .gtwiz_userdata_rx_out(qsfp0_gt_rxdata_1),
    .rxdatavalid_out(qsfp0_gt_rxdatavalid_1),
    .rxheader_out(qsfp0_gt_rxheader_1),
    .rxheadervalid_out(qsfp0_gt_rxheadervalid_1),
    .rxoutclk_out(sfp_gt_rxclkout),
    .rxpmaresetdone_out(gt_rxpmaresetdone),
    .rxprgdivresetdone_out(gt_rxprgdivresetdone),
    .rxstartofseq_out(),

    .txoutclk_out(sfp_gt_txclkout),
    .txpmaresetdone_out(gt_txpmaresetdone),
    .txprgdivresetdone_out(gt_txprgdivresetdone)
);

sync_reset #(
    .N(4)
)
qsfp0_rx_rst_1_reset_sync_inst (
    .clk(rx_clk),
    .rst(~gt_reset_rx_done),
    .out(rx_rst)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
qsfp0_phy_1_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .xgmii_txd(qsfp0_txd_1),
    .xgmii_txc(qsfp0_txc_1),
    .xgmii_rxd(qsfp0_rxd_1),
    .xgmii_rxc(qsfp0_rxc_1),
    .serdes_tx_data(qsfp0_gt_txdata_1),
    .serdes_tx_hdr(qsfp0_gt_txheader_1[1:0]),
    .serdes_rx_data(qsfp0_gt_rxdata_1),
    .serdes_rx_hdr(qsfp0_gt_rxheader_1[1:0]),
    .serdes_rx_bitslip(qsfp0_gt_rxgearboxslip_1),
    .rx_error_count(qsfp0_rx_error_count_1),
    .rx_block_lock(qsfp0_rx_block_lock_1),
    .rx_high_ber(),
    .tx_prbs31_enable(0),
    .rx_prbs31_enable(0)
);

assign eth_gt_user_clock = tx_clk;

eth_mac_10g_fifo #(
    .DATA_WIDTH(AXIS_ETH_DATA_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_PERIOD_NS(IF_PTP_PERIOD_NS),
    .PTP_PERIOD_FNS(IF_PTP_PERIOD_FNS),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .PTP_TAG_WIDTH(PTP_TAG_WIDTH),
    .TX_PTP_TS_ENABLE(PTP_TS_ENABLE),
    .TX_PTP_TAG_ENABLE(PTP_TS_ENABLE),
    .RX_PTP_TS_ENABLE(PTP_TS_ENABLE),
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .RX_FRAME_FIFO(1)
)
eth_mac_10g_fifo_inst (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .logic_clk(tx_clk),
    .logic_rst(tx_rst),

    .tx_axis_tdata(eth0_tx_axis_tdata),
    .tx_axis_tkeep(eth0_tx_axis_tkeep),
    .tx_axis_tuser(eth0_tx_axis_tuser),
    .tx_axis_tvalid(eth0_tx_axis_tvalid),
    .tx_axis_tready(eth0_tx_axis_tready),
    .tx_axis_tlast(eth0_tx_axis_tlast),

    .rx_axis_tdata(eth0_rx_axis_tdata),
    .rx_axis_tkeep(eth0_rx_axis_tkeep),
    .rx_axis_tuser(eth0_rx_axis_tuser),
    .rx_axis_tvalid(eth0_rx_axis_tvalid),
    .rx_axis_tready(eth0_rx_axis_tready),
    .rx_axis_tlast(eth0_rx_axis_tlast),

    .xgmii_rxd(qsfp0_rxd_1),
    .xgmii_rxc(qsfp0_rxc_1),
    .xgmii_txd(qsfp0_txd_1),
    .xgmii_txc(qsfp0_txc_1),

    .tx_fifo_overflow(eth0_status[0]),
    .tx_fifo_bad_frame(eth0_status[1]),
    .tx_fifo_good_frame(eth0_status[2]),
    .tx_error_underflow(eth0_status[3]),
    .rx_error_bad_frame(eth0_status[4]),
    .rx_error_bad_fcs(eth0_status[5]),
    .rx_fifo_overflow(eth0_status[6]),
    .rx_fifo_bad_frame(eth0_status[7]),
    .rx_fifo_good_frame(eth0_status[8]),

    .ifg_delay(8'd12)
);

endmodule
