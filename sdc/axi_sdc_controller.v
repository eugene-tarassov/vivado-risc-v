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

module sdc_controller #(
    parameter dma_addr_bits = 32,
    parameter fifo_addr_bits = 7,
    parameter sdio_card_detect_level = 1,
    parameter voltage_controll_reg = 3300,
    parameter capabilies_reg = 16'b0000_0000_0000_0011
) (
    input wire async_resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXI:S_AXI_LITE, FREQ_HZ 100000000" *)
    input wire clock,

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWADDR" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock, ID_WIDTH 0, PROTOCOL AXI4LITE, DATA_WIDTH 32" *)
    input wire [15:0] s_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWVALID" *)
    input wire s_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWREADY" *)
    output wire s_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WDATA" *)
    input wire [31:0] s_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WVALID" *)
    input wire s_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WREADY" *)
    output wire s_axi_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BRESP" *)
    output reg [1:0] s_axi_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BVALID" *)
    output reg s_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BREADY" *)
    input wire s_axi_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARADDR" *)
    input wire [15:0] s_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARVALID" *)
    input wire s_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARREADY" *)
    output wire s_axi_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RDATA" *)
    output reg [31:0] s_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RRESP" *)
    output reg [1:0] s_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RVALID" *)
    output reg s_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RREADY" *)
    input wire s_axi_rready,

    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock, ID_WIDTH 0, PROTOCOL AXI4, DATA_WIDTH 32" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *)
    output reg  [dma_addr_bits-1:0] m_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *)
    output reg  [7:0] m_axi_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *)
    output reg  m_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *)
    input wire m_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *)
    output wire [31:0] m_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WLAST" *)
    output reg  m_axi_wlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *)
    output reg  m_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *)
    input wire m_axi_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *)
    input wire [1:0] m_axi_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *)
    input wire m_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *)
    output wire m_axi_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *)
    output reg  [dma_addr_bits-1:0] m_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARLEN" *)
    output reg  [7:0] m_axi_arlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *)
    output reg  m_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *)
    input wire m_axi_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *)
    input wire [31:0] m_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RLAST" *)
    input wire m_axi_rlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *)
    input wire [1:0] m_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *)
    input wire m_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *)
    output wire m_axi_rready,

    // SD BUS
    inout wire sdio_cmd,
    inout wire [3:0] sdio_dat,
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sdio_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 50000000" *)
    output reg sdio_clk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 sdio_reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output reg sdio_reset,
    input wire sdio_cd,

    // Interrupts
    output wire interrupt
);

`include "sd_defines.h"

wire reset;

wire go_idle;
reg  cmd_start;
wire [1:0] cmd_setting;
wire cmd_start_tx;
wire [39:0] cmd;
wire [119:0] cmd_response;
wire cmd_crc_ok;
wire cmd_index_ok;
wire cmd_finish;

wire d_write;
wire d_read;
wire [31:0] data_in_rx_fifo;
wire en_tx_fifo;
wire en_rx_fifo;
wire sd_data_busy;
wire data_busy;
wire data_crc_ok;
wire tx_fifo_re;
wire rx_fifo_we;

reg data_start_rx;
reg data_start_tx;
reg data_prepare_tx;
reg  cmd_int_rst;
reg  data_int_rst;
reg  ctrl_rst;

// AXI accessible registers
reg  [31:0] argument_reg;
reg  [`CMD_REG_SIZE-1:0] command_reg;
reg  [`CMD_TIMEOUT_W-1:0] cmd_timeout_reg;
reg  [`DATA_TIMEOUT_W-1:0] data_timeout_reg;
reg  [0:0] software_reset_reg;
wire [31:0] response_0_reg;
wire [31:0] response_1_reg;
wire [31:0] response_2_reg;
wire [31:0] response_3_reg;
reg  [`BLKSIZE_W-1:0] block_size_reg;
reg  [1:0] controller_setting_reg;
wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg;
wire [`INT_DATA_SIZE-1:0] data_int_status_reg;
wire [`INT_DATA_SIZE-1:0] data_int_status;
reg  [`INT_CMD_SIZE-1:0] cmd_int_enable_reg;
reg  [`INT_DATA_SIZE-1:0] data_int_enable_reg;
reg  [`BLKCNT_W-1:0] block_count_reg;
reg  [dma_addr_bits-1:0] dma_addr_reg;
reg  [7:0] clock_divider_reg = 124; // 400KHz

// ------ Clocks and resets

(* ASYNC_REG="true" *)
reg  [2:0] reset_sync;
assign reset = reset_sync[2];

always @(posedge clock)
    reset_sync <= {reset_sync[1:0], !async_resetn};

reg [7:0] clock_cnt;
reg clock_state;
reg clock_posedge;
reg clock_data_in;
wire fifo_almost_full;
wire fifo_almost_empty;

always @(posedge clock) begin
    if (reset) begin
        clock_posedge <= 0;
        clock_data_in <= 0;
        clock_state <= 0;
        clock_cnt <= 0;
    end else if (clock_cnt < clock_divider_reg) begin
        clock_posedge <= 0;
        clock_data_in <= 0;
        clock_cnt <= clock_cnt + 1;
    end else if (clock_cnt < 124 && data_busy && en_rx_fifo && fifo_almost_full) begin
        // Prevent Rx FIFO overflow
        clock_posedge <= 0;
        clock_data_in <= 0;
        clock_cnt <= clock_cnt + 1;
    end else if (clock_cnt < 124 && data_busy && en_tx_fifo && fifo_almost_empty) begin
        // Prevent Tx FIFO underflow
        clock_posedge <= 0;
        clock_data_in <= 0;
        clock_cnt <= clock_cnt + 1;
    end else begin
        clock_state <= !clock_state;
        clock_posedge <= !clock_state;
        if (clock_divider_reg == 0)
            clock_data_in <= !clock_state;
        else
            clock_data_in <= clock_state;
        clock_cnt <= 0;
    end
    sdio_clk <= sdio_reset || clock_state;

    if (reset) sdio_reset <= 0;
    else if (clock_posedge) sdio_reset <= controller_setting_reg[1];
end

// ------ SD IO Buffers

wire sd_cmd_i;
wire sd_cmd_o;
wire sd_cmd_oe;
reg  sd_cmd_reg_o;
reg  sd_cmd_reg_t;
wire [3:0] sd_dat_i;
wire [3:0] sd_dat_o;
wire sd_dat_oe;
reg  [3:0] sd_dat_reg_o;
reg  sd_dat_reg_t;

IOBUF IOBUF_cmd (.O(sd_cmd_i), .IO(sdio_cmd), .I(sd_cmd_reg_o), .T(sd_cmd_reg_t));
IOBUF IOBUF_dat0 (.O(sd_dat_i[0]), .IO(sdio_dat[0]), .I(sd_dat_reg_o[0]), .T(sd_dat_reg_t));
IOBUF IOBUF_dat1 (.O(sd_dat_i[1]), .IO(sdio_dat[1]), .I(sd_dat_reg_o[1]), .T(sd_dat_reg_t));
IOBUF IOBUF_dat2 (.O(sd_dat_i[2]), .IO(sdio_dat[2]), .I(sd_dat_reg_o[2]), .T(sd_dat_reg_t));
IOBUF IOBUF_dat3 (.O(sd_dat_i[3]), .IO(sdio_dat[3]), .I(sd_dat_reg_o[3]), .T(sd_dat_reg_t));

always @(negedge clock) begin
    // Output data delayed by 1/2 clock cycle (5ns) to ensure
    // required hold time: default speed - min 5ns, high speed - min 2ns (actual 5ns)
    if (sdio_reset) begin
        sd_cmd_reg_o <= 0;
        sd_dat_reg_o <= 0;
        sd_cmd_reg_t <= 0;
        sd_dat_reg_t <= 0;
    end else begin
        sd_cmd_reg_o <= sd_cmd_o;
        sd_dat_reg_o <= sd_dat_o;
        sd_cmd_reg_t <= !sd_cmd_oe;
        sd_dat_reg_t <= !(sd_dat_oe || (cmd_start_tx && (command_reg == 0)));
    end
end

// ------ SD card detect

reg [25:0] sd_detect_cnt;
wire sd_insert_int = sd_detect_cnt[25];
wire sd_remove_int = !sd_detect_cnt[25];
reg sd_insert_ie;
reg sd_remove_ie;

always @(posedge clock) begin
    if (sdio_cd != sdio_card_detect_level) begin
        sd_detect_cnt <= 0;
    end else if (!sd_insert_int) begin
        sd_detect_cnt <= sd_detect_cnt + 1;
    end
end

// ------ AXI Slave Interface

reg [15:0] read_addr;
reg [15:0] write_addr;
reg [31:0] write_data;
reg rd_req;
reg [1:0] wr_req;

assign s_axi_arready = !rd_req && !s_axi_rvalid;
assign s_axi_awready = !wr_req[0] && !s_axi_bvalid;
assign s_axi_wready = !wr_req[1] && !s_axi_bvalid;

always @(posedge clock) begin
    if (reset) begin
        s_axi_rdata <= 0;
        s_axi_rresp <= 0;
        s_axi_rvalid <= 0;
        s_axi_bresp <= 0;
        s_axi_bvalid <= 0;
        rd_req <= 0;
        wr_req <= 0;
        read_addr <= 0;
        write_addr <= 0;
        write_data <= 0;
        cmd_start <= 0;
        data_int_rst <= 0;
        cmd_int_rst <= 0;
        ctrl_rst <= 0;
        argument_reg <= 0;
        command_reg <= 0;
        cmd_timeout_reg <= 0;
        data_timeout_reg <= 0;
        block_size_reg <= `RESET_BLOCK_SIZE;
        controller_setting_reg <= 0;
        cmd_int_enable_reg <= 0;
        data_int_enable_reg <= 0;
        software_reset_reg <= 0;
        clock_divider_reg <= `RESET_CLOCK_DIV;
        block_count_reg <= 0;
        sd_insert_ie <= 0;
        sd_remove_ie <= 0;
        dma_addr_reg <= 0;
    end else begin
        if (clock_posedge) begin
            cmd_start <= 0;
            data_int_rst <= 0;
            cmd_int_rst <= 0;
            ctrl_rst <= software_reset_reg[0];
        end
        if (s_axi_arready && s_axi_arvalid) begin
            read_addr <= s_axi_araddr;
            rd_req <= 1;
        end
        if (s_axi_rvalid && s_axi_rready) begin
            s_axi_rvalid <= 0;
        end else if (!s_axi_rvalid && rd_req) begin
            s_axi_rdata <= 0;
            if (read_addr[15:8] == 0) begin
                case (read_addr[7:0])
                    `argument     : s_axi_rdata <= argument_reg;
                    `command      : s_axi_rdata <= command_reg;
                    `resp0        : s_axi_rdata <= response_0_reg;
                    `resp1        : s_axi_rdata <= response_1_reg;
                    `resp2        : s_axi_rdata <= response_2_reg;
                    `resp3        : s_axi_rdata <= response_3_reg;
                    `controller   : s_axi_rdata <= controller_setting_reg;
                    `blksize      : s_axi_rdata <= block_size_reg;
                    `voltage      : s_axi_rdata <= voltage_controll_reg;
                    `capa         : s_axi_rdata <= capabilies_reg | (dma_addr_bits << 8);
                    `clock_d      : s_axi_rdata <= clock_divider_reg;
                    `reset        : s_axi_rdata <= { cmd_start, data_int_rst, cmd_int_rst, ctrl_rst };
                    `cmd_timeout  : s_axi_rdata <= cmd_timeout_reg;
                    `data_timeout : s_axi_rdata <= data_timeout_reg;
                    `cmd_isr      : s_axi_rdata <= cmd_int_status_reg;
                    `cmd_iser     : s_axi_rdata <= cmd_int_enable_reg;
                    `data_isr     : s_axi_rdata <= data_int_status_reg;
                    `data_iser    : s_axi_rdata <= data_int_enable_reg;
                    `blkcnt       : s_axi_rdata <= block_count_reg;
                    `card_detect  : s_axi_rdata <= { sd_remove_int, sd_remove_ie, sd_insert_int, sd_insert_ie };
                    `dst_src_addr : s_axi_rdata <= dma_addr_reg[31:0];
                    `dst_src_addr_high : if (dma_addr_bits > 32) s_axi_rdata <= dma_addr_reg[dma_addr_bits-1:32];
                endcase
            end
            s_axi_rresp <= 0;
            s_axi_rvalid <= 1;
            rd_req <= 0;
        end
        if (s_axi_awready && s_axi_awvalid) begin
            write_addr <= s_axi_awaddr;
            wr_req[0] <= 1;
        end
        if (s_axi_wready && s_axi_wvalid) begin
            write_data <= s_axi_wdata;
            wr_req[1] <= 1;
        end
        if (s_axi_bvalid && s_axi_bready) begin
            s_axi_bvalid <= 0;
        end else if (!s_axi_bvalid && wr_req == 2'b11) begin
            if (write_addr[15:8] == 0) begin
                case (write_addr[7:0])
                    `argument     : begin argument_reg <= write_data; cmd_start <= 1; end
                    `command      : command_reg <= write_data;
                    `reset        : software_reset_reg <= write_data;
                    `cmd_timeout  : cmd_timeout_reg <= write_data;
                    `data_timeout : data_timeout_reg <= write_data;
                    `blksize      : block_size_reg <= write_data;
                    `controller   : controller_setting_reg <= write_data;
                    `cmd_isr      : cmd_int_rst <= 1;
                    `cmd_iser     : cmd_int_enable_reg <= write_data;
                    `clock_d      : clock_divider_reg <= write_data;
                    `data_isr     : data_int_rst <= 1;
                    `data_iser    : data_int_enable_reg <= write_data;
                    `blkcnt       : block_count_reg <= write_data;
                    `card_detect  : begin sd_remove_ie <= write_data[2]; sd_insert_ie <= write_data[0]; end
                    `dst_src_addr : dma_addr_reg[31:0] <= write_data;
                    `dst_src_addr_high : if (dma_addr_bits > 32) dma_addr_reg[dma_addr_bits-1:32] <= write_data;
                endcase
            end
            s_axi_bresp <= 0;
            s_axi_bvalid <= 1;
            wr_req <= 0;
        end
    end
end

// ------ Data FIFO

reg  [31:0] fifo_mem [(1<<fifo_addr_bits)-1:0];
reg  [fifo_addr_bits-1:0] fifo_inp_pos;
reg  [fifo_addr_bits-1:0] fifo_out_pos;
wire [fifo_addr_bits-1:0] fifo_inp_nxt = fifo_inp_pos + 1;
wire [fifo_addr_bits-1:0] fifo_out_nxt = fifo_out_pos + 1;
wire [fifo_addr_bits-1:0] fifo_data_len = fifo_inp_pos - fifo_out_pos;
wire [fifo_addr_bits-1:0] fifo_free_len = fifo_out_pos - fifo_inp_nxt;
wire fifo_full = fifo_inp_nxt == fifo_out_pos;
wire fifo_empty = fifo_inp_pos == fifo_out_pos;
wire fifo_ready = fifo_data_len >= (1 << fifo_addr_bits) / 2;
wire [31:0] fifo_din = en_rx_fifo ? data_in_rx_fifo : m_bus_dat_i;
wire fifo_we = en_rx_fifo ? rx_fifo_we && clock_posedge : m_axi_rready && m_axi_rvalid;
wire fifo_re = en_rx_fifo ? m_axi_wready && m_axi_wvalid : tx_fifo_re && clock_posedge;
reg [31:0] fifo_dout;

assign fifo_almost_full = fifo_data_len > (1 << fifo_addr_bits) * 3 / 4;
assign fifo_almost_empty = fifo_free_len > (1 << fifo_addr_bits) * 3 / 4;

wire tx_stb = en_tx_fifo && fifo_free_len >= (1 << fifo_addr_bits) / 3;
wire rx_stb = en_rx_fifo && m_axi_bresp_cnt != 3'b111 && (fifo_data_len >= (1 << fifo_addr_bits) / 3 || (!fifo_empty && !data_busy));

always @(posedge clock)
    if (reset || ctrl_rst || !(en_rx_fifo || en_tx_fifo)) begin
        fifo_inp_pos <= 0;
        fifo_out_pos <= 0;
    end else begin
        if (fifo_we && !fifo_full) begin
            fifo_mem[fifo_inp_pos] <= fifo_din;
            fifo_inp_pos <= fifo_inp_nxt;
            if (fifo_empty) fifo_dout <= fifo_din;
        end
        if (fifo_re && !fifo_empty) begin
            if (fifo_we && !fifo_full && fifo_out_nxt == fifo_inp_pos) fifo_dout <= fifo_din;
            else fifo_dout <= fifo_mem[fifo_out_nxt];
            fifo_out_pos <= fifo_out_nxt;
        end
    end

// ------ AXI Master Interface

// AXI transaction (DDR access) is over 80 clock cycles
// Must use burst to achive required throughput

reg m_axi_cyc;
wire m_axi_write = en_rx_fifo;
reg [7:0] m_axi_wcnt;
reg [dma_addr_bits-1:2] m_bus_adr_o;
wire [31:0] m_bus_dat_i;
reg [2:0] m_axi_bresp_cnt;
reg m_bus_error;

assign m_axi_bready = m_axi_bresp_cnt != 0;
assign m_axi_rready = m_axi_cyc & !m_axi_write;
assign m_bus_dat_i = {m_axi_rdata[7:0],m_axi_rdata[15:8],m_axi_rdata[23:16],m_axi_rdata[31:24]};
assign m_axi_wdata = {fifo_dout[7:0],fifo_dout[15:8],fifo_dout[23:16],fifo_dout[31:24]};

// AXI burst cannot cross a 4KB boundary
wire [fifo_addr_bits-1:0] tx_burst_len;
wire [fifo_addr_bits-1:0] rx_burst_len;
assign tx_burst_len = m_bus_adr_o[11:2] + fifo_free_len >= m_bus_adr_o[11:2] ? fifo_free_len - 1 : ~m_bus_adr_o[fifo_addr_bits+1:2];
assign rx_burst_len = m_bus_adr_o[11:2] + fifo_data_len >= m_bus_adr_o[11:2] ? fifo_data_len - 1 : ~m_bus_adr_o[fifo_addr_bits+1:2];

assign data_int_status_reg = { data_int_status[`INT_DATA_SIZE-1:1],
    !en_rx_fifo && !en_tx_fifo && !m_axi_cyc && m_axi_bresp_cnt == 0 && data_int_status[0] };

always @(posedge clock) begin
    if (reset | ctrl_rst) begin
        m_axi_arvalid <= 0;
        m_axi_awvalid <= 0;
        m_axi_wvalid <= 0;
        m_axi_cyc <= 0;
    end else if (m_axi_cyc) begin
        if (m_axi_awvalid && m_axi_awready) begin
            m_axi_awvalid <= 0;
        end
        if (m_axi_arvalid && m_axi_arready) begin
            m_axi_arvalid <= 0;
        end
        if (m_axi_wvalid && m_axi_wready) begin
            if (m_axi_wlast) begin
                m_axi_wvalid <= 0;
                m_axi_cyc <= 0;
            end else begin
                m_axi_wlast <= m_axi_wcnt + 1 == m_axi_awlen;
                m_axi_wcnt <= m_axi_wcnt + 1;
            end
        end
        if (m_axi_rvalid && m_axi_rready && m_axi_rlast) begin
            m_axi_cyc <= 0;
        end
    end else if (tx_stb || rx_stb) begin
        m_axi_cyc <= 1;
        m_axi_wcnt <= 0;
        if (m_axi_write) begin
            m_axi_awaddr <= { m_bus_adr_o, 2'b00 };
            m_axi_awlen <= rx_burst_len < 8'hff ? rx_burst_len : 8'hff;
            m_axi_wlast <= rx_burst_len == 0;
            m_axi_awvalid <= 1;
            m_axi_wvalid <= 1;
        end else begin
            m_axi_araddr <= { m_bus_adr_o, 2'b00 };
            m_axi_arlen <= tx_burst_len < 8'hff ? tx_burst_len : 8'hff;
            m_axi_arvalid <= 1;
        end
    end
    if (reset | ctrl_rst) begin
        m_bus_adr_o <= 0;
    end else if ((m_axi_wready && m_axi_wvalid) || (m_axi_rready && m_axi_rvalid)) begin
        m_bus_adr_o <= m_bus_adr_o + 1;
    end else if (!m_axi_cyc && !en_rx_fifo && !en_tx_fifo) begin
        m_bus_adr_o <= dma_addr_reg[dma_addr_bits-1:2];
    end
    if (reset | ctrl_rst) begin
        m_axi_bresp_cnt <= 0;
    end else if ((m_axi_awvalid && m_axi_awready) && !(m_axi_bvalid && m_axi_bready)) begin
        m_axi_bresp_cnt <= m_axi_bresp_cnt + 1;
    end else if (!(m_axi_awvalid && m_axi_awready) && (m_axi_bvalid && m_axi_bready)) begin
        m_axi_bresp_cnt <= m_axi_bresp_cnt - 1;
    end
    if (reset | ctrl_rst | cmd_start) begin
        m_bus_error <= 0;
    end else if (m_axi_bvalid && m_axi_bready && m_axi_bresp) begin
        m_bus_error <= 1;
    end else if (m_axi_rvalid && m_axi_rready && m_axi_rresp) begin
        m_bus_error <= 1;
    end
    if (reset | ctrl_rst) begin
        data_start_tx <= 0;
        data_start_rx <= 0;
        data_prepare_tx <= 0;
    end else if (clock_posedge) begin
        data_start_tx <= 0;
        data_start_rx <= 0;
        if (cmd_start) begin
            data_prepare_tx <= 0;
            if (command_reg[`CMD_WITH_DATA] == 2'b01) data_start_rx <= 1;
            else if (command_reg[`CMD_WITH_DATA] != 2'b00) data_prepare_tx <= 1;
        end else if (data_prepare_tx) begin
            if (cmd_int_status_reg[`INT_CMD_CC]) begin
                data_prepare_tx <= 0;
                data_start_tx <= 1;
            end else if (cmd_int_status_reg[`INT_CMD_EI]) begin
                data_prepare_tx <= 0;
            end
        end
    end
end

// ------ SD Card Interface

sd_cmd_master sd_cmd_master0(
    .clock            (clock),
    .clock_posedge    (clock_posedge),
    .reset            (reset | ctrl_rst),
    .start            (cmd_start),
    .int_status_rst   (cmd_int_rst),
    .setting          (cmd_setting),
    .start_xfr        (cmd_start_tx),
    .go_idle          (go_idle),
    .cmd              (cmd),
    .response         (cmd_response),
    .crc_error        (!cmd_crc_ok),
    .index_ok         (cmd_index_ok),
    .busy             (sd_data_busy),
    .finish           (cmd_finish),
    .argument         (argument_reg),
    .command          (command_reg),
    .timeout          (cmd_timeout_reg),
    .int_status       (cmd_int_status_reg),
    .response_0       (response_0_reg),
    .response_1       (response_1_reg),
    .response_2       (response_2_reg),
    .response_3       (response_3_reg)
    );

sd_cmd_serial_host cmd_serial_host0(
    .clock            (clock),
    .clock_posedge    (clock_posedge),
    .clock_data_in    (clock_data_in),
    .reset            (reset | ctrl_rst | go_idle),
    .setting          (cmd_setting),
    .cmd              (cmd),
    .start            (cmd_start_tx),
    .finish           (cmd_finish),
    .response         (cmd_response),
    .crc_ok           (cmd_crc_ok),
    .index_ok         (cmd_index_ok),
    .cmd_i            (sd_cmd_i),
    .cmd_o            (sd_cmd_o),
    .cmd_oe           (sd_cmd_oe)
    );

sd_data_master sd_data_master0(
    .clock            (clock),
    .clock_posedge    (clock_posedge),
    .reset            (reset | ctrl_rst),
    .start_tx         (data_start_tx),
    .start_rx         (data_start_rx),
    .timeout          (data_timeout_reg),
    .d_write          (d_write),
    .d_read           (d_read),
    .en_tx_fifo       (en_tx_fifo),
    .en_rx_fifo       (en_rx_fifo),
    .fifo_empty       (fifo_empty),
    .fifo_ready       (fifo_ready),
    .fifo_full        (fifo_full),
    .bus_cycle        (m_axi_cyc || m_axi_bresp_cnt != 0),
    .xfr_complete     (!data_busy),
    .crc_error        (!data_crc_ok),
    .bus_error        (m_bus_error),
    .int_status       (data_int_status),
    .int_status_rst   (data_int_rst)
    );

sd_data_serial_host sd_data_serial_host0(
    .clock            (clock),
    .clock_posedge    (clock_posedge),
    .clock_data_in    (clock_data_in),
    .reset            (reset | ctrl_rst),
    .data_in          (fifo_dout),
    .rd               (tx_fifo_re),
    .data_out         (data_in_rx_fifo),
    .we               (rx_fifo_we),
    .dat_oe           (sd_dat_oe),
    .dat_o            (sd_dat_o),
    .dat_i            (sd_dat_i),
    .blksize          (block_size_reg),
    .bus_4bit         (controller_setting_reg[0]),
    .blkcnt           (block_count_reg),
    .start            ({d_read, d_write}),
    .byte_alignment   (dma_addr_reg[1:0]),
    .sd_data_busy     (sd_data_busy),
    .busy             (data_busy),
    .crc_ok           (data_crc_ok)
    );

assign interrupt =
    |(cmd_int_status_reg & cmd_int_enable_reg) ||
    |(data_int_status_reg & data_int_enable_reg) ||
    (sd_insert_int & sd_insert_ie) ||
    (sd_remove_int & sd_remove_ie);

endmodule
