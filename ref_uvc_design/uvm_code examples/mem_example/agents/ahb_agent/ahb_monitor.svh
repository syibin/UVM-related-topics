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
class ahb_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(ahb_monitor);

// Virtual Interface
virtual ahb_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
ahb_agent_config m_cfg;

//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(ahb_seq_item) ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "ahb_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
  
extern function void notify_transaction(ahb_seq_item item);

endclass: ahb_monitor

function ahb_monitor::new(string name = "ahb_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void ahb_monitor::build_phase(uvm_phase phase);
  `get_config(ahb_agent_config, m_cfg, "ahb_agent_config")
  m_bfm = m_cfg.mon_bfm;
  m_bfm.proxy = this;
  
  ap = new("ap", this);
endfunction: build_phase

task ahb_monitor::run_phase(uvm_phase phase);
  m_bfm.run();
endtask: run_phase

function void ahb_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase

function void ahb_monitor::notify_transaction(ahb_seq_item item);
  ap.write(item);
endfunction : notify_transaction
