/*

Copyright (c) 2021-2024 Eugene Tarassov
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

module ethernet_sfp_10g #(
    // Timestamping
    parameter PTP_TS_ENABLE = 0
) (

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000" *)
    input wire clock,

    input wire clock_ok,

    output wire eth_gt_user_clock,

    output wire [15:0] eth_status,

    /* ETH0 AXIS */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TDATA" *)
    input wire [63:0] eth_tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TKEEP" *)
    input wire [7:0] eth_tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TVALID" *)
    input wire eth_tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TREADY" *)
    output wire eth_tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TLAST" *)
    input wire eth_tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_TX_AXIS TUSER" *)
    input wire eth_tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TDATA" *)
    output wire [63:0] eth_rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TKEEP" *)
    output wire [7:0] eth_rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TVALID" *)
    output wire eth_rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TREADY" *)
    input wire eth_rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TLAST" *)
    output wire eth_rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ETH0_RX_AXIS TUSER" *)
    output wire eth_rx_axis_tuser,

    /* SFP */
    output wire         sfp_tx_p,
    output wire         sfp_tx_n,
    input  wire         sfp_rx_p,
    input  wire         sfp_rx_n,
    input  wire         sfp_mgt_refclk_p,
    input  wire         sfp_mgt_refclk_n,
    output wire         sfp_modsel,
    output wire         sfp_reset,
    input  wire         sfp_modprs,
    input  wire         sfp_int,
    output wire         sfp_lpmode,
    output wire         sfp_refclk_reset,
    output wire [1:0]   sfp_fs

);

// Interface configuration (port)
localparam ENABLE_PADDING = 1;
localparam ENABLE_DIC = 1;
localparam MIN_FRAME_LENGTH = 64;
localparam TX_FIFO_DEPTH = 4096;
localparam RX_FIFO_DEPTH = 16384;

// Ethernet interface configuration
localparam XGMII_DATA_WIDTH = 64;
localparam XGMII_CTRL_WIDTH = XGMII_DATA_WIDTH/8;

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
assign sfp_modsel = 1'b0;
assign sfp_reset = 1'b1;
assign sfp_lpmode = 1'b0;
assign sfp_refclk_reset = rst_refclk_int;
assign sfp_fs = 2'b10;

wire                         rx_rst;
wire [XGMII_DATA_WIDTH-1:0]  sfp_txd;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_txc;
wire [XGMII_DATA_WIDTH-1:0]  sfp_rxd;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_rxc;
wire [6:0]                   sfp_rx_error_count;

wire sfp_rx_block_lock;

wire qsfp_gtpowergood;

wire sfp_mgt_refclk;

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

IBUFDS_GTE4 ibufds_gte4_sfp_mgt_refclk_inst (
    .I             (sfp_mgt_refclk_p),
    .IB            (sfp_mgt_refclk_n),
    .CEB           (1'b0),
    .O             (sfp_mgt_refclk),
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

wire [5:0] sfp_gt_txheader;
wire [63:0] sfp_gt_txdata;
wire sfp_gt_rxgearboxslip;
wire [5:0] sfp_gt_rxheader;
wire [1:0] sfp_gt_rxheadervalid;
wire [63:0] sfp_gt_rxdata;
wire [1:0] sfp_gt_rxdatavalid;
wire sfp_rx_reset_req;

assign sfp_gt_txheader[5:2] = 0;

gtwizard_ultrascale_0
sfp_gt1_inst (
    .gtwiz_userclk_tx_active_in(gt_userclk_tx_active),
    .gtwiz_userclk_rx_active_in(gt_userclk_rx_active),

    .gtwiz_reset_clk_freerun_in(clk_125mhz_int),
    .gtwiz_reset_all_in(rst_125mhz_int),

    .gtwiz_reset_tx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_tx_datapath_in(1'b0),

    .gtwiz_reset_rx_pll_and_datapath_in(1'b0),
    .gtwiz_reset_rx_datapath_in(sfp_rx_reset_req),

    .gtwiz_reset_rx_cdr_stable_out(),

    .gtwiz_reset_tx_done_out(gt_reset_tx_done),
    .gtwiz_reset_rx_done_out(gt_reset_rx_done),

    .gtrefclk00_in(sfp_mgt_refclk),

    .qpll0outclk_out(),
    .qpll0outrefclk_out(),

    .gtyrxn_in(sfp_rx_n),
    .gtyrxp_in(sfp_rx_p),

    .rxusrclk_in(rx_clk),
    .rxusrclk2_in(rx_clk),

    .gtwiz_userdata_tx_in(sfp_gt_txdata),
    .txheader_in(sfp_gt_txheader),
    .txsequence_in(1'b0),

    .txusrclk_in(tx_clk),
    .txusrclk2_in(tx_clk),

    .gtpowergood_out(qsfp_gtpowergood),

    .gtytxn_out(sfp_tx_n),
    .gtytxp_out(sfp_tx_p),

    .rxgearboxslip_in(sfp_gt_rxgearboxslip),
    .gtwiz_userdata_rx_out(sfp_gt_rxdata),
    .rxdatavalid_out(sfp_gt_rxdatavalid),
    .rxheader_out(sfp_gt_rxheader),
    .rxheadervalid_out(sfp_gt_rxheadervalid),
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
sfp_rx_rst_reset_sync_inst (
    .clk(rx_clk),
    .rst(~gt_reset_rx_done),
    .out(rx_rst)
);

eth_phy_10g #(
    .BIT_REVERSE(1)
)
sfp_phy_inst (
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),

    /* XGMII interface */
    .xgmii_txd(sfp_txd),
    .xgmii_txc(sfp_txc),
    .xgmii_rxd(sfp_rxd),
    .xgmii_rxc(sfp_rxc),

    /* SERDES interface */
    .serdes_tx_data(sfp_gt_txdata),
    .serdes_tx_hdr(sfp_gt_txheader[1:0]),
    .serdes_rx_data(sfp_gt_rxdata),
    .serdes_rx_hdr(sfp_gt_rxheader[1:0]),
    .serdes_rx_bitslip(sfp_gt_rxgearboxslip),
    .serdes_rx_reset_req(sfp_rx_reset_req),

    /* Status */
    .tx_bad_block(),
    .rx_error_count(sfp_rx_error_count),
    .rx_bad_block(),
    .rx_sequence_error(),
    .rx_block_lock(sfp_rx_block_lock),
    .rx_high_ber(),
    .rx_status(),

    /* Configuration */
    .cfg_tx_prbs31_enable(0),
    .cfg_rx_prbs31_enable(0)
);

assign eth_gt_user_clock = tx_clk;

eth_mac_10g_fifo #(
    .DATA_WIDTH(XGMII_DATA_WIDTH),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH)
)
eth_mac_10g_fifo_inst (
    .rx_clk(rx_clk),
    .rx_rst(rx_rst),
    .tx_clk(tx_clk),
    .tx_rst(tx_rst),
    .logic_clk(tx_clk),
    .logic_rst(tx_rst),

    .tx_axis_tdata(eth_tx_axis_tdata),
    .tx_axis_tkeep(eth_tx_axis_tkeep),
    .tx_axis_tuser(eth_tx_axis_tuser),
    .tx_axis_tvalid(eth_tx_axis_tvalid),
    .tx_axis_tready(eth_tx_axis_tready),
    .tx_axis_tlast(eth_tx_axis_tlast),

    .rx_axis_tdata(eth_rx_axis_tdata),
    .rx_axis_tkeep(eth_rx_axis_tkeep),
    .rx_axis_tuser(eth_rx_axis_tuser),
    .rx_axis_tvalid(eth_rx_axis_tvalid),
    .rx_axis_tready(eth_rx_axis_tready),
    .rx_axis_tlast(eth_rx_axis_tlast),

    .xgmii_rxd(sfp_rxd),
    .xgmii_rxc(sfp_rxc),
    .xgmii_txd(sfp_txd),
    .xgmii_txc(sfp_txc),

    .tx_fifo_overflow(eth_status[0]),
    .tx_fifo_bad_frame(eth_status[1]),
    .tx_fifo_good_frame(eth_status[2]),
    .tx_error_underflow(eth_status[3]),
    .rx_error_bad_frame(eth_status[4]),
    .rx_error_bad_fcs(eth_status[5]),
    .rx_fifo_overflow(eth_status[6]),
    .rx_fifo_bad_frame(eth_status[7]),
    .rx_fifo_good_frame(eth_status[8]),

    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1)
);

endmodule
