module ethernet_arty_a7_100t (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock25 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset" *)
    input wire clock,

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

    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII TXD" *)
    output wire [3:0] mii_txd, // Ethernet transmit data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII TX_EN" *)
    output wire mii_tx_en, // Ethernet transmit enable (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII RXD" *)
    input wire [3:0] mii_rxd, // Ethernet receive data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII RX_DV" *)
    input wire mii_rx_dv, // Ethernet receive data valid (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII RX_ER" *)
    input wire mii_rx_er, // Ethernet receive error (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII CRS" *)
    input wire mii_crs, // Ethernet carrier sense (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII COL" *)
    input wire mii_col, // Ethernet collision (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII TX_CLK" *)
    input wire mii_tx_clk, // Ethernet transmit clock (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:mii:1.0 MII RX_CLK" *)
    input wire mii_rx_clk // Ethernet receive clock (required)
);

`default_nettype none

assign status_vector[15:9] = { mii_col, mii_crs, 2'b00 };

eth_mac_mii_fifo #(
    .TARGET("XILINX"),
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
    .rst(reset),
    .logic_clk(clock),
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

    .mii_rx_clk(mii_rx_clk),
    .mii_rxd(mii_rxd),
    .mii_rx_dv(mii_rx_dv),
    .mii_rx_er(mii_rx_er),
    .mii_tx_clk(mii_tx_clk),
    .mii_txd(mii_txd),
    .mii_tx_en(mii_tx_en),
    .mii_tx_er(),

    .tx_fifo_overflow(status_vector[0]),
    .tx_fifo_bad_frame(status_vector[1]),
    .tx_fifo_good_frame(status_vector[2]),
    .tx_error_underflow(status_vector[3]),
    .rx_error_bad_frame(status_vector[4]),
    .rx_error_bad_fcs(status_vector[5]),
    .rx_fifo_overflow(status_vector[6]),
    .rx_fifo_bad_frame(status_vector[7]),
    .rx_fifo_good_frame(status_vector[8]),

    .cfg_ifg(8'd12),
    .cfg_tx_enable(1'b1),
    .cfg_rx_enable(1'b1)
);

endmodule
