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
class gpio_monitor extends uvm_component;

// UVM Factory Registration Macro
//
`uvm_component_utils(gpio_monitor);

// Virtual Interface
local virtual gpio_monitor_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
gpio_agent_config m_cfg;
//------------------------------------------
// Component Members
//------------------------------------------
uvm_analysis_port #(gpio_seq_item) ap;
uvm_analysis_port #(gpio_seq_item) ext_ap;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:

extern function new(string name = "gpio_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

// Proxy Methods:
  
extern function void notify_transaction(gpio_seq_item item);
extern function void notify_transaction_ext_ap(gpio_seq_item item);

endclass: gpio_monitor

function gpio_monitor::new(string name = "gpio_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void gpio_monitor::build_phase(uvm_phase phase);
  `get_config(gpio_agent_config, m_cfg, "gpio_agent_config")
  m_bfm = m_cfg.mon_bfm;
  m_bfm.proxy = this;
  
  ap = new("ap", this);
  if(m_cfg.monitor_external_clock == 1) begin
    ext_ap = new("ext_ap", this);
  end
endfunction: build_phase

task gpio_monitor::run_phase(uvm_phase phase);
  fork
    m_bfm.internal_monitor_loop();
    begin // Only needed if running external clock monitoring
      if(m_cfg.monitor_external_clock == 1) begin
        m_bfm.external_monitor_loop();
      end
    end
  join
endtask: run_phase

function void gpio_monitor::report_phase(uvm_phase phase);
// Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase

function void gpio_monitor::notify_transaction(gpio_seq_item item);
  ap.write(item);
endfunction : notify_transaction

function void gpio_monitor::notify_transaction_ext_ap(gpio_seq_item item);
  ext_ap.write(item);
endfunction : notify_transaction_ext_ap
