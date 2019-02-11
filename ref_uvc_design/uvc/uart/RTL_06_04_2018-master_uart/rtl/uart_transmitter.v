//*****************************************************************************
//	DESIGN	NAME	:	uart_transmitter
//	FILE	NAME	:	uart_transmitter.v
//	DESIGNER		:	Andrey B. Didenko
//
//	The module implements UART transmitter function.
//  It contains state machine, TSR (Transmit Shift Register), parity generator,
//  flow control logic and control interface with uart_regs module.
//*****************************************************************************

module uart_transmitter
(
//---- Clock & Reset ----------------------
input	wire		      clk             ,
input	wire		      rst_n           ,

//---- Transmitter data Interface ---------
input   wire              tsr_push_i      ,
input   wire [7:0]        tsr_byte_i      ,
input   wire              txbrk_i         ,

output  wire              tsr_empty_o     ,

//---- modes ------------------------------
input   wire              enable_i        ,
input   wire              brg_sample_i    ,
input   wire              brgh_i          ,
input   wire              stsel_i         ,
input   wire [1:0]        pdsel_i         ,

output  wire              cts_o           ,

//---- external interface -----------------
input   wire              cts_i           ,

output  wire              txd_o
//-----------------------------------------
);

//*****************************************************************************
//							Declarations
//*****************************************************************************
reg   [1:0] cts_s         ;
reg   [3:0] baud_cnt      ;
reg         xstrt_st      ;
reg         xbyte_st      ;
reg         xbpar_st      ;
reg         xstop_st      ;
reg   [7:0] tsr           ;
reg         tsr_valid     ;
reg   [3:0] xbyte_cnt     ;
reg         parity        ;

wire        cts           ;
wire        baud_edge     ;
wire        idle          ;
wire        xstrt_st_set  ;
wire        xstrt_st_clr  ;
wire        xbyte_st_set  ;
wire        xbyte_st_clr  ;
wire        xbpar_st_set  ;
wire        xbpar_st_clr  ;
wire        xstop_st_set  ;
wire        xstop_st_clr  ;


//*****************************************************************************
//							Interface logic
//*****************************************************************************

assign txd_o = xstrt_st? 1'b0 : xbyte_st? tsr[0] : xbpar_st? parity : 1'b1;

assign cts_o = cts;

// CTS pin synchronization
assign cts = cts_s[1];

always @(posedge clk or negedge rst_n)
    if (!rst_n) cts_s  <= 2'b0;
    else        cts_s  <= {cts_s[0], cts_i};


assign tsr_empty_o = (idle & !tsr_valid);


//*****************************************************************************
//							Bit interval generator
//*****************************************************************************

always @ (posedge clk, negedge rst_n)
  if (!rst_n)                       baud_cnt <= 4'b0;
  else if (brg_sample_i & enable_i) baud_cnt <= baud_cnt + 4'b1;

assign baud_edge = brg_sample_i & (brgh_i & (&baud_cnt[1:0]) |
                                  !brgh_i & (&baud_cnt));

//*****************************************************************************
//							FSM logic
//*****************************************************************************

assign idle = !(xstrt_st | xbyte_st | xbpar_st | xstop_st);


assign xstrt_st_set = enable_i & idle & tsr_valid & baud_edge;
assign xstrt_st_clr = xstrt_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             xstrt_st <= 1'b0;
  else if (xstrt_st_set)  xstrt_st <= 1'b1;
  else if (xstrt_st_clr)  xstrt_st <= 1'b0;

assign xbyte_st_set = xstrt_st_clr;
assign xbyte_st_clr = xbyte_st & !(|xbyte_cnt) & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             xbyte_st <= 1'b0;
  else if (xbyte_st_set)  xbyte_st <= 1'b1;
  else if (xbyte_st_clr)  xbyte_st <= 1'b0;

assign xbpar_st_set = xbyte_st_clr & (^pdsel_i) & !txbrk_i;
assign xbpar_st_clr = xbpar_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             xbpar_st <= 1'b0;
  else if (xbpar_st_set)  xbpar_st <= 1'b1;
  else if (xbpar_st_clr)  xbpar_st <= 1'b0;

assign xstop_st_set = stsel_i & !txbrk_i & (xbyte_st_clr & !xbpar_st_set | xbpar_st_clr);
assign xstop_st_clr = xstop_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             xstop_st <= 1'b0;
  else if (xstop_st_set)  xstop_st <= 1'b1;
  else if (xstop_st_clr)  xstop_st <= 1'b0;

// Transmit Shift Register
always @ (posedge clk, negedge rst_n)
  if (!rst_n)          tsr <= 8'h0;
  else if (tsr_push_i) tsr <= txbrk_i? 8'h0 : tsr_byte_i;
  else if (xbyte_st & baud_edge) tsr <= {1'b0, tsr[7:1]};

always @ (posedge clk, negedge rst_n)
  if (!rst_n)            tsr_valid <= 1'b0;
  else if (xbyte_st_clr) tsr_valid <= 1'b0;
  else if (tsr_push_i)   tsr_valid <= 1'b1;

// Transmit bit counter
always @ (posedge clk, negedge rst_n)
  if (!rst_n)                                   xbyte_cnt <= 4'b0;
  else if (xbyte_st_set)                        xbyte_cnt <= txbrk_i? 4'hb : 4'h7;
  else if (xbyte_st & (|xbyte_cnt) & baud_edge) xbyte_cnt <= xbyte_cnt - 4'b1;

// Parity generation
always @ (posedge clk, negedge rst_n)
  if (!rst_n)          parity <= 1'b0;
  else if (tsr_push_i) parity <= pdsel_i[0]? (^tsr_byte_i) : !(^tsr_byte_i);



///////////////////////////////////////////////////////////////////////////////
endmodule
