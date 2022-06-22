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

module sd_cmd_serial_host (
    //---------------Input ports---------------
    input clock,
    input clock_posedge,
    input clock_data_in,
    input reset,
    input [1:0] setting,
    input [39:0] cmd,
    input start,
    input cmd_i,
    //---------------Output ports---------------
    output reg [119:0] response,
    output reg finish,
    output reg crc_ok,
    output reg index_ok,
    output reg cmd_oe,
    output reg cmd_o
);

//-------------Internal Constant-------------
parameter INIT_DELAY    = 4;
parameter BITS_TO_SEND  = 48;
parameter CMD_SIZE      = 40;
parameter RESP_SIZE     = 128;

//---------------Internal variable-----------
reg cmd_dat_reg;
integer resp_len;
reg with_response;
reg [CMD_SIZE-1:0] cmd_buff;
reg [RESP_SIZE-1:0] resp_buff;
integer resp_idx;
//CRC
reg crc_rst;
reg [6:0]crc_in;
wire [6:0] crc_val;
reg crc_enable;
reg crc_bit;
reg crc_match;
//-Internal Counterns
integer counter;
//-State Machine
parameter
    STATE_SIZE = 8,
    INIT      = 8'b00000001,
    IDLE      = 8'b00000010,
    SETUP_CRC = 8'b00000100,
    WRITE     = 8'b00001000,
    READ_WAIT = 8'b00010000,
    READ      = 8'b00100000,
    FINISH_WR = 8'b01000000,
    FINISH_WO = 8'b10000000;
reg [STATE_SIZE-1:0] state;

//Misc
`define cmd_idx  (CMD_SIZE-1-counter)

//sd cmd input pad register
always @(posedge clock) begin
    if (clock_data_in) cmd_dat_reg <= cmd_i;
end

//------------------------------------------
sd_crc_7 CRC_7(
    crc_bit,
    crc_enable & clock_posedge,
    clock,
    crc_rst,
    crc_val);

//------------------------------------------

always @(posedge clock) begin
    if (reset) begin
        resp_len <= 0;
        with_response <= 0;
        cmd_buff <= 0;
        crc_enable <= 0;
        resp_idx <= 0;
        cmd_oe <= 1;
        cmd_o <= 1;
        resp_buff <= 0;
        finish <= 0;
        crc_rst <= 1;
        crc_bit <= 0;
        crc_in <= 0;
        response <= 0;
        index_ok <= 0;
        crc_ok <= 0;
        crc_match <= 0;
        counter <= 0;
        state <= INIT;
    end else if (clock_posedge) begin
        case (state)
            INIT: begin
                counter <= counter+1;
                // Pull cmd line up
                cmd_oe <= 1;
                cmd_o <= 1;
                if (counter >= INIT_DELAY) state <= IDLE;
            end
            IDLE: begin
                cmd_oe <= 0;
                counter <= 0;
                crc_rst <= 1;
                crc_enable <= 0;
                response <= 0;
                resp_idx <= 0;
                crc_ok <= 0;
                index_ok <= 0;
                finish <= 0;
                if (start) begin
                    resp_len <= setting[1] ? 127 : 39;
                    with_response <= setting[0];
                    cmd_buff <= cmd;
                    state <= SETUP_CRC;
                end
            end
            SETUP_CRC: begin
                crc_rst <= 0;
                crc_enable <= 1;
                crc_bit <= cmd_buff[`cmd_idx];
                state <= WRITE;
            end
            WRITE: begin
                if (counter < BITS_TO_SEND-8) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
                    cmd_oe <= 1;
                    cmd_o <= cmd_buff[`cmd_idx];
                    if (counter < BITS_TO_SEND-9) begin //1 step ahead
                        crc_bit <= cmd_buff[`cmd_idx-1];
                    end else begin
                        crc_enable <= 0;
                    end
                end else if (counter < BITS_TO_SEND-1) begin
                    cmd_oe <= 1;
                    crc_enable <= 0;
                    cmd_o <= crc_val[BITS_TO_SEND-counter-2];
                end else if (counter == BITS_TO_SEND-1) begin
                    cmd_oe <= 1;
                    cmd_o <= 1'b1;
                end else begin
                    cmd_oe <= 0;
                    cmd_o <= 1'b1;
                end
                counter <= counter + 1;
                if (counter >= BITS_TO_SEND && with_response) state <= READ_WAIT;
                else if (counter >= BITS_TO_SEND) state <= FINISH_WO;
            end
            READ_WAIT: begin
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 1;
                cmd_oe <= 0;
                resp_buff[RESP_SIZE-1] <= cmd_dat_reg;
                if (!cmd_dat_reg) state <= READ;
            end
            FINISH_WO: begin
                finish <= 1;
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 0;
                cmd_oe <= 0;
                state <= IDLE;
            end
            READ: begin
                crc_rst <= 0;
                crc_enable <= (resp_len != RESP_SIZE-1 || counter > 7);
                cmd_oe <= 0;
                if (counter <= resp_len) begin
                    if (counter < 8) //1+1+6 (S,T,Index)
                        resp_buff[RESP_SIZE-1-counter] <= cmd_dat_reg;
                    else begin
                        resp_idx <= resp_idx + 1;
                        resp_buff[RESP_SIZE-9-resp_idx] <= cmd_dat_reg;
                    end
                    crc_bit <= cmd_dat_reg;
                end else if (counter-resp_len <= 7) begin
                    crc_in[(resp_len+7)-(counter)] <= cmd_dat_reg;
                    crc_enable <= 0;
                end else begin
                    crc_enable <= 0;
                    crc_match <= crc_in == crc_val;
                end
                counter <= counter + 1;
                if (counter >= resp_len+8) state <= FINISH_WR;
            end
            FINISH_WR: begin
                index_ok <= cmd_buff[37:32] == resp_buff[125:120];
                crc_ok <= crc_match;
                finish <= 1;
                crc_enable <= 0;
                crc_rst <= 1;
                counter <= 0;
                cmd_oe <= 0;
                response <= resp_buff[119:0];
                state <= IDLE;
            end
            default:
                state <= INIT;
        endcase
    end
end

endmodule

module sd_crc_7(
   input        BITVAL,                            // Next input bit
   input        ENABLE,                            // Enable calculation
   input        BITSTRB,                           // Current bit valid (Clock)
   input        CLEAR,                             // Init CRC value
   output reg [6:0] CRC                            // Current output CRC value
);

wire inv;
assign inv = BITVAL ^ CRC[6];

always @(posedge BITSTRB or posedge CLEAR) begin
    if (CLEAR) begin
        CRC <= 0;
    end else if (ENABLE == 1) begin
        CRC[6] <= CRC[5];
        CRC[5] <= CRC[4];
        CRC[4] <= CRC[3];
        CRC[3] <= CRC[2] ^ inv;
        CRC[2] <= CRC[1];
        CRC[1] <= CRC[0];
        CRC[0] <= inv;
    end
end

endmodule
