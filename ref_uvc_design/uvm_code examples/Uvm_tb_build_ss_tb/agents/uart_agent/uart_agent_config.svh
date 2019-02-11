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

class uart_agent_config extends uvm_object;

`uvm_object_utils(uart_agent_config)

bit ACTIVE = 1;
logic[7:0] lcr = 8'h3f;
logic[15:0] baud_divisor = 16'h0004;

// BFM Virtual Interfaces
virtual uart_monitor_bfm mon_bfm;
virtual uart_driver_bfm  drv_bfm;

function new(string name = "uart_agent_config");
  super.new(name);
endfunction

endclass: uart_agent_config
