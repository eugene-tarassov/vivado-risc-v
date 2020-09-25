//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013-2020 Authors                              ////
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
    input rst,
    input start_i,
    input int_status_rst_i,
    output [1:0] setting_o,
    output reg start_xfr_o,
    output reg go_idle_o,
    output reg  [39:0] cmd_o,
    input [119:0] response_i,
    input crc_ok_i,
    input index_ok_i,
    input finish_i,
    input busy_i, // direct signal from data sd data input (data[0])
    //input card_detect,
    input [31:0] argument_i,
    input [`CMD_REG_SIZE-1:0] command_i,
    input [`CMD_TIMEOUT_W-1:0] timeout_i,
    output [`INT_CMD_SIZE-1:0] int_status_o,
    output reg [31:0] response_0_o,
    output reg [31:0] response_1_o,
    output reg [31:0] response_2_o,
    output reg [31:0] response_3_o
);

reg expect_response;
reg long_response;
reg [`INT_CMD_SIZE-1:0] int_status_reg;
reg [`CMD_TIMEOUT_W-1:0] watchdog;
reg watchdog_enable;
reg watchdog_alarm;

reg [2:0] state;
parameter IDLE       = 3'b001;
parameter EXECUTE    = 3'b010;
parameter BUSY_CHECK = 3'b100;

assign setting_o[1:0] = {long_response, expect_response};
assign int_status_o = state == IDLE ? int_status_reg : 5'h0;

always @(posedge clock) begin
    if (rst) begin
        response_0_o <= 0;
        response_1_o <= 0;
        response_2_o <= 0;
        response_3_o <= 0;
        int_status_reg <= 0;
        expect_response <= 0;
        long_response <= 0;
        cmd_o <= 0;
        start_xfr_o <= 0;
        watchdog <= 0;
        watchdog_enable <= 0;
        watchdog_alarm <= 0;
        go_idle_o <= 0;
        state <= IDLE;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                go_idle_o <= 0;
                if (command_i[`CMD_RESPONSE_CHECK]  == 2'b10 || command_i[`CMD_RESPONSE_CHECK] == 2'b11) begin
                    expect_response <=  1;
                    long_response <= 1;
                end else if (command_i[`CMD_RESPONSE_CHECK] == 2'b01) begin
                    expect_response <= 1;
                    long_response <= 0;
                end else begin
                    expect_response <= 0;
                    long_response <= 0;
                end
                cmd_o[39:38] <= 2'b01;
                cmd_o[37:32] <= command_i[`CMD_INDEX];
                cmd_o[31:0] <= argument_i;
                watchdog <= 0;
                watchdog_enable <= timeout_i != 0;
                watchdog_alarm <= 0;
                if (start_i) begin
                    start_xfr_o <= 1;
                    int_status_reg <= 0;
                    state <= EXECUTE;
                end
            end
            EXECUTE: begin
                start_xfr_o <= 0;
                if (watchdog_alarm) begin
                    int_status_reg[`INT_CMD_CTE] <= 1;
                    int_status_reg[`INT_CMD_EI] <= 1;
                    go_idle_o <= 1;
                    state <= IDLE;
                end else begin
                    if (watchdog_enable) begin
                        watchdog <= watchdog + 1;
                        if (watchdog >= timeout_i) watchdog_alarm <= 1;
                    end
                    if (finish_i) begin
                        if (command_i[`CMD_CRC_CHECK] && !crc_ok_i) begin
                            int_status_reg[`INT_CMD_CCRCE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        if (command_i[`CMD_IDX_CHECK] && !index_ok_i) begin
                            int_status_reg[`INT_CMD_CIE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        int_status_reg[`INT_CMD_CC] <= 1;
                        if (expect_response) begin
                            response_0_o <= response_i[119:88];
                            response_1_o <= response_i[87:56];
                            response_2_o <= response_i[55:24];
                            response_3_o <= {response_i[23:0], 8'h00};
                        end
                        if (command_i[`CMD_BUSY_CHECK]) state <= BUSY_CHECK;
                        else state <= IDLE;
                    end
                end
            end
            BUSY_CHECK: begin
                if (!busy_i) state <= IDLE;
            end
        endcase
        if (int_status_rst_i)
            int_status_reg <= 0;
    end
end

endmodule
