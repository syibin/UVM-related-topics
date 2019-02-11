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

class uart_agent extends uvm_agent;

`uvm_component_utils(uart_agent)

uvm_analysis_port #(uart_seq_item) ap;

uart_driver m_uart_driver;
uart_sequencer m_uart_sequencer;
uart_monitor m_uart_monitor;

uart_agent_config m_cfg;


function new(string name = "uart_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  `get_config(uart_agent_config, m_cfg, "uart_agent_config")
  ap = new("APB Monitor", this);
  m_uart_monitor = uart_monitor::type_id::create("m_uart_monitor", this);
  m_uart_monitor.m_cfg = m_cfg;
  if(m_cfg.ACTIVE)
    begin
      m_uart_driver = uart_driver::type_id::create("m_uart_driver", this);
      m_uart_driver.m_cfg = m_cfg;
      m_uart_sequencer = uart_sequencer::type_id::create("m_uart_sequencer", this);
    end
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_uart_monitor.ap.connect(ap);
  if(m_cfg.ACTIVE) begin
    m_uart_driver.seq_item_port.connect(m_uart_sequencer.seq_item_export);
  end
endfunction: connect_phase

endclass: uart_agent
