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

module sd_data_master (
    input clock,
    input clock_posedge,
    input rst,
    input start_tx_i,
    input start_rx_i,
    input [`DATA_TIMEOUT_W-1:0] timeout_i,
    // Output to SD-Host Reg
    output reg d_write_o,
    output reg d_read_o,
    // To fifo filler
    output reg start_tx_fifo_o,
    output reg start_rx_fifo_o,
    input tx_fifo_empty_i,
    input tx_fifo_ready_i,
    input rx_fifo_full_i,
    // SD-DATA_Host
    input xfr_complete_i,
    input crc_ok_i,
    // status output
    output reg [`INT_DATA_SIZE-1:0] int_status_o,
    input int_status_rst_i
);

reg [3:0] state;
localparam IDLE          = 4'b0001;
localparam START_TX_FIFO = 4'b0010;
localparam START_RX_FIFO = 4'b0100;
localparam DATA_TRANSFER = 4'b1000;

reg [`DATA_TIMEOUT_W-1:0] watchdog;
reg watchdog_enable;
reg watchdog_alarm;
reg tx_cycle;

always @(posedge clock) begin
    if (rst) begin
        start_tx_fifo_o <= 0;
        start_rx_fifo_o <= 0;
        d_write_o <= 0;
        d_read_o <= 0;
        tx_cycle <= 0;
        int_status_o <= 0;
        watchdog <= 0;
        watchdog_enable <= 0;
        watchdog_alarm <= 0;
        state <= IDLE;
    end else if (clock_posedge) begin
        case (state)
            IDLE: begin
                start_tx_fifo_o <= 0;
                start_rx_fifo_o <= 0;
                d_write_o <= 0;
                d_read_o <= 0;
                tx_cycle <= 0;
                watchdog <= 0;
                watchdog_enable <= timeout_i != 0;
                watchdog_alarm <= 0;
                if (start_tx_i) state <= START_TX_FIFO;
                else if (start_rx_i) state <= START_RX_FIFO;
            end
            START_RX_FIFO: begin
                start_rx_fifo_o <= 1;
                start_tx_fifo_o <= 0;
                tx_cycle <= 0;
                d_read_o <= 1;
                if (!xfr_complete_i) state <= DATA_TRANSFER;
            end
            START_TX_FIFO:  begin
                start_rx_fifo_o <= 0;
                start_tx_fifo_o <= 1;
                tx_cycle <= 1;
                if (tx_fifo_ready_i) begin
                    d_write_o <= 1;
                    if (!xfr_complete_i) state <= DATA_TRANSFER;
                end
            end
            DATA_TRANSFER: begin
                d_read_o <= 0;
                d_write_o <= 0;
                if (tx_cycle) begin
                    if (tx_fifo_empty_i) begin
                        int_status_o[`INT_DATA_CFE] <= 1;
                        int_status_o[`INT_DATA_EI] <= 1;
                        state <= IDLE;
                        // stop sd_data_serial_host
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end
                end else begin
                    if (rx_fifo_full_i) begin
                        int_status_o[`INT_DATA_CFE] <= 1;
                        int_status_o[`INT_DATA_EI] <= 1;
                        state <= IDLE;
                        // stop sd_data_serial_host
                        d_write_o <= 1;
                        d_read_o <= 1;
                    end
                end
                if (watchdog_alarm) begin
                    int_status_o[`INT_DATA_CTE] <= 1;
                    int_status_o[`INT_DATA_EI] <= 1;
                    state <= IDLE;
                    // stop sd_data_serial_host
                    d_write_o <= 1;
                    d_read_o <= 1;
                end else if (xfr_complete_i) begin
                    state <= IDLE;
                    if (!crc_ok_i) begin
                        int_status_o[`INT_DATA_CCRCE] <= 1;
                        int_status_o[`INT_DATA_EI] <= 1;
                    end else begin
                        int_status_o[`INT_DATA_CC] <= 1;
                    end
                end else if (watchdog_enable) begin
                    watchdog <= watchdog + 1;
                    if (watchdog >= timeout_i) watchdog_alarm <= 1;
                end
            end
        endcase
        if (int_status_rst_i)
            int_status_o <= 0;
    end
end

endmodule
