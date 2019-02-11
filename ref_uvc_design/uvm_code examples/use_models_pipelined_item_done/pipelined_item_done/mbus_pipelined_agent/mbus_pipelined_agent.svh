//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//
// Note that this agent has been simplified - it does not
// contain a monitor or any analysis components
//
class mbus_pipelined_agent extends uvm_component;

`uvm_component_utils(mbus_pipelined_agent)

mbus_pipelined_agent_config m_cfg;
mbus_pipelined_driver m_driver;
mbus_pipelined_sequencer m_sequencer;

function new(string name = "mbus_pipelined_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  uvm_object tmp;

  if(!uvm_config_db #(mbus_pipelined_agent_config)::get(this, "", "mbus_agent_config", m_cfg)) begin
    `uvm_fatal("Build", "MBUS pipelined agent config not found")
  end

  if(m_cfg.is_active) begin
    m_driver = mbus_pipelined_driver::type_id::create("m_driver", this);
    m_sequencer = mbus_pipelined_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  if(m_cfg.is_active) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    m_driver.set_bfm(m_cfg.driver_bfm);
  end
endfunction: connect_phase

endclass: mbus_pipelined_agent
