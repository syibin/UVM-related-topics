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
class gpio_test_base extends uvm_test;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(gpio_test_base)

  //------------------------------------------
  // Data Members
  //------------------------------------------

  //------------------------------------------
  // Component Members
  //------------------------------------------
  gpio_env m_env; // The environment class
  gpio_env_config m_env_cfg;
  apb_agent_config m_apb_cfg;
  gpio_agent_config m_GPO_cfg;
  gpio_agent_config m_GPOE_cfg;
  gpio_agent_config m_GPI_cfg;
  gpio_agent_config m_AUX_cfg;
  gpio_reg_block gpio_rb;

  //------------------------------------------
  // Methods
  //------------------------------------------
  extern virtual function void configure_apb_agent(apb_agent_config cfg);
  // Standard UVM Methods:
  extern function new(string name = "gpio_test_base", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void assign_seqs(gpio_virtual_sequence_base seq);

endclass: gpio_test_base

function gpio_test_base::new(string name = "gpio_test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void gpio_test_base::build_phase(uvm_phase phase);
  m_env_cfg = gpio_env_config::type_id::create("m_env_cfg", this);

  // Register model
  // Enable all types of coverage available in the register model
  uvm_reg::include_coverage("*", UVM_CVR_ALL);

  gpio_rb = gpio_reg_block::type_id::create("gpio_rb");
  gpio_rb.build();

  m_env_cfg.gpio_rb = gpio_rb;

  m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg", this);
  if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "APB_mon_bfm", m_apb_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual apb_driver_bfm) ::get(this, "", "APB_drv_bfm", m_apb_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_drv_bfm from uvm_config_db. Have you set() it?")
  configure_apb_agent(m_apb_cfg);
  m_env_cfg.m_apb_agent_cfg = m_apb_cfg;
  m_GPO_cfg = gpio_agent_config::type_id::create("m_GPO_cfg", this);
  m_GPO_cfg.active = UVM_PASSIVE;  
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPO_mon_bfm", m_GPO_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPO_mon_bfm from uvm_config_db. Have you set() it?")
//  if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPO_drv_bfm", m_GPO_cfg.drv_bfm))
//    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_GPO_agent_cfg = m_GPO_cfg;
  m_GPOE_cfg = gpio_agent_config::type_id::create("m_GPOE_cfg", this);
  m_GPOE_cfg.active = UVM_PASSIVE;  
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPOE_mon_bfm", m_GPOE_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPOE_mon_bfm from uvm_config_db. Have you set() it?")
//  if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPOE_drv_bfm", m_GPOE_cfg.drv_bfm))
//    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_GPOE_agent_cfg = m_GPOE_cfg;
  m_GPI_cfg = gpio_agent_config::type_id::create("m_GPI_cfg", this);
  m_GPI_cfg.monitor_external_clock = 1; // Need to monitor the external clock
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPI_mon_bfm", m_GPI_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPI_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPI_drv_bfm", m_GPI_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_GPI_agent_cfg = m_GPI_cfg;
  m_AUX_cfg = gpio_agent_config::type_id::create("m_AUX_cfg", this);
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "AUX_mon_bfm", m_AUX_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface AUX_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "AUX_drv_bfm", m_AUX_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_AUX_agent_cfg = m_AUX_cfg;
  // Assign the Interrupt virtual interface to the env config
  if (!uvm_config_db #(virtual intr_if)::get(this, "", "INTR_vif", m_env_cfg.INTR))
    `uvm_fatal("VIF CONFIG", "Cannot get() interface INTR_vif from uvm_config_db. Have you set() it?")
  uvm_config_db #(gpio_env_config)::set(this,"*","gpio_env_config", m_env_cfg);
  m_env = gpio_env::type_id::create("m_env", this);
endfunction: build_phase

task gpio_test_base::run_phase(uvm_phase phase);

endtask: run_phase

//
// Convenience function to configure the apb agent
//
// This can be overloaded by extensions to this base class
function void gpio_test_base::configure_apb_agent(apb_agent_config cfg);
  cfg.active = UVM_ACTIVE;
  cfg.has_functional_coverage = 0;
  cfg.has_scoreboard = 0;
  // GPIO is on select line 0 for address range 0-18h
  cfg.no_select_lines = 1;
  cfg.start_address[0] = 32'h0;
  cfg.range[0] = 32'h24;
endfunction: configure_apb_agent

// Used to assign sequencers to test sequence
//
function void gpio_test_base::assign_seqs(gpio_virtual_sequence_base seq);
  seq.aux = m_env.m_AUX_agent.m_sequencer;
  seq.gpi = m_env.m_GPI_agent.m_sequencer;

  seq.m_cfg = m_env_cfg;
endfunction
