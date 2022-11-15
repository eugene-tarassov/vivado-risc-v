module ethernet_nexys_a7_100t (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock50 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset, FREQ_HZ 50000000" *)
    input wire clock50,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    input wire [7:0] tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TKEEP" *)
    input wire [0:0] tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TVALID" *)
    input wire tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TREADY" *)
    output wire tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TLAST" *)
    input wire tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TUSER" *)
    input wire tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TDATA" *)
    output wire [7:0] rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TKEEP" *)
    output wire [0:0] rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TVALID" *)
    output wire rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TREADY" *)
    input wire rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TLAST" *)
    output wire rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TUSER" *)
    output wire rx_axis_tuser,

    output wire [15:0] status_vector,

    (* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 RMII CRS_DV" *)
    input wire rmii_crs_dv, // Carrier sence, Receive data valid (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 RMII RX_ER" *)
    input wire rmii_rx_er, // Receive error (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 RMII RXD" *)
    input wire [1:0] rmii_rxd, // Receive data (required)
    (* IOB = "TRUE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 RMII TX_EN" *)
    output reg rmii_tx_en, // Transmit enable (required)
    (* IOB = "TRUE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rmii:1.0 RMII TXD" *)
    output reg [1:0] rmii_txd // Transmit data (required)
);

`default_nettype none

assign status_vector = 0;

reg mii_rx_clock;
reg mii_tx_clock;
reg mii_rx_idle;

reg  [3:0]  mii_rxd;
reg         mii_rx_dv;
reg         mii_rx_er;
wire [3:0]  mii_txd;
wire        mii_tx_en;
wire        mii_tx_er;

wire [7:0]  tx_fifo_axis_tdata;
wire        tx_fifo_axis_tvalid;
wire        tx_fifo_axis_tready;
wire        tx_fifo_axis_tlast;
wire        tx_fifo_axis_tuser;

wire [7:0]  rx_fifo_axis_tdata;
wire        rx_fifo_axis_tvalid;
wire        rx_fifo_axis_tlast;
wire        rx_fifo_axis_tuser;

reg [1:0] reg_txd;
reg reg_tx_en;

always @(negedge clock50) begin
    rmii_tx_en <= reg_tx_en;
    rmii_txd <= reg_txd;
end

always @(posedge clock50) begin
    if (reset) begin
        mii_rx_clock <= 0;
        mii_tx_clock <= 0;
        mii_rx_idle <= 1;
        mii_rx_dv <= 0;
        mii_rx_er <= 0;
        mii_rxd <= 0;
        reg_tx_en <= 0;
        reg_txd <= 0;
    end else begin
        mii_rx_clock <= !mii_rx_clock;
        mii_tx_clock <= !mii_tx_clock;
        if (mii_tx_clock) begin
            reg_tx_en <= mii_tx_en;
            reg_txd <= mii_txd[1:0];
        end else begin
            reg_txd <= mii_txd[3:2];
        end
        if (!rmii_crs_dv && mii_rx_clock) begin
            mii_rx_idle <= 1;
            mii_rx_dv <= 0;
            mii_rxd <= 0;
        end else if (mii_rx_idle) begin
            if (rmii_rxd != 0 && rmii_crs_dv) begin
                mii_rxd[1:0] <= rmii_rxd;
                mii_rx_clock <= 1;
                mii_rx_idle <= 0;
            end
        end else if (mii_rx_clock) begin
            mii_rxd[3:2] <= rmii_rxd;
            mii_rx_er <= rmii_rx_er;
            mii_rx_dv <= 1;
        end else begin
            mii_rxd[1:0] <= rmii_rxd;
        end
    end
end

eth_mac_1g #(
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(64)
)
eth_mac_inst (
    .tx_clk(clock50),
    .tx_rst(reset),
    .rx_clk(clock50),
    .rx_rst(reset),
    .tx_axis_tdata(tx_fifo_axis_tdata),
    .tx_axis_tvalid(tx_fifo_axis_tvalid),
    .tx_axis_tready(tx_fifo_axis_tready),
    .tx_axis_tlast(tx_fifo_axis_tlast),
    .tx_axis_tuser(tx_fifo_axis_tuser),
    .rx_axis_tdata(rx_fifo_axis_tdata),
    .rx_axis_tvalid(rx_fifo_axis_tvalid),
    .rx_axis_tlast(rx_fifo_axis_tlast),
    .rx_axis_tuser(rx_fifo_axis_tuser),
    .gmii_rxd(mii_rxd),
    .gmii_rx_dv(mii_rx_dv),
    .gmii_rx_er(mii_rx_er),
    .gmii_txd(mii_txd),
    .gmii_tx_en(mii_tx_en),
    .gmii_tx_er(mii_tx_er),
    .rx_clk_enable(!mii_rx_clock),
    .tx_clk_enable(!mii_tx_clock),
    .rx_mii_select(1'b1),
    .tx_mii_select(1'b1),
    .tx_start_packet(),
    .tx_error_underflow(),
    .rx_start_packet(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .ifg_delay(12)
);

axis_async_fifo_adapter #(
    .DEPTH(4096),
    .S_DATA_WIDTH(8),
    .S_KEEP_ENABLE(0),
    .M_DATA_WIDTH(8),
    .M_KEEP_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(1),
    .FRAME_FIFO(1),
    .USER_BAD_FRAME_VALUE(1'b1),
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_BAD_FRAME(0),
    .DROP_WHEN_FULL(1)
)
tx_fifo (
    // AXI input
    .s_clk(clock50),
    .s_rst(reset),
    .s_axis_tdata(tx_axis_tdata),
    .s_axis_tkeep(tx_axis_tkeep),
    .s_axis_tvalid(tx_axis_tvalid),
    .s_axis_tready(tx_axis_tready),
    .s_axis_tlast(tx_axis_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(tx_axis_tuser),
    // AXI output
    .m_clk(clock50),
    .m_rst(reset),
    .m_axis_tdata(tx_fifo_axis_tdata),
    .m_axis_tkeep(),
    .m_axis_tvalid(tx_fifo_axis_tvalid),
    .m_axis_tready(tx_fifo_axis_tready),
    .m_axis_tlast(tx_fifo_axis_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(tx_fifo_axis_tuser),
    // Status
    .s_status_overflow(),
    .s_status_bad_frame(),
    .s_status_good_frame(),
    .m_status_overflow(),
    .m_status_bad_frame(),
    .m_status_good_frame()
);

axis_async_fifo_adapter #(
    .DEPTH(4096),
    .S_DATA_WIDTH(8),
    .S_KEEP_ENABLE(0),
    .M_DATA_WIDTH(8),
    .M_KEEP_ENABLE(0),
    .ID_ENABLE(0),
    .DEST_ENABLE(0),
    .USER_ENABLE(1),
    .USER_WIDTH(1),
    .FRAME_FIFO(1),
    .USER_BAD_FRAME_VALUE(1'b1),
    .USER_BAD_FRAME_MASK(1'b1),
    .DROP_BAD_FRAME(0),
    .DROP_WHEN_FULL(1)
)
rx_fifo (
    // AXI input
    .s_clk(clock50),
    .s_rst(reset),
    .s_axis_tdata(rx_fifo_axis_tdata),
    .s_axis_tkeep(0),
    .s_axis_tvalid(rx_fifo_axis_tvalid),
    .s_axis_tready(),
    .s_axis_tlast(rx_fifo_axis_tlast),
    .s_axis_tid(0),
    .s_axis_tdest(0),
    .s_axis_tuser(rx_fifo_axis_tuser),
    // AXI output
    .m_clk(clock50),
    .m_rst(reset),
    .m_axis_tdata(rx_axis_tdata),
    .m_axis_tkeep(rx_axis_tkeep),
    .m_axis_tvalid(rx_axis_tvalid),
    .m_axis_tready(rx_axis_tready),
    .m_axis_tlast(rx_axis_tlast),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(rx_axis_tuser),
    // Status
    .s_status_overflow(),
    .s_status_bad_frame(),
    .s_status_good_frame(),
    .m_status_overflow(),
    .m_status_bad_frame(),
    .m_status_good_frame()
);

endmodule
