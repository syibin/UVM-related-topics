//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

module biquad_tb;

import uvm_pkg::*;
import biquad_test_pkg::*;

logic PCLK;
logic PRESETn;
logic CLK48K;

apb_if APB(.PCLK(PCLK), .PRESETn(PRESETn));
signal_if SIGNAL();

biquad DUT(// APB Interface
           .PCLK(PCLK),
           .PRESETn(PRESETn),
           .PSEL(APB.PSEL[0]),
           .PENABLE(APB.PENABLE),
           .PADDR(APB.PADDR),
           .PWDATA(APB.PWDATA),
           .PRDATA(APB.PRDATA),
           .PWRITE(APB.PWRITE),
           .PREADY(APB.PREADY),
           .PSLVERR(APB.PSLVERR),
           // Filter clock
           .FCLK(CLK48K),
           // Filter input and output
           .x(SIGNAL.x),
           .yout(SIGNAL.y));


initial begin
  uvm_config_db #(virtual apb_if)::set(null, "uvm_test_top", "APB", APB);
  uvm_config_db #(virtual signal_if)::set(null, "uvm_test_top", "SIGNAL", SIGNAL);
  run_test();
end

initial begin
  PCLK = 0;
  PRESETn = 0;
  repeat(10) begin
    #1ns PCLK = ~PCLK;
  end
  PRESETn = 1;
  forever begin
    #1ns PCLK = ~PCLK;
  end
end

initial begin
  CLK48K = 0;
  forever begin
    #10417ns  CLK48K = ~CLK48K;
//    #2604ns  CLK48K = ~CLK48K;
  end
end

endmodule: biquad_tb