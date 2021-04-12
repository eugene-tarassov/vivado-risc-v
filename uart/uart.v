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

module uart (
    input wire async_resetn,

    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clock CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXI_LITE, FREQ_HZ 100000000" *)
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

    // Interrupts
    output reg interrupt,

    // RS232
    (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 RS232 TxD" *)
    output reg TxD,
    (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 RS232 RxD" *)
    input wire RxD,
    (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 RS232 RTSn" *)
    output reg RTSn,
    (* X_INTERFACE_INFO = "xilinx.com:interface:uart:1.0 RS232 CTSn" *)
    input wire CTSn
);

wire reset;

// ------ Resets

(* ASYNC_REG="true" *)
reg  [2:0] reset_sync;
assign reset = reset_sync[2];

always @(posedge clock)
    reset_sync <= {reset_sync[1:0], !async_resetn};

// ------ RX/TX

`define fifo_ptr_bits 4

reg  [7:0] rx_buf [(1<<`fifo_ptr_bits)-1:0];
reg  [`fifo_ptr_bits-1:0] rx_inp_pos;
reg  [`fifo_ptr_bits-1:0] rx_out_pos;
wire [`fifo_ptr_bits-1:0] rx_inp_nxt;
wire [`fifo_ptr_bits-1:0] rx_out_nxt;
wire rx_full;
wire rx_empty;
wire rx_irq;

assign rx_full = rx_inp_nxt == rx_out_pos;
assign rx_empty = rx_inp_pos == rx_out_pos;
assign rx_inp_nxt = rx_inp_pos + 1;
assign rx_out_nxt = rx_out_pos + 1;
assign rx_irq = !rx_empty;

reg  [7:0] tx_buf [(1<<`fifo_ptr_bits)-1:0];
reg  [`fifo_ptr_bits-1:0] tx_inp_pos;
reg  [`fifo_ptr_bits-1:0] tx_out_pos;
wire [`fifo_ptr_bits-1:0] tx_inp_nxt;
wire [`fifo_ptr_bits-1:0] tx_out_nxt;
wire [`fifo_ptr_bits-1:0] tx_len;
wire tx_full;
wire tx_empty;
wire tx_irq;
reg tx_stop;

reg [7:0] xon_xoff_inp;
reg [7:0] xon_xoff_out;

assign tx_full = tx_inp_nxt == tx_out_pos;
assign tx_empty = tx_inp_pos == tx_out_pos;
assign tx_inp_nxt = tx_inp_pos + 1;
assign tx_out_nxt = tx_out_pos + 1;
assign tx_len = tx_inp_pos - tx_out_pos;
assign tx_irq = tx_len <= (1 << (`fifo_ptr_bits - 2));

`define STATE_SIZE 4
`define IDLE  0
`define START 1
`define BIT0  2
`define BIT1  3
`define BIT2  4
`define BIT3  5
`define BIT4  6
`define BIT5  7
`define BIT6  8
`define BIT7  9

parameter BAUD_RATE = 115200;

 // Clock divider
`define PHASE_MAX (100000000 / BAUD_RATE - 1)

// RxD sampling point
`define PHASE_RXC (`PHASE_MAX / 2)

reg [`STATE_SIZE-1:0] rx_state;
reg [`STATE_SIZE-1:0] tx_state;

reg [15:0] rx_phase;
reg [15:0] tx_phase;

reg [7:0] rx_rg;
reg [7:0] tx_rg;

reg CTS0;

always @(posedge clock) begin
    if (reset) begin
        RTSn <= 1;
        CTS0 <= 1;
        TxD <= 1;
        rx_inp_pos <= 0;
        tx_out_pos <= 0;
        rx_state <= `IDLE;
        tx_state <= `IDLE;
        rx_phase <= 0;
        tx_phase <= 0;
        xon_xoff_out <= 0;
    end else begin
        RTSn <= rx_full;
        if (tx_phase == `PHASE_MAX) begin
            CTS0 <= CTSn;
            case (tx_state)
            `IDLE:
                if (CTSn == 0 && CTS0 == 0) begin
                  if (xon_xoff_inp != xon_xoff_out) begin
                      if (xon_xoff_inp != 0) begin
                          TxD <= 0;
                          tx_state <= `START;
                          tx_rg <= xon_xoff_inp;
                      end
                      xon_xoff_out <= xon_xoff_inp;
                  end else if (!tx_empty && !tx_stop) begin
                      TxD <= 0;
                      tx_state <= `START;
                      tx_rg <= tx_buf[tx_out_pos];
                      tx_out_pos <= tx_out_nxt;
                  end
                end
            `START: begin TxD <= tx_rg[0]; tx_state <= `BIT0; end
            `BIT0: begin TxD <= tx_rg[1]; tx_state <= `BIT1; end
            `BIT1: begin TxD <= tx_rg[2]; tx_state <= `BIT2; end
            `BIT2: begin TxD <= tx_rg[3]; tx_state <= `BIT3; end
            `BIT3: begin TxD <= tx_rg[4]; tx_state <= `BIT4; end
            `BIT4: begin TxD <= tx_rg[5]; tx_state <= `BIT5; end
            `BIT5: begin TxD <= tx_rg[6]; tx_state <= `BIT6; end
            `BIT6: begin TxD <= tx_rg[7]; tx_state <= `BIT7; end
            `BIT7: begin TxD <= 1; tx_state <= `IDLE; end
            endcase
            tx_phase <= 0;
        end else begin
            tx_phase <= tx_phase + 1;
        end
        if (rx_phase == `PHASE_MAX) begin
            case (rx_state)
            `IDLE: if (RxD == 0) begin rx_state <= `START; end
            `START: begin rx_rg[0] <= RxD; rx_state <= `BIT0; end
            `BIT0: begin rx_rg[1] <= RxD; rx_state <= `BIT1; end
            `BIT1: begin rx_rg[2] <= RxD; rx_state <= `BIT2; end
            `BIT2: begin rx_rg[3] <= RxD; rx_state <= `BIT3; end
            `BIT3: begin rx_rg[4] <= RxD; rx_state <= `BIT4; end
            `BIT4: begin rx_rg[5] <= RxD; rx_state <= `BIT5; end
            `BIT5: begin rx_rg[6] <= RxD; rx_state <= `BIT6; end
            `BIT6: begin rx_rg[7] <= RxD; rx_state <= `BIT7; end
            `BIT7:
                begin
                    rx_buf[rx_inp_pos] <= rx_rg;
                    rx_inp_pos <= rx_inp_nxt;
                    rx_state <= `IDLE;
                end
            endcase
            rx_phase <= 0;
        end else if (rx_state == `IDLE && RxD == 1) begin
            rx_phase <= `PHASE_RXC;
        end else begin
            rx_phase <= rx_phase + 1;
        end
    end
end

// ------ Interrupts

reg [1:0] irq_enable;

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
        rx_out_pos <= 0;
        tx_inp_pos <= 0;
        irq_enable <= 0;
        interrupt <= 0;
        xon_xoff_inp <= 0;
        tx_stop <= 0;
    end else begin
        interrupt <= (irq_enable[0] && rx_irq) || (irq_enable[1] && tx_irq);
        if (s_axi_arready && s_axi_arvalid) begin
            read_addr <= s_axi_araddr;
            rd_req <= 1;
        end
        if (s_axi_rvalid && s_axi_rready) begin
            s_axi_rvalid <= 0;
        end else if (!s_axi_rvalid && rd_req) begin
            s_axi_rdata <= 0;
            if (read_addr[15:4] == 0) begin
                case (read_addr[3:0])
                4'h00: if (!rx_empty) begin s_axi_rdata[7:0] <= rx_buf[rx_out_pos]; rx_out_pos <= rx_out_nxt; end
                4'h08: s_axi_rdata[4:0] <= { !CTSn, tx_full, tx_empty, rx_full, !rx_empty };
                4'h0c: s_axi_rdata[6:4] <= { tx_stop, irq_enable };
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
            if (write_addr[15:4] == 0) begin
                case (write_addr[3:0])
                4'h04:
                    if (write_data[8] != 0) begin
                        // xon/xoff char
                        xon_xoff_inp <= write_data[7:0];
                    end else if (!tx_full) begin
                        tx_buf[tx_inp_pos] <= write_data[7:0];
                        tx_inp_pos <= tx_inp_nxt;
                    end
                4'h0c:
                    begin
                        if (write_data[0]) begin rx_out_pos <= rx_inp_pos; end
                        if (write_data[1]) begin tx_inp_pos <= tx_out_pos; end
                        irq_enable <= write_data[5:4];
                        tx_stop <= write_data[6];
                    end
                endcase
            end
            s_axi_bresp <= 0;
            s_axi_bvalid <= 1;
            wr_req <= 0;
        end
    end
end

endmodule
