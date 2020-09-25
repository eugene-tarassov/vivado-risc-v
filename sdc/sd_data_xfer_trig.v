//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013-2020 Authors                              ////
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

module sd_data_xfer_trig (
    input clock,
    input clock_posedge,
    input rst,
    input cmd_with_data_start_i,
    input r_w_i,
    input [`INT_CMD_SIZE-1:0] cmd_int_status_i,
    output reg start_tx_o,
    output reg start_rx_o
);

reg r_w_reg;
parameter SIZE = 2;
reg [SIZE-1:0] state;
parameter IDLE             = 2'b00;
parameter WAIT_FOR_CMD_INT = 2'b01;
parameter TRIGGER_XFER     = 2'b10;

always @(posedge clock) begin
    if (rst) begin
        start_tx_o <= 0;
        start_rx_o <= 0;
        r_w_reg <= 0;
        state <= IDLE;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                start_tx_o <= 0;
                start_rx_o <= 0;
                r_w_reg <= r_w_i;
                if (cmd_with_data_start_i) begin
                    state <= r_w_i ? TRIGGER_XFER : WAIT_FOR_CMD_INT;
                end
            end
            WAIT_FOR_CMD_INT: begin
                start_tx_o <= 0;
                start_rx_o <= 0;
                if (cmd_int_status_i[`INT_CMD_CC]) state <= TRIGGER_XFER;
                else if (cmd_int_status_i[`INT_CMD_EI]) state <= IDLE;
            end
            TRIGGER_XFER: begin
                start_tx_o <= ~r_w_reg;
                start_rx_o <= r_w_reg;
                state <= IDLE;
            end
        endcase
    end
end

endmodule
