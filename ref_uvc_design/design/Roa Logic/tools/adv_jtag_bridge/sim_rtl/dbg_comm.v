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


module dbg_comm #(
  parameter JTAG_IN = "/dev/shm/gbd_in.dat",
  parameter JTAG_OUT = "/dev/shm/gdb_out.dat"
)
(
  output TRSTN,
         TCK,
         TMS,
         TDI,
  inout  TDO
);

parameter Tp = 20;

//////////////////////////////////////////////////////////////////
//
// Variables
//

// For handling data from the input file
integer handle1, handle2;
reg [4:0] memory[0:0];

// Temp. signal
reg [3:0] in_word_r;


////////////////////////////////////////////////////////////////
//
// Module Body
//

// Set the initial state of the JTAG pins
initial
begin
    in_word_r = 4'h0;  // This sets the TRSTN output active...
end


// Handle input from a file for the JTAG pins
initial
begin
    #500;  // Wait until reset is complete
    while(1)
    begin
        #Tp;
        $readmemh(JTAG_OUT, memory);
        if(!(memory[0] & 5'b10000))
        begin
            in_word_r = memory[0][3:0];
            handle1 = $fopen(JTAG_OUT);
            $fwrite(handle1, "%h", 5'b10000 | memory[0]);  // To ack that we read gdb_out.dat
            $fflush(handle1);
            $fclose(handle1);
        end
    end
end

// Send the current state of the JTAG output to a file 
always @(TDO or negedge TCK)
begin
    handle2 = $fopen(JTAG_IN);
    $fdisplay(handle2, "%b", TDO);
    $fflush(handle2);
    $fclose(handle2);
end

// Note these must match the bit definitions in the JTAG bridge program (adv_jtag_bridge)
assign TCK   = in_word_r[0];
assign TRSTN = in_word_r[1];
assign TDI   = in_word_r[2];
assign TMS   = in_word_r[3];

endmodule

