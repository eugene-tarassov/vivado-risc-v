//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2020 Authors                                   ////
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

module axi_sd_fifo #(parameter addr_bits = 4) (
    input clk,
    input rst,
    input re,
    input we,
    input [31:0] din,
    output reg [31:0] dout,
    output [addr_bits-1:0] data_len,
    output [addr_bits-1:0] free_len,
    output full,
    output empty);

reg  [31:0] mem [(1<<addr_bits)-1:0];
reg  [addr_bits-1:0] inp_pos;
reg  [addr_bits-1:0] out_pos;
wire [addr_bits-1:0] inp_nxt;
wire [addr_bits-1:0] out_nxt;

assign full = inp_nxt == out_pos;
assign empty = inp_pos == out_pos;
assign inp_nxt = inp_pos + 1;
assign out_nxt = out_pos + 1;
assign data_len = inp_pos - out_pos;
assign free_len = out_pos - inp_nxt;

always @(posedge clk)
    if (rst) begin
        inp_pos <= 0;
        out_pos <= 0;
    end else begin
        if (we && !full) begin
            mem[inp_pos] <= din;
            inp_pos <= inp_nxt;
            if (empty) dout <= din;
        end
        if (re && !empty) begin
            if (we && !full && out_nxt == inp_pos) dout <= din;
            else dout <= mem[out_nxt];
            out_pos <= out_nxt;
        end
    end

endmodule
