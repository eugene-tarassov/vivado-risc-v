module ethernet_genesys2 (
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

    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TD" *)
    output [3:0] rgmii_txd, // Ethernet transmit data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TX_CTL" *)
    output rgmii_tx_ctl, // Ethernet transmit control (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII TXC" *)
    output rgmii_tx_clk, // Ethernet transmit clock (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RD" *)
    input [3:0] rgmii_rxd, // Ethernet receive data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RX_CTL" *)
    input rgmii_rx_ctl, // Ethernet receive control (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:rgmii:1.0 RGMII RXC" *)
    input rgmii_rx_clk // Ethernet receive clock (required)
);

// Genesys 2 board uses RTL8211E-VL phy, TXDLY off, RXDLY on

// 0.078 ns increment
`define rgmii_clock_odelay 23
`define rgmii_clock_idelay 0
`define rgmii_data_idelay  25

assign status_vector[15:9] = 0;

wire rgmii_tx_clk_delay;
wire rgmii_rx_clk_delay;
wire [3:0] rgmii_rxd_delay;
wire rgmii_rx_ctl_delay;

eth_mac_1g_rgmii_fifo #(
    .TARGET("XILINX"),
    .IODDR_STYLE("IODDR"),
    .CLOCK_INPUT_STYLE("BUFR"),
    .USE_CLK90("FALSE"),
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
    .gtx_clk90(1'b0),
    .gtx_rst(reset),
    .logic_clk(clock125),
    .logic_rst(reset),

    .tx_axis_tdata(tx_axis_tdata),
    .tx_axis_tkeep(tx_axis_tkeep),
    .tx_axis_tvalid(tx_axis_tvalid),
    .tx_axis_tready(tx_axis_tready),
    .tx_axis_tlast(tx_axis_tlast),
    .tx_axis_tuser(tx_axis_tuser),

    .rx_axis_tdata(rx_axis_tdata),
    .rx_axis_tkeep(rx_axis_tkeep),
    .rx_axis_tvalid(rx_axis_tvalid),
    .rx_axis_tready(rx_axis_tready),
    .rx_axis_tlast(rx_axis_tlast),
    .rx_axis_tuser(rx_axis_tuser),

    .rgmii_rx_clk(rgmii_rx_clk_delay),
    .rgmii_rx_ctl(rgmii_rx_ctl_delay),
    .rgmii_rxd(rgmii_rxd_delay),

    .rgmii_tx_clk(rgmii_tx_clk_delay),
    .rgmii_tx_ctl(rgmii_tx_ctl),
    .rgmii_txd(rgmii_txd),

    .tx_fifo_overflow(status_vector[0]),
    .tx_fifo_bad_frame(status_vector[1]),
    .tx_fifo_good_frame(status_vector[2]),
    .tx_error_underflow(status_vector[3]),
    .rx_error_bad_frame(status_vector[4]),
    .rx_error_bad_fcs(status_vector[5]),
    .rx_fifo_overflow(status_vector[6]),
    .rx_fifo_bad_frame(status_vector[7]),
    .rx_fifo_good_frame(status_vector[8]),

    .ifg_delay(12)
);

(* IODELAY_GROUP = "rgmii_idelay_group" *)
IDELAYCTRL rgmii_idelay_control_block (
    .REFCLK(clock200),
    .RST(reset),
    .RDY()
);

(* IODELAY_GROUP = "rgmii_idelay_group" *)
IDELAYE2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(`rgmii_clock_idelay),
    .SIGNAL_PATTERN("CLOCK")
)
rgmii_idelay_clk (
    .IDATAIN(rgmii_rx_clk),
    .DATAOUT(rgmii_rx_clk_delay),
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
generate for (n = 0; n < 4; n = n + 1) begin
    (* IODELAY_GROUP = "rgmii_idelay_group" *)
    IDELAYE2 #(
        .IDELAY_TYPE("FIXED"),
        .IDELAY_VALUE(`rgmii_data_idelay),
        .SIGNAL_PATTERN("DATA")
    )
    rgmii_idelay_rxd (
        .IDATAIN(rgmii_rxd[n]),
        .DATAOUT(rgmii_rxd_delay[n]),
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

(* IODELAY_GROUP = "rgmii_idelay_group" *)
IDELAYE2 #(
    .IDELAY_TYPE("FIXED"),
    .IDELAY_VALUE(`rgmii_data_idelay),
    .SIGNAL_PATTERN("DATA")
)
rgmii_idelay_ctl (
    .IDATAIN(rgmii_rx_ctl),
    .DATAOUT(rgmii_rx_ctl_delay),
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

(* IODELAY_GROUP = "rgmii_idelay_group" *)
ODELAYE2 #(
    .ODELAY_TYPE("FIXED"),
    .ODELAY_VALUE(`rgmii_clock_odelay),
    .SIGNAL_PATTERN("CLOCK")
)
rgmii_odelay_clk (
    .DATAOUT(rgmii_tx_clk),
    .C(1'b0),
    .CE(1'b0),
    .CINVCTRL(1'b0),
    .CLKIN(1'b0),
    .CNTVALUEIN(0),
    .INC(1'b0),
    .LD(1'b0),
    .LDPIPEEN(1'b0),
    .ODATAIN(rgmii_tx_clk_delay),
    .REGRST(1'b0)
);

endmodule
