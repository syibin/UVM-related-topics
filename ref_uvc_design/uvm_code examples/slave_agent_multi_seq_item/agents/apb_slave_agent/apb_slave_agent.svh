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

//
// Class Description:
//
//
class apb_slave_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_slave_agent)

//------------------------------------------
// Data Members
//------------------------------------------
apb_slave_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(apb_slave_access_item) ap;
apb_slave_monitor   m_monitor;
apb_slave_sequencer m_sequencer;
apb_slave_driver    m_driver;
item_listener listener;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_slave_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: apb_slave_agent


function apb_slave_agent::new(string name = "apb_slave_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_slave_agent::build_phase(uvm_phase phase);
  m_cfg = apb_slave_agent_config::get_config(this);
  // Monitor is always present
  m_monitor = apb_slave_monitor::type_id::create("m_monitor", this);
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = apb_slave_driver::type_id::create("m_driver", this);
    m_sequencer = apb_slave_sequencer::type_id::create("m_sequencer", this);
  end
  listener = item_listener::type_id::create("item_listener", this);
endfunction: build_phase

function void apb_slave_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.rsp_ap;
  ap.connect(listener.analysis_export);
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end

endfunction: connect_phase
