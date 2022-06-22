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

module sd_data_serial_host(
    input clock,
    input clock_posedge,
    input clock_data_in,
    input reset,
    // Tx Fifo
    input [31:0] data_in,
    output reg rd,
    // Rx Fifo
    output reg [31:0] data_out,
    output reg we,
    // tristate data
    output reg dat_oe,
    output reg[3:0] dat_o,
    input [3:0] dat_i,
    // Controll signals
    input [`BLKSIZE_W-1:0] blksize,
    input bus_4bit,
    input [`BLKCNT_W-1:0] blkcnt,
    input [1:0] start,
    input [1:0] byte_alignment,
    output sd_data_busy,
    output busy,
    output reg crc_ok
);

reg [3:0] DAT_dat_reg;
reg bus_4bit_reg;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [3:0];
reg [`BLKSIZE_W+4-1:0] data_cycles;
reg [`BLKSIZE_W+4-1:0] transf_cnt;
reg [3:0] drt_bit;
reg [3:0] drt_reg;
reg [`BLKCNT_W-1:0] blkcnt_reg;
reg [1:0] byte_alignment_reg;
reg [3:0] crc_bit;
reg [3:0] last_din;
reg [4:0] data_index;

reg [6:0] state;
parameter IDLE       = 7'b0000001;
parameter WRITE_DAT  = 7'b0000010;
parameter WRITE_WAIT = 7'b0000100;
parameter WRITE_DRT  = 7'b0001000;
parameter WRITE_BUSY = 7'b0010000;
parameter READ_WAIT  = 7'b0100000;
parameter READ_DAT   = 7'b1000000;

// sd data input pad register
always @(posedge clock) begin
    if (clock_data_in) DAT_dat_reg <= dat_i;
end

genvar i;
generate
    for (i=0; i<4; i=i+1) begin: CRC_16_gen
        sd_crc_16 CRC_16_i (last_din[i], crc_en & clock_posedge, clock, crc_rst, crc_out[i]);
    end
endgenerate

assign busy = (state != IDLE);
assign sd_data_busy = !DAT_dat_reg[0];

always @(posedge clock) begin
    if (reset) begin
        state <= IDLE;
        dat_oe <= 0;
        crc_en <= 0;
        crc_rst <= 1;
        transf_cnt <= 0;
        rd <= 0;
        last_din <= 0;
        crc_bit <= 0;
        dat_o <= 4'b1111;
        drt_bit <= 0;
        drt_reg <= 0;
        we <= 0;
        data_out <= 0;
        crc_ok <= 0;
        data_index <= 0;
        blkcnt_reg <= 0;
        byte_alignment_reg <= 0;
        data_cycles <= 0;
        bus_4bit_reg <= 0;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                dat_oe <= 0;
                dat_o <= 4'b1111;
                transf_cnt <= 0;
                crc_en <= 0;
                crc_rst <= 1;
                crc_bit <= 15;
                we <= 0;
                rd <= 0;
                data_index <= 0;
                blkcnt_reg <= blkcnt;
                byte_alignment_reg <= byte_alignment;
                data_cycles <= (bus_4bit ? {3'b000, blksize, 1'b0} + 2 : {1'b0, blksize, 3'b000} + 8);
                bus_4bit_reg <= bus_4bit;
                if (start == 2'b01) state <= WRITE_DAT;
                else if (start == 2'b10) state <= READ_WAIT;
            end
            WRITE_DAT: begin
                rd <= 0;
                transf_cnt <= transf_cnt + 16'h1;
                if (transf_cnt == 0) begin
                    crc_ok <= 0;
                    crc_bit <= 15;
                end else if (transf_cnt == 1) begin
                    crc_rst <= 0;
                    crc_en <= 1;
                    if (bus_4bit_reg) begin
                        last_din <= {
                            data_in[31-(byte_alignment_reg << 3)],
                            data_in[30-(byte_alignment_reg << 3)],
                            data_in[29-(byte_alignment_reg << 3)],
                            data_in[28-(byte_alignment_reg << 3)]
                        };
                    end else begin
                        last_din <= {3'h7, data_in[31-(byte_alignment_reg << 3)]};
                    end
                    dat_oe <= 1;
                    dat_o <= bus_4bit_reg ? 4'h0 : 4'he;
                    data_index <= bus_4bit_reg ? {2'b00, byte_alignment_reg, 1'b1} : {byte_alignment_reg, 3'b001};
                end else if (transf_cnt <= data_cycles+1) begin
                    if (bus_4bit_reg) begin
                        last_din <= {
                            data_in[31-(data_index[2:0]<<2)],
                            data_in[30-(data_index[2:0]<<2)],
                            data_in[29-(data_index[2:0]<<2)],
                            data_in[28-(data_index[2:0]<<2)]
                        };
                        if (data_index[2:0] == 3'h6 && transf_cnt <= data_cycles-1) rd <= 1;
                    end else begin
                        last_din <= {3'h7, data_in[31-data_index]};
                        if (data_index == 30) rd <= 1;
                    end
                    data_index <= data_index + 5'h1;
                    dat_o <= last_din;
                    if (transf_cnt == data_cycles+1) crc_en <= 0;
                end else if (transf_cnt <= data_cycles+17) begin
                    crc_en <= 0;
                    dat_o[0] <= crc_out[0][crc_bit];
                    if (bus_4bit_reg)
                        dat_o[3:1] <= {crc_out[3][crc_bit], crc_out[2][crc_bit], crc_out[1][crc_bit]};
                    crc_bit <= crc_bit - 1;
                end else if (transf_cnt == data_cycles+18) begin
                    dat_o <= 4'hf;
                end else if (transf_cnt == data_cycles+19) begin
                    dat_oe <= 0;
                end else begin
                    state <= WRITE_WAIT;
                end
            end
            WRITE_WAIT: begin
                drt_bit <= 0;
                if (!DAT_dat_reg[0]) state <= WRITE_DRT;
            end
            WRITE_DRT: begin
                // See 7.3.3.1 Data Response Token
                if (drt_bit <= 3) begin
                    drt_reg[drt_bit] <= DAT_dat_reg[0];
                end else if (drt_bit == 15) begin
                    crc_ok <= drt_reg[3:0] == 4'b1010;
                    state <= WRITE_BUSY;
                end
                drt_bit <= drt_bit + 1;
            end
            WRITE_BUSY: begin
                if (DAT_dat_reg[0]) begin
                    if (blkcnt_reg != 0 && crc_ok) begin
                        transf_cnt <= 0;
                        blkcnt_reg <= blkcnt_reg - 1;
                        byte_alignment_reg <= byte_alignment_reg + blksize[1:0] + 2'b1;
                        crc_rst <= 1;
                        state <= WRITE_DAT;
                    end else begin
                        state <= IDLE;
                    end
                end
            end
            READ_WAIT: begin
                dat_oe <= 0;
                crc_bit <= 15;
                last_din <= 0;
                transf_cnt <= 0;
                data_index <= bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3);
                if (!DAT_dat_reg[0]) begin
                    crc_rst <= 0;
                    crc_en <= 1;
                    state <= READ_DAT;
                end
            end
            READ_DAT: begin
                last_din <= DAT_dat_reg;
                transf_cnt <= transf_cnt + 16'h1;
                if (transf_cnt < data_cycles) begin
                    if (bus_4bit_reg) begin
                        we <= (data_index[2:0] == 7 || (transf_cnt == data_cycles-1 && !blkcnt_reg));
                        data_out[31-(data_index[2:0]<<2)] <= DAT_dat_reg[3];
                        data_out[30-(data_index[2:0]<<2)] <= DAT_dat_reg[2];
                        data_out[29-(data_index[2:0]<<2)] <= DAT_dat_reg[1];
                        data_out[28-(data_index[2:0]<<2)] <= DAT_dat_reg[0];
                    end else begin
                        we <= (data_index == 31 || (transf_cnt == data_cycles-1 && !blkcnt_reg));
                        data_out[31-data_index] <= DAT_dat_reg[0];
                    end
                    data_index <= data_index + 5'h1;
                    crc_ok <= 1;
                end else if (transf_cnt == data_cycles) begin
                    crc_en <= 0;
                    we <= 0;
                end else if (transf_cnt <= data_cycles+16) begin
                    if (crc_out[0][crc_bit] != last_din[0]) crc_ok <= 0;
                    if (bus_4bit_reg) begin
                        if (crc_out[1][crc_bit] != last_din[1]) crc_ok <= 0;
                        if (crc_out[2][crc_bit] != last_din[2]) crc_ok <= 0;
                        if (crc_out[3][crc_bit] != last_din[3]) crc_ok <= 0;
                    end
                    if (crc_bit == 0) begin
                        byte_alignment_reg <= byte_alignment_reg + blksize[1:0] + 2'b1;
                        crc_rst <= 1;
                    end else begin
                        crc_bit <= crc_bit - 1;
                    end
                end else if (blkcnt_reg != 0 && crc_ok) begin
                    blkcnt_reg <= blkcnt_reg - 1;
                    state <= READ_WAIT;
                end else begin
                    state <= IDLE;
                end
            end
            default:
                state <= IDLE;
        endcase
        if (start == 2'b11) state <= IDLE; // Abort
    end
end

endmodule

module sd_crc_16(
    input        BITVAL,                            // Next input bit
    input        ENABLE,                            // Enable calculation
    input        BITSTRB,                           // Current bit valid (Clock)
    input        CLEAR,                             // Init CRC value
    output reg [15:0] CRC                           // Current output CRC value
);

assign inv = BITVAL ^ CRC[15];

always @(posedge BITSTRB) begin
    if (CLEAR) begin
        CRC <= 0;
    end else if (ENABLE == 1) begin
        CRC[15] <= CRC[14];
        CRC[14] <= CRC[13];
        CRC[13] <= CRC[12];
        CRC[12] <= CRC[11] ^ inv;
        CRC[11] <= CRC[10];
        CRC[10] <= CRC[9];
        CRC[9] <= CRC[8];
        CRC[8] <= CRC[7];
        CRC[7] <= CRC[6];
        CRC[6] <= CRC[5];
        CRC[5] <= CRC[4] ^ inv;
        CRC[4] <= CRC[3];
        CRC[3] <= CRC[2];
        CRC[2] <= CRC[1];
        CRC[1] <= CRC[0];
        CRC[0] <= inv;
    end
end

endmodule
