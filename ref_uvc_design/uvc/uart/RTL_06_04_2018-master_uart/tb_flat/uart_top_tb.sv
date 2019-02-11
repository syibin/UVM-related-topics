module uart_top_tb;

`define UART_BASE_ADDRESS     32'h0
`define UART_INTF_REGISTER    32'h0
`define UART_INTC_REGISTER    32'h4
`define UART_MODE_REGISTER    32'h8
`define UART_STATUS_REGISTER  32'hC
`define UART_RXBUF_REGISTER   32'h10
`define UART_TXBUF_REGISTER   32'h14
`define CHARACTER_NUM         30



bit          clk;
bit          rst_n;

logic  [7:0] paddr = 8'h0;
logic        psel = 1'b0;
logic        penable = 1'b0;
logic        pwrite = 1'b0;
logic [31:0] pwdata = 32'h0;
logic  [3:0] pstrb = 4'h0;
logic [31:0] prdata;
logic        pready;
logic        pslverr;

logic        interrupt;

logic        cts = 1'b1;
logic        txd;
logic        rxd = 1'b1;
logic        rts;


uart_top #( .APB_ADDR_WIDTH   ( 8                  ),
            .APB_BASE_ADDRESS ( `UART_BASE_ADDRESS )
                 )
uart_top_u(

  // clock and reset
  .clk          ( clk       ),
  .rst_n        ( rst_n     ),

  // APB register's interface
  .apb_addr_i   ( paddr     ),
  .apb_sel_i    ( psel      ),
  .apb_en_i     ( penable   ),
  .apb_wr_i     ( pwrite    ),
  .apb_wdata_i  ( pwdata    ),
  .apb_strb_i   ( pstrb     ),

  .apb_rdata_o  ( prdata    ),
  .apb_ready_o  ( pready    ),
  .apb_err_o    ( pslverr   ),

  // interrupt
  .int_o        ( interrupt ),

  // external interface
  .cts_i        ( cts       ),
  .txd_o        ( txd       ),

  .rxd_i        ( rxd       ),
  .rts_o        ( rts       )

);


///////////////////////////////////////////////////////////////////////////////////////////////////
`include "tasks.sv"

bit    [7:0] character;
bit   [31:0] read_data;
bit          error;
bit   [31:0] mode;
bit    [2:0] interrupts_config;
bit    [1:0] ins_errors;
bit   [31:0] intf;
logic  [9:0] symbol = 4'bxxxx;
bit    [3:0] send_error;


always #5ns clk <= !clk;

initial begin
  repeat(20) @(posedge clk);
  rst_n <= 1'b1;
end


initial begin
  $timeformat(-9, 2, "ns", 20);

  `ifdef LOOPBACK_PDSEL11_FCE0_STSEL0_BRGH0_NOINTERRUPT
    interrupts_config = 3'b0;
    mode              = 32'h0000_00A3;

    `include "internal_loopback.sv"
  `endif

  `ifdef LOOPBACK_PDSEL10_FCE1_STSEL0_BRGH0_NOINTERRUPT
    interrupts_config = 3'b0;
    mode              = 32'h0000_00B2;

    `include "internal_loopback.sv"
  `endif

  `ifdef LOOPBACK_PDSEL01_FCE0_STSEL1_BRGH0_NOINTERRUPT
    interrupts_config = 3'b0;
    mode              = 32'h0000_00A5;

    `include "internal_loopback.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH0_FERR0_PERR0_INTERRUPT
    interrupts_config = 3'b010;
    mode              = 32'h0000_0286;
    ins_errors        = 2'b0;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH0_FERR1_PERR0_INTERRUPT
    interrupts_config = 3'b110;
    mode              = 32'h0000_0182;
    ins_errors        = 2'b01;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH0_FERR0_PERR1_INTERRUPT
    interrupts_config = 3'b110;
    mode              = 32'h0000_0182;
    ins_errors        = 2'b10;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL11_FCE0_STSEL0_BRGH0_FERR0_PERR0_INTERRUPT
    interrupts_config = 3'b010;
    mode              = 32'h0000_0183;
    ins_errors        = 2'b0;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL11_FCE0_STSEL0_BRGH0_FERR0_PERR1_INTERRUPT
    interrupts_config = 3'b110;
    mode              = 32'h0000_0183;
    ins_errors        = 2'b10;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH1_FERR0_PERR0_INTERRUPT
    interrupts_config = 3'b010;
    mode              = 32'h0000_018A;
    ins_errors        = 2'b00;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH1_FERR1_PERR0_INTERRUPT
    interrupts_config = 3'b110;
    mode              = 32'h0000_018A;
    ins_errors        = 2'b01;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_PDSEL10_FCE0_STSEL0_BRGH1_FERR1_PERR1_INTERRUPT
    interrupts_config = 3'b110;
    mode              = 32'h0000_018A;
    ins_errors        = 2'b11;

    `include "uart_receive.sv"
  `endif

  `ifdef UART_RECEIVE_OVERFLOW
    interrupts_config = 3'b110;
    mode              = 32'h0000_0186;
    ins_errors        = 2'b0;

    `include "uart_rx_overflow.sv"
  `endif

  `ifdef UART_TRANSMIT_FCE0
    mode       = 32'h0000_1186;
    ins_errors = 2'b0;

    `include "uart_transmit.sv"
  `endif

  //`ifdef UART_TRANSMIT_FCE1
    mode       = 32'h0000_0096;
    ins_errors = 2'b0;

    `include "uart_transmit.sv"
  //`endif

end


endmodule
