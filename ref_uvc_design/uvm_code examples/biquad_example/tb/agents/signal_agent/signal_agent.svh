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

class signal_agent extends uvm_component;

`uvm_component_utils(signal_agent)

uvm_analysis_port #(signal_seq_item) ap;
signal_driver m_driver;
uvm_sequencer #(signal_seq_item) m_sequencer;
signal_monitor m_monitor;
signal_agent_config cfg;

extern function new(string name = "signal_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: signal_agent

function signal_agent::new(string name = "signal_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void signal_agent::build_phase(uvm_phase phase);
  if(!uvm_config_db #(signal_agent_config)::get(this, "", "signal_agent_config", cfg)) begin
    `uvm_error("build_phase", "Unable to locate signal_agent_config in uvm_config_db")
  end
  ap = new("ap", this);
  m_monitor = signal_monitor::type_id::create("m_monitor", this);
  m_sequencer = uvm_sequencer #(signal_seq_item)::type_id::create("m_sequencer", this);
  m_driver = signal_driver::type_id::create("m_driver", this);
endfunction: build_phase

function void signal_agent::connect_phase(uvm_phase phase);
  m_monitor.ap.connect(ap);
  m_monitor.SIGNAL = cfg.SIGNAL;
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  m_driver.SIGNAL = cfg.SIGNAL;
endfunction: connect_phase