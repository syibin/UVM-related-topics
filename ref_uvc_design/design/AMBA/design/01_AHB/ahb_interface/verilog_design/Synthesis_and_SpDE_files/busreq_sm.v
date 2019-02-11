/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              busreq_sm.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/
// First Draft (5/21/2002 H. Kim)

`timescale 1ns/10ps

module busreq_sm (
		hclk,
		hreset,
		dma_en,
		req_done,
		full,
		empty,
		non_zero,
		rd_req,
		wr_req,
		rd_update,
		wr_update
		);

input			hclk;
input			hreset;
input			dma_en;
input			req_done;
input			full;
input			empty;
input			non_zero;
output			rd_req;
output			wr_req;
output			rd_update;	// Read Address Update
output			wr_update;	// Write Address Update

reg		[2:0]	state;
reg		[2:0]	nextstate;
wire			rd_req;
wire			wr_req;
wire			rd_update;
wire			wr_update;

// ******************************************************
// Parameter Definition for State
// ******************************************************
parameter         IDLE                = 3'b000;
parameter         INIT                = 3'b001;
parameter         WRREQ               = 3'b010;
parameter         RDREQ               = 3'b011;
parameter         WRDONE              = 3'b110;
parameter         RDDONE              = 3'b111;

assign rd_req = (state == RDREQ);
assign wr_req = (state == WRREQ);
assign rd_update = (state == RDDONE);
assign wr_update = (state == WRDONE);

always @(posedge hclk or posedge hreset)
	if (hreset) begin
		state <= #1 IDLE;
	end
	else begin
		state <= #1 nextstate;
	end

always @(state or dma_en or empty or full or non_zero or req_done)
	case(state)
		IDLE: 	if (dma_en)
						nextstate = INIT;
				else
						nextstate = IDLE;
		INIT:  	if (!empty)
						nextstate = WRREQ;	
				else if (!full && non_zero)
						nextstate = RDREQ;
				else 
						nextstate = INIT;
		WRREQ:  if (req_done)
						nextstate = WRDONE;
				else
						nextstate = WRREQ;
		RDREQ:  if (req_done)
						nextstate = RDDONE;
				else
						nextstate = RDREQ;
		WRDONE:	if (!full && non_zero) 
						nextstate = RDREQ;
				else
						nextstate = INIT;
		RDDONE: if (!empty)
						nextstate = WRREQ;	
				else 
						nextstate = INIT;
		default:	nextstate = IDLE;
	endcase

endmodule
