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

class uart_driver extends uvm_driver #(uart_seq_item, uart_seq_item);

`uvm_component_utils(uart_driver)

// Virtual Interface
local virtual uart_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
uart_agent_config m_cfg;
uart_seq_item pkt;
  
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:


function new(string name = "uart_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  `get_config(uart_agent_config, m_cfg, "uart_agent_config")
  m_bfm = m_cfg.drv_bfm;
  
endfunction: build_phase
  
task run_phase(uvm_phase phase);
  fork
    send_pkts;
    m_bfm.clk_gen;
  join
endtask: run_phase
  
// Helper Methods:
  
task send_pkts;
  m_bfm.clear_sigs();
  forever begin
    seq_item_port.get_next_item(pkt);
    m_bfm.send_pkt(pkt);
    seq_item_port.item_done();
  end
endtask: send_pkts

endclass: uart_driver
