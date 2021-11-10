/*

Copyright (c) 2020-2021 Eugene Tarassov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

module ethernet #(
    parameter burst_size = 16,
    parameter dma_word_bits = 32,
    parameter dma_addr_bits = 32,
    parameter axis_word_bits = 8,
    parameter enable_mdio = 1
) (
    input wire async_resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    output wire reset,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXI:S_AXI_LITE:TX_AXIS:RX_AXIS" *)
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

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock, ID_WIDTH 0, PROTOCOL AXI4" *)
    output reg  [dma_addr_bits-1:0] m_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *)
    output reg  [7:0] m_axi_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *)
    output reg  m_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *)
    input wire m_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *)
    output wire [dma_word_bits-1:0] m_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *)
    output wire [dma_word_bits/8-1:0] m_axi_wstrb,
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
    input wire [dma_word_bits-1:0] m_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RLAST" *)
    input wire m_axi_rlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *)
    input wire [1:0] m_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *)
    input wire m_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *)
    output wire m_axi_rready,

    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY LEVEL_HIGH" *)
    output wire interrupt,

    input wire [15:0]status_vector,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
    output wire [axis_word_bits-1:0] tx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TKEEP" *)
    output wire [axis_word_bits/8-1:0] tx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TVALID" *)
    output wire tx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TREADY" *)
    input wire tx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TLAST" *)
    output wire tx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TUSER" *)
    output wire tx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TDATA" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
    input wire [axis_word_bits-1:0] rx_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TKEEP" *)
    input wire [axis_word_bits/8-1:0] rx_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TVALID" *)
    input wire rx_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TREADY" *)
    output wire rx_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TLAST" *)
    input wire rx_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 RX_AXIS TUSER" *)
    input wire rx_axis_tuser,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 mdio_clock CLK" *)
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 2500000" *)
    output reg mdio_clock,  // PHY MII Management clock
    inout wire mdio_data,   // PHY MII Management data
    output wire mdio_reset, // PHY reset
    input wire mdio_int     // PHY interrupt

);

`default_nettype none

(* ASYNC_REG="true" *)
reg  [2:0] reset_sync;
assign reset = !reset_sync[2];

always @(posedge clock)
    reset_sync <= {reset_sync[1:0], async_resetn};

`define burst_size_log2 $clog2(burst_size)

`define dma_word_bytes (dma_word_bits / 8)
`define dma_word_log2 $clog2(`dma_word_bytes)

`define axis_word_bytes (axis_word_bits / 8)
`define axis_word_log2 $clog2(`axis_word_bytes)

`define pkt_addr_bits_range dma_addr_bits-1:0
`define pkt_size_bits_range 13:0

// ------ AXI LITE Slave Interface

`define pkt_ptr_bits 4 /* max is 6 */
`define pkt_ptr_max ((1 << `pkt_ptr_bits) - 1)
`define min_burst (1 << (`burst_size_log2 - 1))

reg rd_req;
reg [1:0] wr_req;
reg [11:0] read_addr;
reg [11:0] write_addr;
reg [31:0] write_data;
wire [`pkt_ptr_bits-1:0] read_pkt_no = read_addr[4+:`pkt_ptr_bits];
wire [`pkt_ptr_bits-1:0] write_pkt_no = write_addr[4+:`pkt_ptr_bits];

assign s_axi_arready = !rd_req && !s_axi_rvalid;
assign s_axi_awready = !wr_req[0] && !s_axi_bvalid;
assign s_axi_wready = !wr_req[1] && !s_axi_bvalid;

reg [`pkt_ptr_bits-1:0] rx_pkt_inp;
reg [`pkt_ptr_bits-1:0] rx_pkt_out;
reg [`pkt_addr_bits_range] rx_addr[`pkt_ptr_max:0];
reg [`pkt_size_bits_range] rx_size[`pkt_ptr_max:0];
reg [`pkt_size_bits_range] rx_done[`pkt_ptr_max:0];
reg [1:0] rx_status[`pkt_ptr_max:0];

reg [`pkt_ptr_bits-1:0] tx_pkt_inp;
reg [`pkt_ptr_bits-1:0] tx_pkt_out;
reg [`pkt_addr_bits_range] tx_addr[`pkt_ptr_max:0];
reg [`pkt_size_bits_range] tx_size[`pkt_ptr_max:0];

reg rx_enable;
reg tx_enable;
reg rx_start;
reg tx_start;
reg rx_axis_start;
reg tx_axis_start;
reg rx_axis_stop;
reg rx_bad_frame;
reg tx_axis_stop;
reg rx_m_axi_stop;
reg tx_m_axi_stop;
reg rx_int;
reg tx_int;

reg [31:0] int_enable;
wire [31:0] int_status;

reg mdio_start;
reg mdio_done;
reg [31:0] mdio_tx = 0;
reg [31:0] mdio_rx = 0;
wire mdio_phy_int;
wire mdio_txrx_int;
reg mdio_reset_reg;

reg m_axi_rd_cyc;
reg m_axi_rd_err;
reg m_axi_wr_cyc;
reg m_axi_wr_err;

assign int_status = { mdio_phy_int, mdio_txrx_int, tx_int, rx_int, status_vector };
assign interrupt = (int_enable & int_status) != 0;

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
        rx_pkt_inp <= 0;
        rx_pkt_out <= 0;
        tx_pkt_inp <= 0;
        tx_pkt_out <= 0;
        rx_enable <= 0;
        tx_enable <= 0;
        rx_start <= 0;
        tx_start <= 0;
        int_enable <= 0;
        mdio_tx <= 0;
        mdio_start <= 0;
        mdio_reset_reg <= 0;
    end else begin
        if (s_axi_arready && s_axi_arvalid) begin
            read_addr <= s_axi_araddr;
            rd_req <= 1;
        end
        if (s_axi_rvalid && s_axi_rready) begin
            s_axi_rvalid <= 0;
        end else if (!s_axi_rvalid && rd_req) begin
            s_axi_rdata <= 0;
            if (read_addr[11:10] == 0) begin
                case (read_addr[9:0])
                10'h000: s_axi_rdata <= status_vector;
                10'h004: s_axi_rdata <= { m_axi_rd_err, m_axi_rd_cyc, m_axi_wr_err, m_axi_wr_cyc, tx_start, rx_start };
                10'h008: s_axi_rdata <= int_enable;
                10'h00c: s_axi_rdata <= int_status;
                10'h010: s_axi_rdata <= rx_pkt_inp;
                10'h014: s_axi_rdata <= rx_pkt_out;
                10'h018: s_axi_rdata <= tx_pkt_inp;
                10'h01c: s_axi_rdata <= tx_pkt_out;
                10'h020: s_axi_rdata <= { mdio_reset_reg, tx_enable, rx_enable };
                10'h024: s_axi_rdata <= mdio_tx;
                10'h028: s_axi_rdata <= mdio_rx;
                10'h02c: begin
                  s_axi_rdata[15:10] <= dma_addr_bits;
                  s_axi_rdata[8] <= enable_mdio;
                  s_axi_rdata[7:4] <= `pkt_ptr_bits;
                  s_axi_rdata[3:0] <= `burst_size_log2;
                end
                endcase
            end else if (read_addr[11:10] == 2) begin
                case (read_addr[3:0])
                4'h00: s_axi_rdata <= rx_addr[read_pkt_no];
                4'h04: begin
                  s_axi_rdata[15:0] <= rx_size[read_pkt_no];
                  if (dma_addr_bits > 32) s_axi_rdata[31:16] <= rx_addr[read_pkt_no][dma_addr_bits-1:32];
                end
                4'h08: s_axi_rdata <= rx_done[read_pkt_no];
                4'h0c: s_axi_rdata <= rx_status[read_pkt_no];
                endcase
            end else if (read_addr[11:10] == 3) begin
                case (read_addr[3:0])
                4'h00: s_axi_rdata <= tx_addr[read_pkt_no];
                4'h04: begin
                  s_axi_rdata[15:0] <= tx_size[read_pkt_no];
                  if (dma_addr_bits > 32) s_axi_rdata[31:16] <= tx_addr[read_pkt_no][dma_addr_bits-1:32];
                end
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
            if (write_addr[11:10] == 0) begin
                case (write_addr[9:0])
                10'h008: int_enable <= write_data;
                10'h00c: begin rx_int <= write_data[16]; tx_int <= write_data[17]; end
                10'h010: rx_pkt_inp <= write_data;
                10'h014: if (!rx_enable) rx_pkt_out <= write_data;
                10'h018: tx_pkt_inp <= write_data;
                10'h01c: if (!tx_enable) tx_pkt_out <= write_data;
                10'h020: begin rx_enable <= write_data[0]; tx_enable <= write_data[1]; mdio_reset_reg <= write_data[2]; end
                10'h024: if (enable_mdio) begin mdio_tx <= write_data; mdio_start <= 1; end
                endcase
            end else if (write_addr[11:10] == 2) begin
                case (write_addr[3:0])
                4'h00: rx_addr[write_pkt_no] <= write_data;
                4'h04: begin
                  rx_size[write_pkt_no] <= write_data;
                  if (dma_addr_bits > 32) rx_addr[write_pkt_no][dma_addr_bits-1:32] <= write_data[31:16];
                end
                endcase
            end else if (write_addr[11:10] == 3) begin
                case (write_addr[3:0])
                4'h00: tx_addr[write_pkt_no] <= write_data;
                4'h04: begin
                  tx_size[write_pkt_no] <= write_data;
                  if (dma_addr_bits > 32) tx_addr[write_pkt_no][dma_addr_bits-1:32] <= write_data[31:16];
                end
                endcase
            end
            s_axi_bresp <= 0;
            s_axi_bvalid <= 1;
            wr_req <= 0;
        end
        if (rx_enable && !rx_start && !rx_axis_stop && !rx_m_axi_stop && rx_pkt_inp != rx_pkt_out && rx_axis_tvalid) begin
            rx_start <= 1;
        end else if (rx_start && rx_axis_stop && rx_m_axi_stop) begin
            rx_start <= 0;
            rx_pkt_out <= rx_pkt_out + 1;
            rx_int <= 1;
        end
        if (tx_enable && !tx_start && !tx_axis_stop && !tx_m_axi_stop && tx_pkt_inp != tx_pkt_out && tx_axis_tready) begin
            tx_start <= 1;
        end else if (tx_start && tx_axis_stop && tx_m_axi_stop) begin
            tx_start <= 0;
            tx_pkt_out <= tx_pkt_out + 1;
            tx_int <= 1;
        end
        if (mdio_start && mdio_done) begin
            mdio_start <= 0;
        end
    end
end

// ------ AXI Master Interface, TX

reg  [dma_word_bits-1:0] tx_burst_buf [(1 << `burst_size_log2) - 1 : 0];
reg  [dma_word_bits-1:0] tx_burst_head;
reg  [`burst_size_log2-1:0] tx_burst_inp;
reg  [`burst_size_log2-1:0] tx_burst_out;
reg  tx_burst_tail;

wire [`burst_size_log2-1:0] tx_burst_inp_next = tx_burst_inp + 1;
wire [`burst_size_log2-1:0] tx_burst_out_next = tx_burst_out + 1;
wire [`burst_size_log2-1:0] tx_burst_free_len = tx_burst_out - tx_burst_inp_next;

reg  [`pkt_addr_bits_range] tx_pkt_addr;
reg  [`pkt_size_bits_range] tx_pkt_size;
reg  [`pkt_size_bits_range] tx_pkt_offs;
reg  [`pkt_size_bits_range] tx_word_left;
reg  [`dma_word_log2-1:0] tx_axis_byte_offs;

wire [`dma_word_log2-1:0] tx_axis_byte_last = (tx_pkt_size[`dma_word_log2-1:0] - `axis_word_bytes) & ~(`axis_word_bytes - 1);
wire [`dma_word_log2-1:0] tx_axis_byte_shift = tx_pkt_addr[`dma_word_log2-1:0];

wire [`pkt_addr_bits_range] tx_burst_araddr = (tx_pkt_addr + tx_pkt_offs) & ~(`dma_word_bytes - 1);
wire [`burst_size_log2-1:0] tx_burst_arlen = (tx_word_left >= tx_burst_free_len ? tx_burst_free_len : tx_word_left) - 1;

// AXI burst cannot cross a 4KB boundary
wire [`burst_size_log2-1:0] tx_burst_arlen4k = ~tx_burst_araddr[11:`dma_word_log2] >= tx_burst_arlen ? tx_burst_arlen : ~tx_burst_araddr[`burst_size_log2+`dma_word_log2-1:`dma_word_log2];

assign m_axi_rready = m_axi_rd_cyc;
assign tx_axis_tuser = 0;
assign tx_axis_tdata = tx_burst_buf[tx_burst_out][tx_axis_byte_offs*8+:axis_word_bits];
assign tx_axis_tvalid = tx_burst_inp != tx_burst_out;
assign tx_axis_tkeep = tx_axis_tlast && tx_pkt_size[`dma_word_log2-1:0] != 0 ? ~(~0 << tx_pkt_size[`dma_word_log2-1:0]) : ~0;
assign tx_axis_tlast = tx_m_axi_stop && !tx_burst_tail && (tx_burst_out_next == tx_burst_inp) && (tx_axis_byte_offs == tx_axis_byte_last);

always @(posedge clock) begin
    if (reset) begin
        m_axi_rd_cyc <= 0;
        m_axi_rd_err <= 0;
        m_axi_arvalid <= 0;
        tx_burst_inp <= 0;
        tx_burst_out <= 0;
        tx_axis_start <= 0;
        tx_axis_stop <= 0;
        tx_m_axi_stop <= 0;
        tx_burst_tail <= 0;
    end else if (!tx_start) begin
        tx_burst_inp <= 0;
        tx_burst_out <= 0;
        tx_axis_start <= 0;
        tx_axis_stop <= 0;
        tx_m_axi_stop <= 0;
    end else if (!tx_axis_start) begin
        tx_axis_byte_offs <= 0;
        tx_axis_start <= 1;
        tx_burst_tail <= 0;
        tx_pkt_addr <= tx_addr[tx_pkt_out];
        tx_pkt_size <= tx_size[tx_pkt_out];
        tx_pkt_offs <= 0;
        tx_word_left <= (tx_size[tx_pkt_out] + tx_addr[tx_pkt_out][`dma_word_log2-1:0] + (`dma_word_bytes - 1)) >> `dma_word_log2;
        m_axi_rd_err <= 0;
    end else begin
        if (tx_axis_tvalid && tx_axis_tready) begin
            tx_axis_byte_offs <= tx_axis_byte_offs + `axis_word_bytes;
            if (tx_axis_tlast) begin
                tx_burst_out <= tx_burst_out_next;
                tx_axis_stop <= 1;
            end else if (tx_axis_byte_offs == `dma_word_bytes - `axis_word_bytes) begin
                tx_burst_out <= tx_burst_out_next;
            end
        end
        if (m_axi_rd_cyc) begin
            if (m_axi_arvalid && m_axi_arready) begin
                m_axi_arvalid <= 0;
            end
            if (m_axi_rvalid && m_axi_rready) begin
                if (tx_axis_byte_shift == 0) begin
                    tx_burst_buf[tx_burst_inp] <= m_axi_rdata;
                    tx_burst_inp <= tx_burst_inp_next;
                end else begin
                    tx_burst_head <= m_axi_rdata >> tx_axis_byte_shift*8;
                    if (((tx_pkt_size - 1) & (`dma_word_bytes - 1)) < `dma_word_bytes - tx_axis_byte_shift) tx_burst_tail <= 1;
                    if (tx_pkt_offs != 0) begin
                        tx_burst_buf[tx_burst_inp] <= tx_burst_head | (m_axi_rdata << (`dma_word_bytes - tx_axis_byte_shift)*8);
                        tx_burst_inp <= tx_burst_inp_next;
                    end
                end
                if (tx_word_left <= 1) begin
                    tx_m_axi_stop <= 1;
                    tx_pkt_offs <= tx_pkt_size;
                end else if (tx_pkt_offs == 0) begin
                    tx_pkt_offs[`dma_word_log2:0] <= `dma_word_bytes - tx_pkt_addr[`dma_word_log2-1:0];
                end else begin
                    tx_pkt_offs <= tx_pkt_offs + `dma_word_bytes;
                end
                if (m_axi_rlast) m_axi_rd_cyc <= 0;
                if (m_axi_rresp) m_axi_rd_err <= 1;
                tx_word_left <= tx_word_left - 1;
            end
        end else if (tx_m_axi_stop) begin
            if (tx_burst_tail && tx_burst_free_len != 0) begin
                tx_burst_buf[tx_burst_inp] <= tx_burst_head;
                tx_burst_inp <= tx_burst_inp_next;
                tx_burst_tail <= 0;
            end
        end else if (tx_word_left >= `min_burst && tx_burst_free_len < `min_burst) begin
            // wait for more free space
        end else if (tx_burst_free_len != 0) begin
            m_axi_rd_cyc <= 1;
            m_axi_araddr <= tx_burst_araddr;
            m_axi_arlen <= tx_burst_arlen4k;
            m_axi_arvalid <= 1;
        end
    end
end

// ------ AXI Master Interface, RX

reg [`burst_size_log2-1:0] m_axi_wcnt;
reg rx_m_axi_stop0;
wire rx_m_axi_last;
wire rx_word_last;

reg  [dma_word_bits-1:0] rx_burst_buf [(1 << `burst_size_log2) - 1 : 0];
reg  [`burst_size_log2-1:0] rx_burst_inp;
reg  [`burst_size_log2-1:0] rx_burst_out;
reg  [`dma_word_log2-1:0] rx_axis_byte_offs;
reg  [`dma_word_log2-1:0] rx_axis_byte_shift;
reg  [`axis_word_bytes-1:0] rx_axis_keep;

wire [`burst_size_log2-1:0] rx_burst_inp_next = rx_burst_inp + 1;
wire [`burst_size_log2-1:0] rx_burst_out_next = rx_burst_out + 1;
wire [`burst_size_log2-1:0] rx_burst_data_len = rx_burst_inp - rx_burst_out;

// Find highest set bit in rx_axis_keep
wire [`axis_word_log2:0] rx_axis_keep_stage [0:`axis_word_bytes];
assign rx_axis_keep_stage[0] = 0;
generate genvar i;
    for (i = 0; i < `axis_word_bytes; i = i + 1) begin
        assign rx_axis_keep_stage[i + 1] = rx_axis_keep[i] ? i + 1 : rx_axis_keep_stage[i];
    end
endgenerate
wire [`axis_word_log2:0] rx_axis_keep_cnt = rx_axis_keep_stage[`axis_word_bytes] + rx_axis_byte_shift;

reg  [`pkt_addr_bits_range] rx_pkt_addr;
reg  [`pkt_size_bits_range] rx_word_left;
wire [`pkt_size_bits_range] rx_size_al;
reg  [`dma_word_bytes-1:0] rx_wstrb;
reg  [`dma_word_bytes-1:0] rx_wstrb_last;
reg  [dma_word_bits-1:0] rx_burst_tail;

wire rx_burst_1p = rx_axis_byte_shift != 0 && rx_axis_stop && rx_axis_keep_cnt > `dma_word_bytes;

assign rx_size_al = rx_size[rx_pkt_out] + rx_addr[rx_pkt_out][`dma_word_log2-1:0];
assign rx_word_last = rx_word_left <= 1;
assign m_axi_bready = m_axi_wr_cyc && !m_axi_wvalid;
assign m_axi_wdata = rx_axis_byte_shift == 0 ? rx_burst_buf[rx_burst_out] : rx_burst_tail | (rx_burst_buf[rx_burst_out] << rx_axis_byte_shift*8);
assign m_axi_wstrb = rx_wstrb & (rx_word_last ? rx_wstrb_last : ~0);
assign rx_m_axi_last = rx_axis_stop && (rx_burst_1p ? rx_burst_out == rx_burst_inp : rx_burst_out_next == rx_burst_inp);
assign rx_axis_tready = rx_axis_start && !rx_axis_stop && (rx_burst_inp_next != rx_burst_out || rx_m_axi_stop);

wire [`pkt_addr_bits_range] rx_burst_awaddr = rx_pkt_addr & ~(`dma_word_bytes - 1);
wire [`burst_size_log2-1:0] rx_burst_awlen = rx_word_left >= rx_burst_data_len ? rx_burst_data_len : rx_word_left;

wire [`burst_size_log2-1:0] rx_burst_awlen1p = rx_burst_1p ? rx_burst_awlen : rx_burst_awlen - 1;

// AXI burst cannot cross a 4KB boundary
wire [`burst_size_log2-1:0] rx_burst_awlen4k = ~rx_burst_awaddr[11:`dma_word_log2] >= rx_burst_awlen1p ? rx_burst_awlen1p : ~rx_burst_awaddr[`burst_size_log2+`dma_word_log2-1:`dma_word_log2];

always @(posedge clock) begin
    // RX DMA
    if (reset) begin
        m_axi_wr_cyc <= 0;
        m_axi_wr_err <= 0;
        m_axi_awvalid <= 0;
        m_axi_wvalid <= 0;
        rx_m_axi_stop0 <= 0;
        rx_m_axi_stop <= 0;
        rx_burst_inp <= 0;
        rx_burst_out <= 0;
        rx_axis_start <= 0;
        rx_axis_stop <= 0;
        rx_bad_frame <= 0;
    end else if (!rx_start) begin
        rx_burst_inp <= 0;
        rx_burst_out <= 0;
        rx_axis_start <= 0;
        rx_axis_stop <= 0;
        rx_m_axi_stop0 <= 0;
        rx_m_axi_stop <= 0;
    end else if (!rx_axis_start) begin
        rx_axis_byte_offs <= `axis_word_bytes > 1 ? 0 : rx_addr[rx_pkt_out][`dma_word_log2-1:0];
        rx_axis_start <= 1;
        rx_done[rx_pkt_out] <= 0;
        rx_status[rx_pkt_out] <= 1;
        rx_wstrb <= ~0 << rx_addr[rx_pkt_out][`dma_word_log2-1:0];
        rx_wstrb_last <= ~(rx_size_al[`dma_word_log2-1:0] == 0 ? 0 : (~0 << (rx_size_al[`dma_word_log2-1:0])));
        rx_word_left <= (rx_size_al + (`dma_word_bytes - 1)) >> `dma_word_log2;
        rx_axis_byte_shift <= `axis_word_bytes > 1 ? rx_addr[rx_pkt_out][`dma_word_log2-1:0] : 0;
        rx_pkt_addr <= rx_addr[rx_pkt_out];
        rx_burst_tail <= 0;
        rx_bad_frame <= 1;
        m_axi_wr_err <= 0;
    end else begin
        if (rx_axis_tvalid && rx_axis_tready) begin
            rx_burst_buf[rx_burst_inp][rx_axis_byte_offs*8+:axis_word_bits] <= rx_axis_tdata;
            if (rx_axis_tlast) begin
                rx_burst_inp <= rx_burst_inp_next;
                rx_axis_keep <= rx_axis_tkeep;
                rx_bad_frame <= rx_axis_tuser;
                rx_axis_stop <= 1;
            end else if (rx_axis_byte_offs >= `dma_word_bytes - `axis_word_bytes) begin
                rx_axis_byte_offs <= 0;
                rx_burst_inp <= rx_burst_inp_next;
            end else begin
                rx_axis_byte_offs <= rx_axis_byte_offs + `axis_word_bytes;
            end
        end
        if (m_axi_wr_cyc) begin
            if (m_axi_awvalid && m_axi_awready) begin
                m_axi_awvalid <= 0;
            end
            if (m_axi_bvalid && m_axi_bready) begin
                m_axi_wr_cyc <= 0;
                if (m_axi_bresp) m_axi_wr_err <= 1;
                if (rx_m_axi_stop0) rx_m_axi_stop <= 1;
                rx_done[rx_pkt_out] <= rx_pkt_addr - rx_addr[rx_pkt_out];
                rx_status[rx_pkt_out] <= { m_axi_wr_err, rx_bad_frame };
            end
            if (m_axi_wvalid && m_axi_wready) begin
                if (rx_burst_data_len != 0) begin
                    rx_burst_tail <= rx_burst_buf[rx_burst_out] >> (`dma_word_bytes - rx_axis_byte_shift)*8;
                    rx_burst_out <= rx_burst_out_next;
                end
                if (m_axi_wlast) begin
                    m_axi_wvalid <= 0;
                    m_axi_wlast <= 0;
                end else begin
                    m_axi_wlast <= m_axi_wcnt + 1 == m_axi_awlen;
                    m_axi_wcnt <= m_axi_wcnt + 1;
                end
                if (!rx_m_axi_last) rx_pkt_addr <= rx_burst_awaddr + `dma_word_bytes;
                else rx_pkt_addr <= rx_pkt_addr + rx_axis_byte_offs + rx_axis_keep_cnt - (rx_burst_1p ? `dma_word_bytes : 0);
                if (rx_m_axi_last || rx_word_last) begin
                    rx_m_axi_stop0 <= 1;
                    rx_wstrb <= 0;
                end else begin
                    rx_wstrb <= ((1 << `dma_word_bytes) - 1);
                end
                rx_word_left <= rx_word_left - 1;
            end
        end else if (!rx_axis_stop && rx_burst_data_len < `min_burst) begin
            // wait for more data
        end else if ((rx_burst_data_len != 0 || rx_burst_1p) && !rx_m_axi_stop) begin
            m_axi_wcnt <= 0;
            m_axi_wr_cyc <= 1;
            m_axi_awaddr <= rx_burst_awaddr;
            m_axi_awlen <= rx_burst_awlen4k;
            m_axi_wlast <= rx_burst_awlen4k == 0;
            m_axi_awvalid <= 1;
            m_axi_wvalid <= 1;
        end
    end
end

// ------ PHY MDIO Interface

generate if (enable_mdio) begin

    wire mdio_i;
    reg mdio_o;
    reg mdio_t;
    IOBUF mdio(.O(mdio_i), .IO(mdio_data), .I(mdio_o), .T(mdio_t));

    (* ASYNC_REG="true" *)
    reg  [2:0] mdio_int_sync;
    assign mdio_phy_int = mdio_int_sync[2];
    assign mdio_txrx_int = !(mdio_start || mdio_done);

    always @(posedge clock)
        mdio_int_sync <= {mdio_int_sync[1:0], mdio_int};

    assign mdio_reset = !mdio_reset_reg;

    reg mdio_stop;
    reg [5:0] mdio_cnt;
    reg [5:0] mdio_cnt_rx;
    reg [4:0] mdio_div;

    always @(posedge clock) begin
        if (reset) begin
            mdio_rx <= 0;
            mdio_stop <= 0;
            mdio_done <= 0;
            mdio_cnt <= 0;
            mdio_cnt_rx <= 0;
            mdio_div <= 0;
            mdio_t <= 1;
            mdio_o <= 1;
            mdio_clock <= 0;
        end else if (!mdio_start) begin
            mdio_stop <= 0;
            mdio_done <= 0;
            mdio_cnt <= 0;
            mdio_cnt_rx <= 0;
            mdio_div <= 0;
            mdio_t <= 1;
            mdio_o <= 1;
            mdio_clock <= 0;
        end else if (mdio_done) begin
            // Waiting for handshake
        end else if (mdio_div == 0) begin
            mdio_div <= 24;
            mdio_cnt_rx <= mdio_cnt;
            if (!mdio_clock) begin
                if (mdio_cnt_rx[5]) mdio_rx[~mdio_cnt_rx[4:0]] <= mdio_i;
                mdio_clock <= 1;
            end else if (mdio_stop) begin
                mdio_done <= 1;
                mdio_t <= 0;
                mdio_o <= 1;
                mdio_clock <= 0;
            end else begin
                if (!mdio_cnt[5]) begin
                    // PHY devices require a preamble of 32 ones
                    mdio_t <= 0;
                    mdio_o <= 1;
                end else begin
                    if (mdio_tx[29] && mdio_cnt >= 46) begin
                        // Read from PHY
                        mdio_t <= 1;
                    end else begin
                        // Write to PHY
                        mdio_t <= 0;
                    end
                    mdio_o <= mdio_tx[~mdio_cnt[4:0]];
                end
                if (mdio_cnt == 63) begin
                    mdio_stop <= 1;
                    mdio_cnt <= 0;
                end else begin
                    mdio_cnt <= mdio_cnt + 1;
                end
                mdio_clock <= 0;
            end
        end else begin
            mdio_div <= mdio_div - 1;
        end
    end

end else begin

    assign mdio_reset = 0;
    assign mdio_phy_int = 0;
    assign mdio_txrx_int = 0;
    always @(posedge clock) begin
        mdio_done <= 0;
        mdio_clock <= 0;
    end

end endgenerate

endmodule
