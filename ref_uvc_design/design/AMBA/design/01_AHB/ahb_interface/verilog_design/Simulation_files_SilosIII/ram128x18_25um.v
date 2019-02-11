`timescale 1ns/1ns
`ifdef RAM128X18_25UM
`else
`define RAM128X18_25UM
/*************************************************************************
** File : RAM128X18_25UM.v
** Design Date: 9 Feb 00
** Creation Date: Mon May 13 14:09:59 2002

** Created By SpDE Version: SpDE 9.2 Release Build8
** Author: Ed Bezeg, QuickLogic Corporation,
** Copyright (C) 2000, Customers of QuickLogic may use this
** file for use in designing QuickLogic devices only.
** Description : Verilog RAM Model for 128x18 config, .25um RAM block.
** Synchronous Write, both Synchronous and Asynchronous Read
************************************************************************/

`timescale 1ns / 1ns
module RAM128X18_25UM (WA,RA,WD,RD,WE,RE,WCLK,RCLK,ASYNCRD) /* synthesis syn_black_box syn_macro=1 */ ;

parameter
   wordsize = 18,
   memsize = 128,
   addressbits = 7;

input [addressbits-1:0] WA;       //specify Write Address
input [addressbits-1:0] RA;       //specify Read  Address
input [wordsize-1:0] WD;          //specify Write Data (input data)
input WE, RE;         //specify Write and Read Enable
input WCLK            /*synthesis syn_isclock=1 */;
input RCLK           /*synthesis syn_isclock=1 */;
                      //specify Write and Read Clocks
input ASYNCRD;        //specify Asynchronous Read Enable

output [wordsize-1:0] RD;      //specify Read Data (output data)
`ifdef synthesis
`else
reg [addressbits-1:0] RAREG;      //specify Read Address Register
wire [addressbits-1:0] RADDR;
reg [wordsize-1:0] mem[memsize-1:0];    //declare memory

always @(posedge WCLK)
   if (WE == 1)
      mem[WA] <= #1 WD;

always @(posedge RCLK)
   if (RE == 1)
      RAREG <= #1 RA;

assign #1 RADDR = (ASYNCRD == 1) ? RA : RAREG;

assign #1 RD = mem[RADDR];
`endif
endmodule
`endif
