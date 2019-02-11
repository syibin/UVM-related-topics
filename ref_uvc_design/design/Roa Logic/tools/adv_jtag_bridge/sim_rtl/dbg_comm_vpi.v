//////////////////////////////////////////////////////////////////
//                                                              //
//     ██████╗  ██████╗  █████╗                                 //
//     ██╔══██╗██╔═══██╗██╔══██╗                                //
//     ██████╔╝██║   ██║███████║                                //
//     ██╔══██╗██║   ██║██╔══██║                                //
//     ██║  ██║╚██████╔╝██║  ██║                                //
//     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝                                //
//           ██╗      ██████╗  ██████╗ ██╗ ██████╗              //
//           ██║     ██╔═══██╗██╔════╝ ██║██╔════╝              //
//           ██║     ██║   ██║██║  ███╗██║██║                   //
//           ██║     ██║   ██║██║   ██║██║██║                   //
//           ███████╗╚██████╔╝╚██████╔╝██║╚██████╗              //
//           ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝              //
//                                                              //
//     Advanced Debug Interface - JTAG File IO                  //
//                                                              //
//   Author(s):                                                 //
//        Igor Mohor  (igorm@opencores.org)                     //
//        Gyorgy Jeney (nog@sdf.lonestar.net)                   //
//        Nathan Yawn (nathan.yawn@opencores.org)               //
//        Richard Herveille (richard.herveille@roalogic.com)    //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2000-2008,2016 Authors                         //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////

module dbg_comm_vpi #(
  parameter JP_PORT = "4567",
  parameter TIMEOUT_CNT = 6'd20
)
(
  output TRSTN,
         TCK,
         TMS,
         TDI,
  input  TDO
);

////////////////////////////////////////////////////////////////
//
// Variables
//
reg [4:0] memory;
reg [3:0] in_word_r;
reg [5:0] clk_count;

reg timeout_clk;

////////////////////////////////////////////////////////////////
//
// Module Body
//

// Handle commands from the upper level
initial
begin
    in_word_r = 5'b0;
    memory = 5'b0;
    $jp_init(JP_PORT);
    #500;  // Wait until reset is complete

    while(1)
    begin
        #1;
        $jp_in(memory);  // This will not change memory[][] if no command has been sent from jp
        if(memory[4])  // was memory[0][4]
        begin
	    in_word_r = memory[3:0];
	    memory = memory & 4'b1111;
	    clk_count = 6'b000000;  // Reset the timeout clock in case jp wants to wait for a timeout / half TCK period
       end
    end
end


// Send the output bit to the upper layer
always @(TDO) $jp_out(TDO); 


assign TCK   = in_word_r[0];
assign TRSTN = in_word_r[1];
assign TDI   = in_word_r[2];
assign TMS   = in_word_r[3];


// Send timeouts / wait periods to the upper layer
initial timeout_clk = 0;

always #10 timeout_clk = ~timeout_clk;

always @(posedge timeout_clk)
begin
    if      (clk_count <  TIMEOUT_CNT)
        clk_count[5:0] <= clk_count + 'h1;
    else if (clk_count == TIMEOUT_CNT)
    begin
        $jp_wait_time();
        clk_count[5:0] <= clk_count + 'h1;
    end
    // else it's already timed out, don't do anything
end 

endmodule

