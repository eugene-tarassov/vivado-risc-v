/*

Copyright (c) 2020 Eugene Tarassov

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

module ethernet #(parameter burst_size_bits = 4) (
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
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock, ID_WIDTH 0, PROTOCOL AXI4, DATA_WIDTH 32" *)
    output reg  [31:0] m_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *)
    output reg  [7:0] m_axi_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *)
    output reg  m_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *)
    input wire m_axi_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *)
    output wire [31:0] m_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *)
    output reg [3:0] m_axi_wstrb,
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

    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY LEVEL_HIGH" *)
    output wire interrupt,

    input wire [15:0]status_vector,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 TX_AXIS TDATA" *)
    (* X_INTERFACE_PARAMETER = "CLK_DOMAIN clock" *)
    output wire [7:0] tx_axis_tdata,
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
    input wire [7:0] rx_axis_tdata,
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

(* ASYNC_REG="true" *)
reg  [2:0] reset_sync;
assign reset = reset_sync[2];

always @(posedge clock)
    reset_sync <= {reset_sync[1:0], !async_resetn};

wire pcspma_status_link_status              = status_vector[0];
wire pcspma_status_link_synchronization     = status_vector[1];
wire pcspma_status_rudi_c                   = status_vector[2];
wire pcspma_status_rudi_i                   = status_vector[3];
wire pcspma_status_rudi_invalid             = status_vector[4];
wire pcspma_status_rxdisperr                = status_vector[5];
wire pcspma_status_rxnotintable             = status_vector[6];
wire pcspma_status_phy_link_status          = status_vector[7];
wire [1:0] pcspma_status_remote_fault_encdg = status_vector[9:8];
wire [1:0] pcspma_status_speed              = status_vector[11:10];
wire pcspma_status_duplex                   = status_vector[12];
wire pcspma_status_remote_fault             = status_vector[13];
wire [1:0] pcspma_status_pause              = status_vector[15:14];

wire mdio_i;
reg mdio_o;
reg mdio_t;
IOBUF mdio(.O(mdio_i), .IO(mdio_data), .I(mdio_o), .T(mdio_t));

reg  [2:0] mdio_int_sync;
wire mdio_phy_int = mdio_int_sync[2];

always @(posedge clock)
    mdio_int_sync <= {mdio_int_sync[1:0], mdio_int};

reg mdio_reset_reg;
assign mdio_reset = !mdio_reset_reg;

// ------ AXI LITE Slave Interface

reg [11:0] read_addr;
reg [11:0] write_addr;
reg [31:0] write_data;
reg rd_req;
reg [1:0] wr_req;

assign s_axi_arready = !rd_req && !s_axi_rvalid;
assign s_axi_awready = !wr_req[0] && !s_axi_bvalid;
assign s_axi_wready = !wr_req[1] && !s_axi_bvalid;

`define pkt_ptr_bits 4
`define pkt_ptr_max ((1 << `pkt_ptr_bits) - 1)
`define min_burst (1 << (burst_size_bits - 1))

reg [`pkt_ptr_bits-1:0] rx_pkt_inp;
reg [`pkt_ptr_bits-1:0] rx_pkt_out;
reg [31:0] rx_addr[`pkt_ptr_max:0];
reg [13:0] rx_size[`pkt_ptr_max:0];
reg [13:0] rx_done[`pkt_ptr_max:0];
reg [1:0] rx_status[`pkt_ptr_max:0];

reg [`pkt_ptr_bits-1:0] tx_pkt_inp;
reg [`pkt_ptr_bits-1:0] tx_pkt_out;
reg [31:0] tx_addr[`pkt_ptr_max:0];
reg [13:0] tx_size[`pkt_ptr_max:0];

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

reg [31:0] mdio_tx;
reg [31:0] mdio_rx;
reg mdio_start;
reg mdio_stop;
reg mdio_done;
reg [5:0] mdio_cnt;
reg [5:0] mdio_cnt_rx;
reg [4:0] mdio_div;
wire mdio_txrx_int = !(mdio_start || mdio_done);

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
                10'h02c: begin s_axi_rdata[8] <= 1; s_axi_rdata[7:4] <= `pkt_ptr_bits; s_axi_rdata[3:0] <= burst_size_bits; end
                endcase
            end else if (read_addr[11:10] == 2) begin
                case (read_addr[3:0])
                4'h00: s_axi_rdata <= rx_addr[read_addr[4+:`pkt_ptr_bits]];
                4'h04: s_axi_rdata <= rx_size[read_addr[4+:`pkt_ptr_bits]];
                4'h08: s_axi_rdata <= rx_done[read_addr[4+:`pkt_ptr_bits]];
                4'h0c: s_axi_rdata <= rx_status[read_addr[4+:`pkt_ptr_bits]];
                endcase
            end else if (read_addr[11:10] == 3) begin
                case (read_addr[3:0])
                4'h00: s_axi_rdata <= tx_addr[read_addr[4+:`pkt_ptr_bits]];
                4'h04: s_axi_rdata <= tx_size[read_addr[4+:`pkt_ptr_bits]];
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
                10'h018: tx_pkt_inp <= write_data;
                10'h020: begin rx_enable <= write_data[0]; tx_enable <= write_data[1]; mdio_reset_reg <= write_data[2]; end
                10'h024: begin mdio_tx <= write_data; mdio_start <= 1; end
                endcase
            end else if (write_addr[11:10] == 2) begin
                case (write_addr[3:0])
                4'h00: rx_addr[write_addr[4+:`pkt_ptr_bits]] <= write_data;
                4'h04: rx_size[write_addr[4+:`pkt_ptr_bits]] <= write_data;
                endcase
            end else if (write_addr[11:10] == 3) begin
                case (write_addr[3:0])
                4'h00: tx_addr[write_addr[4+:`pkt_ptr_bits]] <= write_data;
                4'h04: tx_size[write_addr[4+:`pkt_ptr_bits]] <= write_data;
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

reg  [31:0] tx_burst_buf [(1 << burst_size_bits) - 1 : 0];
reg  [burst_size_bits-1:0] tx_burst_inp;
reg  [burst_size_bits-1:0] tx_burst_out;
reg  [1:0] tx_axis_byte;

wire [burst_size_bits-1:0] tx_burst_inp_next;
wire [burst_size_bits-1:0] tx_burst_out_next;
wire [burst_size_bits-1:0] tx_burst_free_len;
wire [burst_size_bits-1:0] tx_burst_arlen;
wire [burst_size_bits-1:0] tx_burst_arlen4k;
wire [31:0] tx_burst_araddr;

reg  [31:0] tx_pkt_addr;
reg  [13:0] tx_pkt_size;
reg  [13:0] tx_pkt_offs;
reg  [13:0] tx_word_left;

assign m_axi_rready = m_axi_rd_cyc;
assign tx_burst_inp_next = tx_burst_inp + 1;
assign tx_burst_out_next = tx_burst_out + 1;
assign tx_burst_free_len = tx_burst_out - tx_burst_inp_next;
assign tx_axis_tuser = 0;
assign tx_axis_tdata = tx_burst_buf[tx_burst_out][tx_axis_byte*8+:8];
assign tx_axis_tvalid = tx_burst_inp != tx_burst_out;
assign tx_axis_tlast = tx_m_axi_stop &&
                    (tx_burst_out_next == tx_burst_inp) &&
                    (tx_axis_byte == (tx_pkt_addr[1:0] + tx_pkt_size[1:0] - 2'd1));

assign tx_burst_araddr = (tx_pkt_addr + tx_pkt_offs) & ~32'h3;
assign tx_burst_arlen = (tx_word_left >= tx_burst_free_len ? tx_burst_free_len : tx_word_left) - 1;

// AXI burst cannot cross a 4KB boundary
assign tx_burst_arlen4k = ~tx_burst_araddr[11:2] >= tx_burst_arlen ? tx_burst_arlen : ~tx_burst_araddr[burst_size_bits+1:2];

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
    end else begin
        if (!tx_start) begin
            tx_burst_inp <= 0;
            tx_burst_out <= 0;
            tx_axis_start <= 0;
            tx_axis_stop <= 0;
        end else if (!tx_axis_start) begin
            tx_axis_byte <= tx_addr[tx_pkt_out][1:0];
            tx_axis_start <= 1;
        end else if (tx_axis_tvalid && tx_axis_tready) begin
            tx_axis_byte <= tx_axis_byte + 1;
            if (tx_axis_tlast) begin
                tx_burst_out <= tx_burst_out_next;
                tx_axis_stop <= 1;
            end else if (tx_axis_byte == 2'h3) begin
                tx_burst_out <= tx_burst_out_next;
            end
        end
        if (!tx_start) begin
            tx_m_axi_stop <= 0;
        end else if (!tx_axis_start) begin
            m_axi_rd_err <= 0;
            tx_pkt_addr <= tx_addr[tx_pkt_out];
            tx_pkt_size <= tx_size[tx_pkt_out];
            tx_pkt_offs <= 0;
            tx_word_left <= (tx_size[tx_pkt_out] + tx_addr[tx_pkt_out][1:0] + 3) >> 2;
        end else if (m_axi_rd_cyc) begin
            if (m_axi_arvalid && m_axi_arready) begin
                m_axi_arvalid <= 0;
            end
            if (m_axi_rvalid && m_axi_rready) begin
                tx_burst_buf[tx_burst_inp] <= m_axi_rdata;
                tx_burst_inp <= tx_burst_inp_next;
                if (tx_word_left <= 1) begin
                    tx_m_axi_stop <= 1;
                    tx_pkt_offs <= tx_pkt_size;
                end else if (tx_pkt_offs == 0) begin
                    tx_pkt_offs[2:0] <= 3'd4 - tx_pkt_addr[1:0];
                end else begin
                    tx_pkt_offs <= tx_pkt_offs + 4;
                end
                if (m_axi_rlast) m_axi_rd_cyc <= 0;
                if (m_axi_rresp) m_axi_rd_err <= 1;
                tx_word_left <= tx_word_left - 1;
            end
        end else if (tx_word_left >= `min_burst && tx_burst_free_len < `min_burst) begin
            // wait for more free space
        end else if (tx_burst_free_len != 0 && tx_axis_start && !tx_m_axi_stop) begin
            m_axi_rd_cyc <= 1;
            m_axi_araddr <= tx_burst_araddr;
            m_axi_arlen <= tx_burst_arlen4k;
            m_axi_arvalid <= 1;
        end
    end
end

// ------ AXI Master Interface, RX

reg [burst_size_bits-1:0] m_axi_wcnt;
reg rx_m_axi_stop0;
wire rx_m_axi_last;

reg  [31:0] rx_burst_buf [(1 << burst_size_bits) - 1 : 0];
reg  [burst_size_bits-1:0] rx_burst_inp;
reg  [burst_size_bits-1:0] rx_burst_out;
reg  [1:0] rx_axis_byte;

wire [burst_size_bits-1:0] rx_burst_inp_next;
wire [burst_size_bits-1:0] rx_burst_out_next;
wire [burst_size_bits-1:0] rx_burst_data_len;
wire [burst_size_bits-1:0] rx_burst_awlen;
wire [burst_size_bits-1:0] rx_burst_awlen4k;
wire [31:0] rx_burst_awaddr;

reg  [31:0] rx_pkt_addr;
reg  [13:0] rx_word_left;

assign m_axi_bready = m_axi_wr_cyc && !m_axi_wvalid;
assign m_axi_wdata = rx_burst_buf[rx_burst_out];
assign rx_burst_inp_next = rx_burst_inp + 1;
assign rx_burst_out_next = rx_burst_out + 1;
assign rx_burst_data_len = rx_burst_inp - rx_burst_out;
assign rx_m_axi_last = rx_axis_stop && (rx_burst_out_next == rx_burst_inp);
assign rx_axis_tready = rx_axis_start && !rx_axis_stop && (rx_burst_inp_next != rx_burst_out || rx_m_axi_stop);
assign rx_burst_awlen = (rx_word_left >= rx_burst_data_len ? rx_burst_data_len : rx_word_left) - 1;
assign rx_burst_awaddr = { rx_pkt_addr[31:2], 2'b00 };

// AXI burst cannot cross a 4KB boundary
assign rx_burst_awlen4k = ~rx_burst_awaddr[11:2] >= rx_burst_awlen ? rx_burst_awlen : ~rx_burst_awaddr[burst_size_bits+1:2];

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
    end else begin
        if (!rx_start) begin
            rx_burst_inp <= 0;
            rx_burst_out <= 0;
            rx_axis_start <= 0;
            rx_axis_stop <= 0;
            rx_bad_frame <= 1;
        end else if (!rx_axis_start) begin
            rx_axis_byte <= rx_addr[rx_pkt_out][1:0];
            rx_axis_start <= 1;
        end else if (rx_axis_tvalid && rx_axis_tready) begin
            rx_burst_buf[rx_burst_inp][rx_axis_byte*8+:8] <= rx_axis_tdata;
            rx_axis_byte <= rx_axis_byte + 1;
            if (rx_axis_tlast) begin
                rx_burst_inp <= rx_burst_inp_next;
                rx_axis_stop <= 1;
                rx_bad_frame <= rx_axis_tuser;
            end else if (rx_axis_byte == 2'h3) begin
                rx_burst_inp <= rx_burst_inp_next;
            end
        end
        if (!rx_start) begin
            rx_m_axi_stop0 <= 0;
            rx_m_axi_stop <= 0;
        end else if (!rx_axis_start) begin
            m_axi_wr_err <= 0;
            rx_done[rx_pkt_out] <= 0;
            rx_status[rx_pkt_out] <= 1;
            m_axi_wstrb <= 4'b1111 << rx_addr[rx_pkt_out][1:0];
            rx_word_left <= (rx_size[rx_pkt_out] + rx_addr[rx_pkt_out][1:0]) >> 2;
            rx_pkt_addr <= rx_addr[rx_pkt_out];
        end else if (m_axi_wr_cyc) begin
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
                rx_burst_out <= rx_burst_out_next;
                if (m_axi_wlast)
                    m_axi_wvalid <= 0;
                else begin
                    m_axi_wlast <= m_axi_wcnt + 1 == m_axi_awlen;
                    m_axi_wcnt <= m_axi_wcnt + 1;
                end
                if (!rx_m_axi_last || rx_axis_byte == 0) rx_pkt_addr <= rx_burst_awaddr + 4;
                else rx_pkt_addr <= rx_pkt_addr + rx_axis_byte;
                if (rx_m_axi_last || rx_word_left <= 1) rx_m_axi_stop0 <= 1;
                rx_word_left <= rx_word_left - 1;
                m_axi_wstrb <= 4'b1111;
            end
        end else if (!rx_axis_stop && rx_burst_data_len < `min_burst) begin
            // wait for more data
        end else if (rx_burst_data_len != 0 && rx_axis_start && !rx_m_axi_stop) begin
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

endmodule
