module mem_reset_control (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    input wire clock,

    input wire clock_ok,       // Main PLL is stable
    input wire mmcm_locked,    // Memory controller PLL is stable
    input wire calib_complete, // Memory controller calibration is complete

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ui_clk_sync_rst RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire ui_clk_sync_rst,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 sys_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire sys_reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 mem_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire mem_reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output wire aresetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ui_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET ui_clk_sync_rst:aresetn" *)
    input wire ui_clk,

    output wire mem_ok
);

// DDR memory reset control

(* ASYNC_REG="true" *)
reg [2:0] clock_ok_reg = 0;
(* ASYNC_REG="true" *)
reg [2:0] sys_reset_reg = 3'b111;
(* ASYNC_REG="true" *)
reg [2:0] aresetn_reg = 0;

reg [5:0] reset_cnt = 0;
assign mem_reset = !reset_cnt[5];
assign mem_ok = !mem_reset && mmcm_locked && calib_complete && !ui_clk_sync_rst && aresetn;

assign aresetn = aresetn_reg[2];

always @(posedge clock) begin
    clock_ok_reg <= {clock_ok_reg[1:0], clock_ok};
    sys_reset_reg <= {sys_reset_reg[1:0], sys_reset};
    if (!clock_ok_reg[2] || sys_reset_reg[2]) reset_cnt <= 0;
    else if (mem_reset) reset_cnt <= reset_cnt + 1;
end

always @(posedge ui_clk) begin
    aresetn_reg <= {aresetn_reg[1:0], !mem_reset && mmcm_locked};
end

endmodule
