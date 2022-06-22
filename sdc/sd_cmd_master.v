//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013-2022 Authors                              ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from https://www.gnu.org/licenses/                           ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_defines.h"

module sd_cmd_master(
    input clock,
    input clock_posedge,
    input reset,
    input start,
    input int_status_rst,
    output [1:0] setting,
    output reg start_xfr,
    output reg go_idle,
    output reg  [39:0] cmd,
    input [119:0] response,
    input crc_error,
    input index_ok,
    input finish,
    input busy, // direct signal from data sd data input (data[0])
    //input card_detect,
    input [31:0] argument,
    input [`CMD_REG_SIZE-1:0] command,
    input [`CMD_TIMEOUT_W-1:0] timeout,
    output [`INT_CMD_SIZE-1:0] int_status,
    output reg [31:0] response_0,
    output reg [31:0] response_1,
    output reg [31:0] response_2,
    output reg [31:0] response_3
);

reg expect_response;
reg long_response;
reg [`INT_CMD_SIZE-1:0] int_status_reg;
reg [`CMD_TIMEOUT_W-1:0] watchdog;
reg watchdog_enable;

reg [2:0] state;
parameter IDLE       = 3'b001;
parameter EXECUTE    = 3'b010;
parameter BUSY_CHECK = 3'b100;

assign setting[1:0] = {long_response, expect_response};
assign int_status = state == IDLE ? int_status_reg : 5'h0;

always @(posedge clock) begin
    if (reset) begin
        response_0 <= 0;
        response_1 <= 0;
        response_2 <= 0;
        response_3 <= 0;
        int_status_reg <= 0;
        expect_response <= 0;
        long_response <= 0;
        cmd <= 0;
        start_xfr <= 0;
        watchdog <= 0;
        watchdog_enable <= 0;
        go_idle <= 0;
        state <= IDLE;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                go_idle <= 0;
                if (command[`CMD_RESPONSE_CHECK]  == 2'b10 || command[`CMD_RESPONSE_CHECK] == 2'b11) begin
                    expect_response <=  1;
                    long_response <= 1;
                end else if (command[`CMD_RESPONSE_CHECK] == 2'b01) begin
                    expect_response <= 1;
                    long_response <= 0;
                end else begin
                    expect_response <= 0;
                    long_response <= 0;
                end
                cmd[39:38] <= 2'b01;
                cmd[37:32] <= command[`CMD_INDEX];
                cmd[31:0] <= argument;
                watchdog <= 0;
                watchdog_enable <= timeout != 0;
                if (start) begin
                    start_xfr <= 1;
                    int_status_reg <= 0;
                    state <= EXECUTE;
                end
            end
            EXECUTE: begin
                start_xfr <= 0;
                if (watchdog_enable && watchdog >= timeout) begin
                    int_status_reg[`INT_CMD_CTE] <= 1;
                    int_status_reg[`INT_CMD_EI] <= 1;
                    go_idle <= 1;
                    state <= IDLE;
                end else if (finish) begin
                    if (command[`CMD_CRC_CHECK] && crc_error) begin
                        int_status_reg[`INT_CMD_CCRCE] <= 1;
                        int_status_reg[`INT_CMD_EI] <= 1;
                    end
                    if (command[`CMD_IDX_CHECK] && !index_ok) begin
                        int_status_reg[`INT_CMD_CIE] <= 1;
                        int_status_reg[`INT_CMD_EI] <= 1;
                    end
                    int_status_reg[`INT_CMD_CC] <= 1;
                    if (expect_response) begin
                        response_0 <= response[119:88];
                        response_1 <= response[87:56];
                        response_2 <= response[55:24];
                        response_3 <= {response[23:0], 8'h00};
                    end
                    if (command[`CMD_BUSY_CHECK]) state <= BUSY_CHECK;
                    else state <= IDLE;
                end else if (watchdog_enable) begin
                    watchdog <= watchdog + 1;
                end
            end
            BUSY_CHECK: begin
                if (!busy) state <= IDLE;
            end
        endcase
        if (int_status_rst)
            int_status_reg <= 0;
    end
end

endmodule
