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
class gpio_agent extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(gpio_agent)

//------------------------------------------
// Data Members
//------------------------------------------
gpio_agent_config m_cfg;
  
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(gpio_seq_item) ap;
uvm_analysis_port #(gpio_seq_item) ext_ap;

gpio_monitor   m_monitor;
gpio_sequencer m_sequencer;
gpio_driver    m_driver;
//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "gpio_agent", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: gpio_agent


function gpio_agent::new(string name = "gpio_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void gpio_agent::build_phase(uvm_phase phase);
  `get_config(gpio_agent_config, m_cfg, "gpio_agent_config")
  // Monitor is always present
  m_monitor = gpio_monitor::type_id::create("m_monitor", this);
  m_monitor.m_cfg = m_cfg;
  // Only build the driver and sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver = gpio_driver::type_id::create("m_driver", this);
    m_driver.m_cfg = m_cfg;
    m_sequencer = gpio_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void gpio_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  if(m_cfg.monitor_external_clock == 1) begin
    ext_ap = m_monitor.ext_ap;
  end
  // Only connect the driver and the sequencer if active
  if(m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
