//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
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

package uart_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "config_macro.svh"

// Parity Calculation
function bit calParity (input logic [7:0] lcr, input logic[7:0] data);
  bit retParity;

  if (lcr[5])
    begin
      case (lcr[4])
        1'b0: retParity = 1'b1;
        1'b1: retParity = 1'b0;
      endcase
    end
  else
    begin
      case (lcr[1:0])
        2'b00: retParity = ^data[4:0];
        2'b01: retParity = ^data[5:0];
        2'b10: retParity = ^data[6:0];
        2'b11: retParity = ^data[7:0];
      endcase
      if (!lcr[4])
        retParity = ~retParity;
    end
  return retParity;
endfunction

`include "uart_seq_item.svh"
`include "uart_agent_config.svh"
`include "uart_monitor.svh"
typedef uvm_sequencer#(uart_seq_item) uart_sequencer;
`include "uart_driver.svh"
`include "uart_agent.svh"

endpackage: uart_agent_pkg
