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

class uart_monitor extends uvm_component;

`uvm_component_utils(uart_monitor)

// Virtual Interface
local virtual uart_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
uart_agent_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(uart_seq_item) ap;
  
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

function new(string name = "uart_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  `get_config(uart_agent_config, m_cfg, "uart_agent_config")
  m_bfm = m_cfg.mon_bfm;
  m_bfm.proxy = this;
  
  ap = new("uart_ap", this);
endfunction: build_phase

task run_phase(uvm_phase phase);
  m_bfm.set_config(m_cfg.baud_divisor, m_cfg.lcr);
  m_bfm.run();
endtask : run_phase

// Proxy Methods:
  
function void notify_transaction(uart_seq_item item);
  ap.write(item);
endfunction : notify_transaction

endclass: uart_monitor
