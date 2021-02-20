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

module axi_sd_fifo_filler #(parameter fifo_addr_bits = 6) (
    input clock,
    input clock_posedge,
    input reset,

    // Bus signals
    output reg [31:2] bus_adr_o,
    output [31:0] bus_dat_o,
    input [31:0] bus_dat_i,
    output bus_we_o,
    output bus_stb_o,
    input bus_last_i,
    input bus_ack_i,

    // Data Master Control signals
    input en_rx_i,
    input en_tx_i,
    input [31:2] adr_i,

    // Data Serial signals
    input [31:0] dat_i,
    output [31:0] dat_o,
    input wr_i,
    input rd_i,
    output [fifo_addr_bits-1:0] tx_free,
    output [fifo_addr_bits-1:0] rx_data,
    output rx_full_o,
    output tx_empty_o,
    output tx_ready_o,
    output rx_empty_o
);

localparam fifo_threshold = 1 << (fifo_addr_bits - 1);

reg bus_wait;
wire [fifo_addr_bits-1:0] tx_data;
wire tx_stb;
wire rx_stb;

assign tx_ready_o = tx_data >= fifo_threshold;
assign tx_stb = en_tx_i && tx_free >= fifo_threshold;
assign rx_stb = en_rx_i ? (rx_data >= fifo_threshold) : !rx_empty_o;
assign bus_we_o = !rx_empty_o;
assign bus_stb_o = bus_wait | tx_stb | rx_stb;

// Note: bus accesses continue for a while after en_rx_i goes to 0
axi_sd_fifo #(.addr_bits(fifo_addr_bits)) rx_fifo (
    .clk(clock),
    .rst(reset),
    .din(dat_i),
    .we(wr_i & clock_posedge),
    .dout(bus_dat_o),
    .re(bus_we_o & bus_stb_o & bus_ack_i),
    .data_len(rx_data),
    .full(rx_full_o),
    .empty(rx_empty_o));

// TODO: tx fifo reads more memory words than needed
axi_sd_fifo #(.addr_bits(fifo_addr_bits)) tx_fifo (
    .clk(clock),
    .rst(reset | !en_tx_i),
    .din(bus_dat_i),
    .we(!bus_we_o & bus_stb_o & bus_ack_i),
    .dout(dat_o),
    .re(rd_i & clock_posedge),
    .free_len(tx_free),
    .data_len(tx_data),
    .empty(tx_empty_o));

always @(posedge clock)
    if (reset) begin
        bus_adr_o <= 0;
        bus_wait <= 0;
    end else if (bus_stb_o & bus_ack_i) begin
        bus_adr_o <= bus_adr_o + 1;
        bus_wait <= !bus_last_i;
    end else if (bus_stb_o) begin
        bus_wait <= 1;
    end else if (!en_rx_i & !en_tx_i & rx_empty_o)
        bus_adr_o <= adr_i;

endmodule
