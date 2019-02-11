/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              fifo128x32.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/
// First Draft 5/21/2002 H. Kim

`timescale 1ns/10ps
`include "r128a32_25um.v"

module fifo128x32 (
	clock,
	reset,
	push,
	pop,
	full,
	empty,
	din,
	dout
);

input 			clock;
input 			reset;
input 			push;
input 			pop;
output 			full;
output 			empty;
input 	[31:0] 	din;
output 	[31:0] 	dout;

wire 	[31:0] 	dout;

reg 	[6:0] 	wptr;
reg 	[6:0] 	rptr;
reg				last_op;

wire			full;
wire			empty;
 
always @(posedge clock or posedge reset)
	if (reset)
		last_op <= #1 1'b0;
    else begin
        if (!empty && pop && !push)
		  last_op <= #1 1'b0;
	    else if (!full && push && !pop)
		  last_op <= #1 1'b1;
	end

always @(posedge clock or posedge reset)
	if (reset)
		rptr <= #1 7'b0000000;
	else if (!empty && pop) 
		rptr <= #1 rptr + 1;

always @(posedge clock or posedge reset)
	if (reset)
		wptr <= #1 7'b0000000;
	else if (!full && push)
		wptr <= #1 wptr + 1;

assign empty = (rptr ==	wptr) && !last_op;
assign full = (wptr == rptr) && last_op;

 r128a32_25um m(
 		.wa({wptr[6:0]}),
 		.ra({rptr[6:0]}),
 		.wd(din),
 		.rd(dout),
 		.we(!full && push),
 		.wclk(clock));

endmodule





