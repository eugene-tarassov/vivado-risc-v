module ethernet_kc705 (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock125 CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS, ASSOCIATED_RESET reset, FREQ_HZ 125000000" *)
    input wire clock125,

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


    // GMII - Gigabit Media Independent Interface
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TXD" *)
    output [7:0] gmii_txd, // Ethernet transmit data. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_EN" *)
    output gmii_tx_en, // Ethernet transmit enable. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_ER" *)
    output gmii_tx_er, // Ethernet transmit error.
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RXD" *)
    input [7:0] gmii_rxd, // Ethernet receive data.  (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_DV" *)
    input gmii_rx_dv, // Ethernet receive data valid. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_ER" *)
    input gmii_rx_er, // Ethernet receive error. (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII CRS" *)
    input gmii_crs, // Ethernet carrier sense.
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII COL" *)
    input gmii_col, // Ethernet collision.
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_CLK" *)
    input gmii_tx_clk, // Ethernet transmit clock for 10/100Mb/s Ethernet speeds
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII GTX_CLK" *)
    output gmii_gtx_clk, // Ethernet transmit clock for 1Gb/s Ethernet
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_CLK" *)
    input gmii_rx_clk // Ethernet receive clock
);

// KC705 board uses Marvell Alaska 88E1111 PHY

assign status_vector[15:9] = 0;

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

    .gmii_rx_clk(gmii_rx_clk),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_tx_clk(gmii_gtx_clk),
    .mii_tx_clk(gmii_tx_clk),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),

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

endmodule
