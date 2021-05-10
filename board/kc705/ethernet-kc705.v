module ethernet_kc705 (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset, FREQ_HZ 125000000" *)
    input wire clock125,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock200 CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
    input wire clock200,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    input wire [7:0] tx_axis_tdata,
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
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TVALID" *)
    output wire rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TREADY" *)
    input wire rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TLAST" *)
    output wire rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TUSER" *)
    output wire rx_axis_tuser,

    output wire [15:0] status_vector,


    // GMII - Gigabit Media Independent Interface
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TXD" *)
    output [7:0] gmii_txd, // Ethernet transmit data. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_EN" *)
    output gmii_tx_en, // Ethernet transmit enable. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_ER" *)
    output gmii_tx_er, // Ethernet transmit error. (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RXD" *)
    input [7:0] gmii_rxd, // Ethernet receive data.  (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_DV" *)
    input gmii_rx_dv, // Ethernet receive data valid. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_ER" *)
    input gmii_rx_er, // Ethernet receive error. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII CRS" *)
    input gmii_crs, // Ethernet carrier sense. (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII COL" *)
    input gmii_col, // Ethernet collision. (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_CLK" *)
    input gmii_tx_clk, // Ethernet transmit clock for 10/100Mb/s Ethernet speeds (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII GTX_CLK" *)
    output gmii_gtx_clk, // Ethernet transmit clock for 1Gb/s Ethernet (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_CLK" *)
    input gmii_rx_clk // Ethernet receive clock (optional)
);

// KC705 board uses Marvell Alaska 88E1111 PHY

// 0.078 ns increment
`define gmii_clock_odelay 23
`define gmii_clock_idelay 0
`define gmii_data_idelay  25

assign status_vector = 0;

wire gmii_rx_clk_delay;
wire [7:0] gmii_rxd_delay;
wire gmii_rx_er_delay;
wire gmii_rx_dc_delay;

eth_mac_1g_gmii_fifo #(
    .TARGET("XILINX"),
    .IODDR_STYLE("IODDR"),
    .CLOCK_INPUT_STYLE("BUFR"),
    .ENABLE_PADDING(1),
    .AXIS_DATA_WIDTH(8),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_DEPTH(4096),
    .TX_FRAME_FIFO(1),
    .RX_FIFO_DEPTH(4096),
    .RX_FRAME_FIFO(1),
    .RX_DROP_BAD_FRAME(0),
    .RX_DROP_WHEN_FULL(1)
)
eth_mac_inst (
    .gtx_clk(clock125),
    .gtx_rst(reset),
    .logic_clk(clock125),
    .logic_rst(reset),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .gmii_rx_clk(gmii_rx_clk_delay),
    .gmii_rxd(gmii_rxd_delay),
    .gmii_rx_dv(gmii_rx_dv_delay),
    .gmii_rx_er(gmii_rx_er_delay),
    .gmii_tx_clk(gmii_gtx_clk),
    .mii_tx_clk(gmii_tx_clk),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),

    .tx_fifo_overflow(),
    .tx_fifo_bad_frame(),
    .tx_fifo_good_frame(),
    .rx_error_bad_frame(),
    .rx_error_bad_fcs(),
    .rx_fifo_overflow(),
    .rx_fifo_bad_frame(),
    .rx_fifo_good_frame(),

    .ifg_delay(12)
);

(* IODELAY_GROUP = "gmii_idelay_group" *)
IDELAYCTRL gmii_idelay_control_block (
    .REFCLK(clock200),
    .RST(reset),
    .RDY()
);

(* IODELAY_GROUP = "gmii_idelay_group" *)
IDELAYE2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(`gmii_clock_idelay),
    .SIGNAL_PATTERN("CLOCK")
)
gmii_idelay_clk (
    .IDATAIN(gmii_rx_clk),
    .DATAOUT(gmii_rx_clk_delay),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

genvar n;
generate for (n = 0; n < 8; n = n + 1) begin
    (* IODELAY_GROUP = "gmii_idelay_group" *)
    IDELAYE2 #(
        .IDELAY_TYPE("FIXED"),
        .IDELAY_VALUE(`gmii_data_idelay),
        .SIGNAL_PATTERN("DATA")
    )
    gmii_idelay_rxd (
        .IDATAIN(gmii_rxd[n]),
        .DATAOUT(gmii_rxd_delay[n]),
        .DATAIN(1'b0),
        .C(1'b0),
        .CE(1'b0),
        .INC(1'b0),
        .CINVCTRL(1'b0),
        .CNTVALUEIN(5'd0),
        .CNTVALUEOUT(),
        .LD(1'b0),
        .LDPIPEEN(1'b0),
        .REGRST(1'b0)
    );
end endgenerate

(* IODELAY_GROUP = "gmii_idelay_group" *)
IDELAYE2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(`gmii_data_idelay),
    .SIGNAL_PATTERN("DATA")
)
gmii_idelay_er (
    .IDATAIN(gmii_rx_er),
    .DATAOUT(gmii_rx_er_delay),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

(* IODELAY_GROUP = "gmii_idelay_group" *)
IDELAYE2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(`gmii_data_idelay),
    .SIGNAL_PATTERN("DATA")
)
gmii_idelay_dv (
    .IDATAIN(gmii_rx_dv),
    .DATAOUT(gmii_rx_dv_delay),
    .DATAIN(1'b0),
    .C(1'b0),
    .CE(1'b0),
    .INC(1'b0),
    .CINVCTRL(1'b0),
    .CNTVALUEIN(5'd0),
    .CNTVALUEOUT(),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .REGRST(1'b0)
);

endmodule
