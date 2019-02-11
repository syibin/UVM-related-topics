//*****************************************************************************
//	DESIGN	NAME	:	uart_receiver
//	FILE	NAME	:	uart_receiver.v
//	DESIGNER		:	Andrey B. Didenko
//
//	The module implements UART receiver function.
//  It contains state machine, RSR (Receive Shift Register), parity and stop
//  bit checker, flow control logic and control interface with uart_regs module.
//*****************************************************************************

module uart_receiver
(
//---- Clock & Reset ----------------------
input	wire		      clk             ,
input	wire		      rst_n           ,

//---- Receiver data Interface ---------
input   wire              rsr_pull_i      ,

output  wire              rsr_empty_o     ,
output  wire              rsr_full_o      ,
output  wire [7:0]        rsr_byte_o      ,
output  wire              ferr_o          ,
output  wire              perr_o          ,


//---- modes ------------------------------
input   wire              enable_i        ,
input   wire              brg_sample_i    ,
input   wire              brgh_i          ,
input   wire [1:0]        pdsel_i         ,

//---- external interface -----------------
input   wire              rxd_i           ,

output  wire              rts_o
//-----------------------------------------
);

//*****************************************************************************
//							Declarations
//*****************************************************************************
reg   [3:0] rxd_d         ;
reg   [3:0] baud_cnt      ;
reg         rstrt_st      ;
reg         rbyte_st      ;
reg         rbpar_st      ;
reg         rstop_st      ;
reg         wait_idle_st  ;
reg   [7:0] rsr           ;
reg         rsr_valid     ;
reg   [3:0] rbyte_cnt     ;
reg         parity        ;
reg         ferr          ;
reg         perr          ;

wire        rxd_edge      ;
wire        baud_edge     ;
wire        sample        ;
wire        rbit1         ;
wire        rbit0         ;
wire        idle          ;
wire        rstrt_st_set  ;
wire        rstrt_st_clr  ;
wire        rbyte_st_set  ;
wire        rbyte_st_clr  ;
wire        rbpar_st_set  ;
wire        rbpar_st_clr  ;
wire        rstop_st_set  ;
wire        rstop_st_clr  ;
wire        ferr_set      ;
wire        parity_calc   ;
wire        perr_set      ;



//*****************************************************************************
//							Interface logic
//*****************************************************************************

assign rts_o       = rsr_valid;

assign rsr_empty_o = idle & !rsr_valid;
assign rsr_full_o  = rsr_valid;
assign rsr_byte_o  = rsr;
assign ferr_o      = ferr;
assign perr_o      = perr;


// rxd edge detection
assign rxd_edge = ^rxd_d[3:2];

always @(posedge clk or negedge rst_n)
    if (!rst_n) rxd_d  <= 4'b0;
    else        rxd_d  <= {rxd_d[2:0], rxd_i};

//*****************************************************************************
//							Bit interval generator
//*****************************************************************************

always @ (posedge clk, negedge rst_n)
  if (!rst_n)                       baud_cnt <= 4'b0;
  else if (idle & rxd_edge)         baud_cnt <= 4'b0;
  else if (brg_sample_i & enable_i) baud_cnt <= baud_cnt + 4'b1;

assign baud_edge = brg_sample_i & (brgh_i & (&baud_cnt[1:0]) |
                                  !brgh_i & (&baud_cnt));

assign sample    = brg_sample_i & (brgh_i & (baud_cnt[1:0] == 2'h2) |
                                  !brgh_i & (baud_cnt[3:0] == 4'h2));


assign rbit1 = &rxd_d[3:2];
assign rbit0 = &(~rxd_d[3:2]);



//*****************************************************************************
//							FSM logic
//*****************************************************************************

assign idle = !(rstrt_st | rbyte_st | rbpar_st | rstop_st | wait_idle_st);


assign rstrt_st_set = enable_i & idle & !rsr_valid & sample & rbit0;
assign rstrt_st_clr = rstrt_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             rstrt_st <= 1'b0;
  else if (rstrt_st_set)  rstrt_st <= 1'b1;
  else if (rstrt_st_clr)  rstrt_st <= 1'b0;

assign rbyte_st_set = rstrt_st_clr;
assign rbyte_st_clr = rbyte_st & !(|rbyte_cnt) & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             rbyte_st <= 1'b0;
  else if (rbyte_st_set)  rbyte_st <= 1'b1;
  else if (rbyte_st_clr)  rbyte_st <= 1'b0;

assign rbpar_st_set = rbyte_st_clr & (^pdsel_i);
assign rbpar_st_clr = rbpar_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             rbpar_st <= 1'b0;
  else if (rbpar_st_set)  rbpar_st <= 1'b1;
  else if (rbpar_st_clr)  rbpar_st <= 1'b0;

assign rstop_st_set = rbyte_st_clr & !rbpar_st_set | rbpar_st_clr;
assign rstop_st_clr = rstop_st & baud_edge;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)             rstop_st <= 1'b0;
  else if (rstop_st_set)  rstop_st <= 1'b1;
  else if (rstop_st_clr)  rstop_st <= 1'b0;

always @ (posedge clk, negedge rst_n)
  if (!rst_n)                     wait_idle_st <= 1'b1;
  else if (rstop_st_clr & !rbit1) wait_idle_st <= 1'b1;
  else if (rbit1)                 wait_idle_st <= 1'b0;


// Receive Shift Register
always @ (posedge clk, negedge rst_n)
  if (!rst_n)                 rsr <= 8'h0;
  else if (rsr_pull_i)        rsr <= 8'h0;
  else if (rbyte_st & sample) rsr <= {rbit1, rsr[7:1]};

always @ (posedge clk, negedge rst_n)
  if (!rst_n)            rsr_valid <= 1'b0;
  else if (rsr_pull_i)   rsr_valid <= 1'b0;
  else if (rstop_st_clr) rsr_valid <= 1'b1;

// Receive bit counter
always @ (posedge clk, negedge rst_n)
  if (!rst_n)                                   rbyte_cnt <= 4'b0;
  else if (rbyte_st_set)                        rbyte_cnt <= 4'h7;
  else if (rbyte_st & (|rbyte_cnt) & baud_edge) rbyte_cnt <= rbyte_cnt - 4'b1;

// Parity bit storing
always @ (posedge clk, negedge rst_n)
  if (!rst_n)                 parity <= 1'b0;
  else if (rbpar_st & sample) parity <= rbit1;

// Parity and stop bit checkers
assign ferr_set = sample & (
                  (rstop_st & rbit0) |
                  (rbyte_st | rbpar_st | rstop_st) & !rbit0 & !rbit1);

always @ (posedge clk, negedge rst_n)
  if (!rst_n)            ferr <= 1'b0;
  else if (rsr_pull_i)   ferr <= 1'b0;
  else if (ferr_set)     ferr <= 1'b1;

assign parity_calc = pdsel_i[0]? (^rsr) : !(^rsr);
assign perr_set = rbpar_st_clr & (parity ^ parity_calc);

always @ (posedge clk, negedge rst_n)
  if (!rst_n)            perr <= 1'b0;
  else if (rsr_pull_i)   perr <= 1'b0;
  else if (perr_set)     perr <= 1'b1;


///////////////////////////////////////////////////////////////////////////////
endmodule
