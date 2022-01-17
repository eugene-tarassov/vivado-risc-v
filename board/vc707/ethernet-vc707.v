module ethernet_vc707 (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF TX_AXIS:RX_AXIS:GMII, ASSOCIATED_RESET reset, FREQ_HZ 125000000" *)
    output wire clock,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
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
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
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

    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TXD" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
    output [7:0]gmii_txd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_EN" *)
    output gmii_tx_en,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII TX_ER" *)
    output gmii_tx_er,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RXD" *)
    input [7:0]gmii_rxd,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_DV" *)
    input gmii_rx_dv,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gmii:1.0 GMII RX_ER" *)
    input gmii_rx_er,


    input userclk_out,
    input userclk2_out,
    input sgmii_clk_r,
    input sgmii_clk_f,
    input sgmii_clk_en,
    input gmii_isolate,
    output [4:0]configuration_vector,

    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 an_interrupt INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY EDGE_RISING" *)
    input an_interrupt,

    output [15:0]an_adv_config_vector,
    output an_restart_config,
    output speed_is_10_100,
    output speed_is_100,
    input [15:0]status_vector,
    output signal_detect
  );

wire [1:0] pcspma_status_speed              = status_vector[11:10];

assign configuration_vector[4]      = 1'b1; // autonegotiation enable
assign configuration_vector[3]      = 1'b0; // isolate
assign configuration_vector[2]      = 1'b0; // power down
assign configuration_vector[1]      = 1'b0; // loopback enable
assign configuration_vector[0]      = 1'b0; // unidirectional enable

assign an_adv_config_vector[15]     = 1'b1;    // SGMII link status
assign an_adv_config_vector[14]     = 1'b1;    // SGMII Acknowledge
assign an_adv_config_vector[13:12]  = 2'b01;   // full duplex
assign an_adv_config_vector[11:10]  = 2'b10;   // SGMII speed
assign an_adv_config_vector[9]      = 1'b0;    // reserved
assign an_adv_config_vector[8:7]    = 2'b00;   // pause frames - SGMII reserved
assign an_adv_config_vector[6]      = 1'b0;    // reserved
assign an_adv_config_vector[5]      = 1'b0;    // full duplex - SGMII reserved
assign an_adv_config_vector[4:1]    = 4'b0000; // reserved
assign an_adv_config_vector[0]      = 1'b1;    // SGMII

eth_mac_1g_fifo #(
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
    .rx_clk(clock),
    .rx_rst(reset),
    .tx_clk(clock),
    .tx_rst(reset),
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

    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),

    .rx_clk_enable(sgmii_clk_en),
    .tx_clk_enable(sgmii_clk_en),
    .rx_mii_select(1'b0),
    .tx_mii_select(1'b0),

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

// ----------------------- SGMII ---------------------------- //

assign clock = userclk2_out;
assign an_restart_config = 1'b0;
assign speed_is_10_100 = pcspma_status_speed != 2'b10;
assign speed_is_100 = pcspma_status_speed == 2'b01;
assign signal_detect = 1'b1;

endmodule
