/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              app_codec.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/
// First Draft (5/14/2002 H. Kim)

`timescale 1ns/10ps
`include "xor32x2.v"

module app_codec (
		hreset,
		clk, 
		app_start,
		block_size,
		datain,
		dataout,
		pop,
		push,
		done
		);

input 			hreset;
input 			clk;
input 			app_start;	// start signal
input	[4:0]	block_size;	// block size from ahb_slave
input  	[31:0] 	datain;   	// Data from FIFO
output			pop;		// read 
output 	[31:0] 	dataout; 	// Data to FIFO
output  		push; 		// write
output  		done; 		// block process done

wire			pop;
wire	[31:0] 	dataout;
wire			push;
wire			done;

reg 	[4:0]   word_count; // word count in a block
reg		[7:0]	wait_count; // Idling time (word_count*8)
reg				wait_flag; 

wire	[31:0]	xorin1;		// Input from FIFO
wire	[31:0]	xorin2;		// Constant
wire	[31:0]	xor2out;

assign push = |word_count && !wait_flag;
assign pop =  push;
assign dataout = xor2out;
assign done = push && (word_count == 5'b00001);
assign xorin1 = datain;
assign xorin2 = 32'hFFFFFFFF;

xor32x2 xor2_1 (.in1(xorin1), .in2(xorin2), .out(xor2out));

always @(posedge clk or posedge hreset) 
	begin
		if (hreset) begin
			wait_count  <= 8'hFF;
			wait_flag	<= 1'b0;
		end
		else if (app_start) begin
			wait_count  <= {block_size, 3'b000};
			wait_flag	<= 1'b1;
  		end
		else if ((|wait_count) && wait_flag)begin
			wait_count  <= wait_count - 1;
		end
		else if (wait_count == 8'h00) begin
			wait_flag 	<= 1'b0;
		end
	end

always @(posedge clk or posedge hreset) 
	begin
		if (hreset) begin
			word_count	<= 5'b00000;
		end
		else if (app_start) begin
			word_count	<= block_size;
  		end
		else if (!wait_flag && push) begin
			word_count	<= word_count - 1;
		end
	end


endmodule







