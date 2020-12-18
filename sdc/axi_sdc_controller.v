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

module sdc_controller (
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
    output reg  [31:0] m_axi_awaddr,
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
    output reg  [31:0] m_axi_araddr,
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
wire [31:0] data_out_tx_fifo;
wire start_tx_fifo;
wire start_rx_fifo;
wire tx_fifo_empty;
wire tx_fifo_ready;
wire rx_fifo_empty;
wire rx_fifo_full;
wire sd_data_busy;
wire data_busy;
wire data_crc_ok;
wire tx_fifo_re;
wire rx_fifo_we;

wire data_start_rx;
wire data_start_tx;
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
reg  [31:0] dma_addr_reg;
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

parameter sdio_card_detect_level = 1;
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

parameter voltage_controll_reg = `SUPPLY_VOLTAGE_mV;
parameter capabilies_reg = 16'b0000_0000_0000_0011;

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
                    `capa         : s_axi_rdata <= capabilies_reg;
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
                    `dst_src_addr : s_axi_rdata <= dma_addr_reg;
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
                    `dst_src_addr : dma_addr_reg <= write_data;
                endcase
            end
            s_axi_bresp <= 0;
            s_axi_bvalid <= 1;
            wr_req <= 0;
        end
    end
end

// ------ AXI Master Interface

// AXI transaction (DDR access) is over 80 clock cycles
// Must use burst to achive required throughput

parameter fifo_addr_bits = 6;

wire m_bus_we_o;
wire m_bus_stb_o;
wire m_bus_last_i;
wire m_bus_ack_i;
reg m_axi_cyc;
reg m_axi_write;
reg [fifo_addr_bits-1:0] m_axi_wcnt;
wire [31:2] m_bus_adr_o;
wire [31:0] m_bus_dat_o;
wire [31:0] m_bus_dat_i;
wire [fifo_addr_bits-1:0] tx_fifo_free_len;
wire [fifo_addr_bits-1:0] rx_fifo_data_len;

assign m_axi_bready = m_axi_cyc & m_axi_write;
assign m_axi_rready = m_axi_cyc & !m_axi_write;
assign m_bus_last_i = m_axi_write ? m_axi_wlast : m_axi_rlast;
assign m_bus_ack_i = m_axi_write ? (m_axi_wready & m_axi_wvalid) : (m_axi_rready & m_axi_rvalid);
assign m_bus_dat_i = {m_axi_rdata[7:0],m_axi_rdata[15:8],m_axi_rdata[23:16],m_axi_rdata[31:24]};
assign m_axi_wdata = {m_bus_dat_o[7:0],m_bus_dat_o[15:8],m_bus_dat_o[23:16],m_bus_dat_o[31:24]};

// AXI burst cannot cross a 4KB boundary
wire [fifo_addr_bits-1:0] tx_burst_len;
wire [fifo_addr_bits-1:0] rx_burst_len;
assign tx_burst_len = m_bus_adr_o[11:2] + tx_fifo_free_len >= m_bus_adr_o[11:2] ? tx_fifo_free_len - 1 : ~m_bus_adr_o[fifo_addr_bits+1:2];
assign rx_burst_len = m_bus_adr_o[11:2] + rx_fifo_data_len >= m_bus_adr_o[11:2] ? rx_fifo_data_len - 1 : ~m_bus_adr_o[fifo_addr_bits+1:2];

assign data_int_status_reg = { data_int_status[`INT_DATA_SIZE-1:1],
    !m_bus_stb_o & !m_axi_cyc & rx_fifo_empty & data_int_status[0] };

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
            if (m_axi_wlast)
                m_axi_wvalid <= 0;
            else begin
                m_axi_wlast <= m_axi_wcnt + 1 == m_axi_awlen;
                m_axi_wcnt <= m_axi_wcnt + 1;
            end
        end
        if (m_axi_bvalid || (m_axi_rvalid && m_axi_rlast)) begin
            m_axi_cyc <= 0;
        end
    end else if (m_bus_stb_o) begin
        m_axi_cyc <= 1;
        m_axi_wcnt <= 0;
        m_axi_write <= m_bus_we_o;
        if (m_bus_we_o) begin
            m_axi_awaddr <= { m_bus_adr_o, 2'b00 };
            m_axi_awlen <= rx_burst_len;
            m_axi_wlast <= rx_burst_len == 0;
            m_axi_awvalid <= 1;
            m_axi_wvalid <= 1;
        end else begin
            m_axi_araddr <= { m_bus_adr_o, 2'b00 };
            m_axi_arlen <= tx_burst_len;
            m_axi_arvalid <= 1;
        end
    end
end

axi_sd_fifo_filler #(.fifo_addr_bits(fifo_addr_bits)) sd_fifo_filler0(
    .clock     (clock),
    .clock_posedge (clock_posedge),
    .reset     (reset | ctrl_rst),
    .bus_adr_o (m_bus_adr_o),
    .bus_dat_o (m_bus_dat_o),
    .bus_dat_i (m_bus_dat_i),
    .bus_stb_o (m_bus_stb_o),
    .bus_last_i(m_bus_last_i),
    .bus_ack_i (m_bus_ack_i),
    .bus_we_o  (m_bus_we_o),
    .en_rx_i   (start_rx_fifo),
    .en_tx_i   (start_tx_fifo),
    .adr_i     (dma_addr_reg[31:2]),
    .dat_i     (data_in_rx_fifo),
    .dat_o     (data_out_tx_fifo),
    .wr_i      (rx_fifo_we),
    .rd_i      (tx_fifo_re),
    .tx_free   (tx_fifo_free_len),
    .rx_data   (rx_fifo_data_len),
    .tx_empty_o(tx_fifo_empty), // HOST -> SD empty
    .rx_full_o (rx_fifo_full),  // SD -> HOST full
    .rx_empty_o(rx_fifo_empty), // SD -> HOST empty
    .tx_ready_o(tx_fifo_ready)  // HOST -> SD has enough data to start transmission
    );

sd_cmd_master sd_cmd_master0(
    .clock        (clock),
    .clock_posedge (clock_posedge),
    .rst          (reset | ctrl_rst),
    .start_i      (cmd_start),
    .int_status_rst_i(cmd_int_rst),
    .setting_o    (cmd_setting),
    .start_xfr_o  (cmd_start_tx),
    .go_idle_o    (go_idle),
    .cmd_o        (cmd),
    .response_i   (cmd_response),
    .crc_ok_i     (cmd_crc_ok),
    .index_ok_i   (cmd_index_ok),
    .busy_i       (sd_data_busy),
    .finish_i     (cmd_finish),
    .argument_i   (argument_reg),
    .command_i    (command_reg),
    .timeout_i    (cmd_timeout_reg),
    .int_status_o (cmd_int_status_reg),
    .response_0_o (response_0_reg),
    .response_1_o (response_1_reg),
    .response_2_o (response_2_reg),
    .response_3_o (response_3_reg)
    );

sd_cmd_serial_host cmd_serial_host0(
    .clock      (clock),
    .clock_posedge (clock_posedge),
    .clock_data_in (clock_data_in),
    .rst        (reset | ctrl_rst | go_idle),
    .setting_i  (cmd_setting),
    .cmd_i      (cmd),
    .start_i    (cmd_start_tx),
    .finish_o   (cmd_finish),
    .response_o (cmd_response),
    .crc_ok_o   (cmd_crc_ok),
    .index_ok_o (cmd_index_ok),
    .cmd_dat_i  (sd_cmd_i),
    .cmd_out_o  (sd_cmd_o),
    .cmd_oe_o   (sd_cmd_oe)
    );

sd_data_master sd_data_master0(
    .clock            (clock),
    .clock_posedge    (clock_posedge),
    .rst              (reset | ctrl_rst),
    .start_tx_i       (data_start_tx),
    .start_rx_i       (data_start_rx),
    .timeout_i        (data_timeout_reg),
    .d_write_o        (d_write),
    .d_read_o         (d_read),
    .start_tx_fifo_o  (start_tx_fifo),
    .start_rx_fifo_o  (start_rx_fifo),
    .tx_fifo_empty_i  (tx_fifo_empty),
    .tx_fifo_ready_i  (tx_fifo_ready),
    .rx_fifo_full_i   (rx_fifo_full),
    .xfr_complete_i   (!data_busy),
    .crc_ok_i         (data_crc_ok),
    .int_status_o     (data_int_status),
    .int_status_rst_i (data_int_rst)
    );

sd_data_serial_host sd_data_serial_host0(
    .clock          (clock),
    .clock_posedge  (clock_posedge),
    .clock_data_in  (clock_data_in),
    .rst            (reset | ctrl_rst),
    .data_in        (data_out_tx_fifo),
    .rd             (tx_fifo_re),
    .data_out       (data_in_rx_fifo),
    .we             (rx_fifo_we),
    .DAT_oe_o       (sd_dat_oe),
    .DAT_dat_o      (sd_dat_o),
    .DAT_dat_i      (sd_dat_i),
    .blksize        (block_size_reg),
    .bus_4bit       (controller_setting_reg[0]),
    .blkcnt         (block_count_reg),
    .start          ({d_read, d_write}),
    .byte_alignment (dma_addr_reg),
    .sd_data_busy   (sd_data_busy),
    .busy           (data_busy),
    .crc_ok         (data_crc_ok)
    );

sd_data_xfer_trig sd_data_xfer_trig0 (
    .clock                 (clock),
    .clock_posedge         (clock_posedge),
    .rst                   (reset | ctrl_rst),
    .cmd_with_data_start_i (cmd_start & (command_reg[`CMD_WITH_DATA] != 2'b00)),
    .r_w_i                 (command_reg[`CMD_WITH_DATA] == 2'b01),
    .cmd_int_status_i      (cmd_int_status_reg),
    .start_tx_o            (data_start_tx),
    .start_rx_o            (data_start_rx)
    );

assign interrupt =
    |(cmd_int_status_reg & cmd_int_enable_reg) ||
    |(data_int_status_reg & data_int_enable_reg) ||
    (sd_insert_int & sd_insert_ie) ||
    (sd_remove_int & sd_remove_ie);

endmodule
