//*****************************************************************************
//	DESIGN	NAME	:	uart_apb_slave
//	FILE	NAME	:	uart_apb_slave.v
//	DESIGNER		:	Andrey B. Didenko
//
//	The module implements bridge function from APB bus to UART register's.
//  It contains address decoding logic and provides simple read/write
//  interfaces to each UART operational register.
//*****************************************************************************
module uart_apb_slave
#(
parameter                       AWIDTH	  = 8,
parameter                       DWIDTH	  = 32,
parameter                       BASE_ADDR	  = 32'h0
 )

(  // system
input  wire                     clk,
input  wire                     rst_n,
// APB
input  wire [AWIDTH - 1 : 0]    apb_addr_i,
input  wire                     apb_sel_i,
input  wire                     apb_en_i,
input  wire                     apb_wr_i,
input  wire [DWIDTH - 1 : 0]    apb_wdata_i,
input  wire [DWIDTH/8 - 1 : 0]  apb_strb_i,

output wire [DWIDTH - 1 : 0]    apb_rdata_o,
output wire                     apb_ready_o,
output wire                     apb_err_o,

// read apb_manager
input  wire                     rerr_i,
input  wire [DWIDTH - 1:0]      rdat_i,

output wire [5:0]               rreq_o,

// write apb_manager
input  wire		                werr_i,

output wire [DWIDTH - 1:0]      wdat_o,
output wire [5:0]               wreq_o,
output wire [DWIDTH/8 - 1:0]    wstr_o
);


// for bus logic
reg	 wack;
reg	 rack;

wire wval ;
wire rval ;
wire wfail;
wire wdone;
wire rdone;
wire rfail;

reg apb_sel_d;
always @(posedge clk, negedge rst_n)
if (!rst_n) apb_sel_d <= 1'b0;
else		apb_sel_d <= apb_sel_i;

// write and read enable
assign wval = apb_sel_i & (!apb_sel_d & !apb_en_i | apb_en_i) &	 apb_wr_i;
assign rval = apb_sel_i & (!apb_sel_d & !apb_en_i | apb_en_i) & !apb_wr_i;

// comparison of the input address apb_addr with register addresses from the MAP
reg [5:0] cmp;

genvar i;
generate

  for(i = 0; i < 6; i = i + 1) begin

	always @*
	  cmp[i] = apb_sel_i & (apb_addr_i[AWIDTH-1:0] == BASE_ADDR[AWIDTH-1:0] + 4*i);

  end

endgenerate


// hit: To form an errors wfail and rfail
wire hit;
assign hit = |cmp;
// wdone, rdone
always @ (posedge clk, negedge rst_n)
  if (!rst_n) wack <= 1'b0;
  else		  wack <= |wreq_o;

always @ (posedge clk, negedge rst_n)
  if (!rst_n) rack <= 1'b0;
  else		  rack <= |rreq_o;

assign wdone = wval & wack;
assign rdone = rval & rack;

// wfail, rfail
assign wfail = wval & (!hit | werr_i);
assign rfail = rval & (!hit | rerr_i);

// wreq_o, rreq_o - requests for individual
//					interfaces for access to
//					registers for reading and writing.
assign wreq_o = (wval & !wack & !apb_ready_o) ? cmp : {6{1'b0}};
assign rreq_o = (rval & !rack & !apb_ready_o) ? cmp : {6{1'b0}};

//apb_err
wire set_apb_err;
assign set_apb_err = wfail | rfail;


reg apb_err_r;
reg apb_ready_r;
always @ (posedge clk, negedge rst_n)
  if (!rst_n)			apb_err_r <= 1'b0;
  else if (apb_ready_r) apb_err_r <= 1'b0;
  else if (set_apb_err) apb_err_r <= 1'b1;

assign apb_err_o = apb_err_r;

//apb_ready
wire set_apb_ready;
assign set_apb_ready =	wval & (wdone | wfail) | rval & (rdone | rfail);

//apb_ready
always @ (posedge clk, negedge rst_n)
  if (!rst_n)			  apb_ready_r <= 1'b0;
  else if (apb_ready_r)	  apb_ready_r <= 1'b0;
  else if (set_apb_ready) apb_ready_r <= 1'b1;

assign apb_ready_o = apb_ready_r;

//apb_rdata
reg [DWIDTH - 1 : 0] apb_rdata_r;
always @ (posedge clk, negedge rst_n)
  if (!rst_n) apb_rdata_r <= {DWIDTH{1'b0}};
  else		  apb_rdata_r <= rdat_i;

assign apb_rdata_o = apb_rdata_r;

//wstr_o, wdat_o
assign wstr_o = apb_strb_i;
assign wdat_o = apb_wdata_i;

endmodule
