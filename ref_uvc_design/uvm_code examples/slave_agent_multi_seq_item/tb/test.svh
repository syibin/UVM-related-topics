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
class test extends uvm_test;

// UVM Factory Registration Macro
//
`uvm_component_utils(test)

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Component Members
//------------------------------------------
// The environment class
env m_env;
// Configuration objects
env_config m_env_cfg;

//------------------------------------------
// Methods
//------------------------------------------
extern function void configure_apb_agent(apb_slave_agent_config cfg);
// Standard UVM Methods:
extern function new(string name = "test", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task  main_phase(uvm_phase phase);

endclass: test

function test::new(string name = "test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void test::build_phase(uvm_phase phase);
  // env configuration
  m_env_cfg = env_config::type_id::create("m_env_cfg");

  // APB configuration
  configure_apb_agent(m_env_cfg.slave_agent_cfg);
  
  if (!uvm_config_db #(virtual apb_slave_driver_bfm)::get(this, "", "APB_slv_drv_bfm", m_env_cfg.slave_agent_cfg.drv_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual apb_slave_driver_bfm)::get(...) failed");
  if (!uvm_config_db #(virtual apb_slave_monitor_bfm)::get(this, "", "APB_slv_mon_bfm", m_env_cfg.slave_agent_cfg.mon_bfm))
    `uvm_error("build_phase", "uvm_config_db #(virtual apb_slave_monitor_bfm)::get(...) failed");

  m_env = env::type_id::create("m_env", this);
  
  uvm_config_db #(uvm_object)::set(this, "m_env*", "env_config", m_env_cfg);
  uvm_config_db #(uvm_object)::set(this, "m_env*", "apb_slave_agent_config", m_env_cfg.slave_agent_cfg);
endfunction: build_phase


//
// Convenience function to configure the apb agent
//
// This can be overloaded by extensions to this base class
function void test::configure_apb_agent(apb_slave_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.start_address[0] = 32'h0;
  cfg.range[0] = 32'h18;
endfunction: configure_apb_agent

task test::main_phase(uvm_phase phase);
  apb_slave_sequence slave_seq = apb_slave_sequence::type_id::create("apb_slave_sequence");
  
  phase.raise_objection(this);
  fork
    slave_seq.start(m_env.slave_agent.m_sequencer);
  #10000;
  join_any
  phase.drop_objection(this);
endtask
