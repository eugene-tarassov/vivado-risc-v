module mem_reset_control (
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000" *)
    input wire clock,

    input wire clock_ok,
    input wire mmcm_locked,
    input wire calib_complete,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 sys_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input wire sys_reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 mem_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire mem_reset,

    output wire mem_ok
);

// DDR memory reset control

(* ASYNC_REG="true" *)
reg [2:0] clock_ok_reg = 0;
(* ASYNC_REG="true" *)
reg [2:0] no_reset_reg = 0;

reg [4:0] reset_cnt = 0;
assign mem_reset = !reset_cnt[4];
assign mem_ok = !mem_reset && mmcm_locked && calib_complete;

always @(posedge clock) begin
    clock_ok_reg <= {clock_ok_reg[1:0], clock_ok};
    no_reset_reg <= {no_reset_reg[1:0], !sys_reset};
    if (!clock_ok_reg[2] || !no_reset_reg[2]) reset_cnt <= 0;
    else if (mem_reset) reset_cnt <= reset_cnt + 1;
end

endmodule
