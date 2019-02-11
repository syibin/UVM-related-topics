/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              appreq_sm.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/
// First Draft (5/22/2002 H. Kim)

`timescale 1ns/10ps

module appreq_sm (
		clk,
		hreset,
		full,
		empty,
		done,
		start
		);

input			clk;
input			hreset;
input			full;
input			empty;
input  			done;
output			start;	// Write Address Update

reg		[1:0]	state;
reg		[1:0]	nextstate;
wire			start;

// ******************************************************
// Parameter Definition for State
// ******************************************************
parameter         IDLE                = 2'b00;
parameter         START               = 2'b01;
parameter         BUSY                = 2'b10;
parameter         DONE                = 2'b11;

assign start = (state == START);

always @(posedge clk or posedge hreset)
	if (hreset) begin
		state <= #1 IDLE;
	end
	else begin
		state <= #1 nextstate;
	end

always @(state or empty or full or done)
	case(state)
		IDLE: 	if (!empty && !full)
						nextstate = START;
				else
						nextstate = IDLE;
		START: 		    nextstate = BUSY;
		BUSY:   if (done)
						nextstate = DONE;
				else
						nextstate = BUSY;
		DONE:	if (!empty && !full) 
						nextstate = START;
				else
						nextstate = IDLE;
		default:	nextstate = IDLE;
	endcase

endmodule
