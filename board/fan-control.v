module fan_control #(
    parameter real temperature = 50.0, // Celsius
    parameter real fan_min  = 25.0, // Power %
    parameter real fan_norm = 45.0  // Power %
) (
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 async_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input wire async_resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 async_resetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output wire resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 100000000" *)
    input wire clock,

    input wire alarm,
    input wire [11:0] device_temp,
    output reg fan_pwm
);

// Fan control using High-Frequency PWM

wire reset;
(* ASYNC_REG="true" *)
reg [2:0] reset_sync;
assign reset = reset_sync[2];
assign resetn = !reset;

always @(posedge clock)
    reset_sync <= {reset_sync[1:0], !async_resetn};

`define reg_width 20
`define reg_msb (`reg_width - 1)

reg [11:0] cnt = 0;
reg [`reg_msb:0] temp_reg = 0;
wire signed [`reg_msb:0] temp_err = temp_reg - ($rtoi((temperature + 273.15) * 4096 / 503.975) << (`reg_width - 12));
wire signed [`reg_msb:0] control = $rtoi(fan_norm * 4096 / 100) + (temp_err >>> (`reg_width - 16));

always @(posedge clock) begin
    if (reset) begin
        temp_reg <= ~0;
        fan_pwm <= 1;
        cnt <= 0;
    end else begin
        if (alarm || cnt < $rtoi(fan_min * 4096 / 100)) fan_pwm <= 1;
        else if (control <= $rtoi(fan_min * 4096 / 100)) fan_pwm <= 0;
        else fan_pwm <= cnt < control;
        if (cnt == 0) temp_reg <= temp_reg - (temp_reg >> (`reg_width - 12)) + device_temp;
        cnt <= cnt + 1;
    end
end

endmodule
