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

module sd_data_master (
    input clock,
    input clock_posedge,
    input reset,
    input start_tx,
    input start_rx,
    input [`DATA_TIMEOUT_W-1:0] timeout,
    // Output to SD-Host Reg
    output reg d_write,
    output reg d_read,
    // To fifo filler
    output reg en_tx_fifo,
    output reg en_rx_fifo,
    input fifo_empty,
    input fifo_ready,
    input fifo_full,
    input bus_cycle,
    // SD-DATA_Host
    input xfr_complete,
    input crc_error,
    input bus_error,
    // status output
    output reg [`INT_DATA_SIZE-1:0] int_status,
    input int_status_rst
);

reg [3:0] state;
localparam IDLE          = 4'b0001;
localparam START_TX_FIFO = 4'b0010;
localparam START_RX_FIFO = 4'b0100;
localparam DATA_TRANSFER = 4'b1000;

reg [`DATA_TIMEOUT_W-1:0] watchdog;
reg watchdog_enable;

always @(posedge clock) begin
    if (reset) begin
        en_tx_fifo <= 0;
        en_rx_fifo <= 0;
        d_write <= 0;
        d_read <= 0;
        int_status <= 0;
        watchdog <= 0;
        watchdog_enable <= 0;
        state <= IDLE;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                en_tx_fifo <= 0;
                en_rx_fifo <= 0;
                d_write <= 0;
                d_read <= 0;
                watchdog <= 0;
                watchdog_enable <= timeout != 0;
                if (start_tx) state <= START_TX_FIFO;
                else if (start_rx) state <= START_RX_FIFO;
            end
            START_RX_FIFO: begin
                en_rx_fifo <= 1;
                en_tx_fifo <= 0;
                d_read <= 1;
                if (!xfr_complete) state <= DATA_TRANSFER;
            end
            START_TX_FIFO:  begin
                en_rx_fifo <= 0;
                en_tx_fifo <= 1;
                if (fifo_ready) begin
                    d_write <= 1;
                    if (!xfr_complete) state <= DATA_TRANSFER;
                end
            end
            DATA_TRANSFER: begin
                d_read <= 0;
                d_write <= 0;
                if (en_tx_fifo && fifo_empty) begin
                    int_status[`INT_DATA_CFE] <= 1;
                    int_status[`INT_DATA_EI] <= 1;
                    state <= IDLE;
                    // stop sd_data_serial_host
                    d_write <= 1;
                    d_read <= 1;
                end else if (en_rx_fifo && fifo_full) begin
                    int_status[`INT_DATA_CFE] <= 1;
                    int_status[`INT_DATA_EI] <= 1;
                    state <= IDLE;
                    // stop sd_data_serial_host
                    d_write <= 1;
                    d_read <= 1;
                end else if (watchdog_enable && watchdog >= timeout) begin
                    int_status[`INT_DATA_CTE] <= 1;
                    int_status[`INT_DATA_EI] <= 1;
                    state <= IDLE;
                    // stop sd_data_serial_host
                    d_write <= 1;
                    d_read <= 1;
                end else if (xfr_complete && !bus_cycle && (en_tx_fifo || fifo_empty)) begin
                    state <= IDLE;
                    if (crc_error) begin
                        int_status[`INT_DATA_CCRCE] <= 1;
                        int_status[`INT_DATA_EI] <= 1;
                    end
                    if (bus_error) begin
                        int_status[`INT_DATA_CBE] <= 1;
                        int_status[`INT_DATA_EI] <= 1;
                    end
                    int_status[`INT_DATA_CC] <= 1;
                end else if (watchdog_enable) begin
                    watchdog <= watchdog + 1;
                end
            end
        endcase
        if (int_status_rst)
            int_status <= 0;
    end
end

endmodule
