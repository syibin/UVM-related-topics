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
class pss_test_base extends uvm_test;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(pss_test_base)

  //------------------------------------------
  // Data Members
  //------------------------------------------

  //------------------------------------------
  // Component Members
  //------------------------------------------
  // The environment class
  pss_env m_env;
  // Configuration objects
  pss_env_config m_env_cfg;
  spi_env_config m_spi_env_cfg;
  gpio_env_config m_gpio_env_cfg;
  //uart_env_config m_uart_env_cfg;
  apb_agent_config m_spi_apb_agent_cfg;
  apb_agent_config m_gpio_apb_agent_cfg;
  ahb_agent_config m_ahb_agent_cfg;
  spi_agent_config m_spi_agent_cfg;
  gpio_agent_config m_GPO_agent_cfg;
  gpio_agent_config m_GPI_agent_cfg;
  gpio_agent_config m_GPOE_agent_cfg;

  //Interrupt Utility
  intr_util ICPIT;

  // Register map
  pss_reg_block pss_rb;

  //------------------------------------------
  // Methods
  //------------------------------------------
  //extern function void configure_apb_agent(apb_agent_config cfg);
  // Standard UVM Methods:
  extern function new(string name = "pss_test_base", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern virtual function void configure_apb_agent(apb_agent_config cfg, int index, logic[31:0] start_address, logic[31:0] range);
  extern function void assign_sequencers(pss_test_seq_base seq_);

  extern task run_phase(uvm_phase phase);

endclass: pss_test_base

function pss_test_base::new(string name = "pss_test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void pss_test_base::build_phase(uvm_phase phase);
  virtual intr_bfm temp_intr_bfm;
  
  m_env_cfg = pss_env_config::type_id::create("m_env_cfg");

  // Register model
  // Enable all types of coverage available in the register model
  uvm_reg::include_coverage("*", UVM_CVR_ALL);

  // Register map - Keep reg_map a generic name for vertical reuse reasons
  pss_rb = pss_reg_block::type_id::create("pss_rb");
  pss_rb.build();
  m_env_cfg.pss_rb = pss_rb;

  // SPI Sub-env configuration:
  m_spi_env_cfg = spi_env_config::type_id::create("m_spi_env_cfg");
  m_spi_env_cfg.spi_rb = pss_rb.spi_rb;

  // apb agent in the SPI env:

  m_spi_apb_agent_cfg = apb_agent_config::type_id::create("m_spi_apb_agent_cfg");
  configure_apb_agent(m_spi_apb_agent_cfg, 0, 32'h0, 32'h18);
  if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "APB_SPI_mon_bfm", m_spi_apb_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_SPI_mon_bfm from uvm_config_db. Have you set() it?")
  //if (!uvm_config_db #(virtual apb_driver_bfm) ::get(this, "", "APB_SPI_drv_bfm", m_spi_apb_agent_cfg.drv_bfm))
  //  `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_spi_apb_agent_cfg.active = UVM_PASSIVE;
  m_spi_env_cfg.m_apb_agent_cfg = m_spi_apb_agent_cfg;

  // SPI agent:
  m_spi_agent_cfg = spi_agent_config::type_id::create("m_spi_agent_cfg");
  if (!uvm_config_db #(virtual spi_monitor_bfm)::get(this, "", "SPI_mon_bfm", m_spi_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual spi_driver_bfm) ::get(this, "", "SPI_drv_bfm", m_spi_agent_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_spi_env_cfg.m_spi_agent_cfg = m_spi_agent_cfg;
  m_env_cfg.m_spi_env_cfg = m_spi_env_cfg;
  uvm_config_db #(spi_env_config)::set(this, "*", "spi_env_config", m_spi_env_cfg);

  // GPIO env configuration:
  m_gpio_env_cfg = gpio_env_config::type_id::create("m_gpio_env_cfg");
  m_gpio_env_cfg.gpio_rb = pss_rb.gpio_rb;
  m_gpio_apb_agent_cfg = apb_agent_config::type_id::create("m_gpio_apb_agent_cfg");
  configure_apb_agent(m_gpio_apb_agent_cfg, 1, 32'h100, 32'h124);
  if (!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "APB_GPIO_mon_bfm", m_gpio_apb_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_GPIO_mon_bfm from uvm_config_db. Have you set() it?")
  //if (!uvm_config_db #(virtual apb_driver_bfm) ::get(this, "", "APB_GPIO_drv_bfm", m_gpio_apb_agent_cfg.drv_bfm))
  //  `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface APB_drv_bfm from uvm_config_db. Have you set() it?")
  m_gpio_apb_agent_cfg.active = UVM_PASSIVE;
  m_gpio_env_cfg.m_apb_agent_cfg = m_gpio_apb_agent_cfg;
  m_gpio_env_cfg.has_functional_coverage = 1; // Register coverage no longer valid

  // GPO agent
  m_GPO_agent_cfg = gpio_agent_config::type_id::create("m_GPO_agent_cfg");
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPO_mon_bfm", m_GPO_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPO_mon_bfm from uvm_config_db. Have you set() it?")
  //if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPO_drv_bfm", m_GPO_agent_cfg.drv_bfm))
  //  `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_GPO_agent_cfg.active = UVM_PASSIVE; // Only monitors
  m_gpio_env_cfg.m_GPO_agent_cfg = m_GPO_agent_cfg;

  // GPOE agent
  m_GPOE_agent_cfg = gpio_agent_config::type_id::create("m_GPOE_agent_cfg");
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPOE_mon_bfm", m_GPOE_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPOE_mon_bfm from uvm_config_db. Have you set() it?")
  //if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPOE_drv_bfm", m_GPOE_agent_cfg.drv_bfm))
  //  `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_GPOE_agent_cfg.active = UVM_PASSIVE; // Only monitors
  m_gpio_env_cfg.m_GPOE_agent_cfg = m_GPOE_agent_cfg;

  // GPI agent - active (default)
  m_GPI_agent_cfg = gpio_agent_config::type_id::create("m_GPI_agent_cfg");
  if (!uvm_config_db #(virtual gpio_monitor_bfm)::get(this, "", "GPI_mon_bfm", m_GPI_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface GPI_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual gpio_driver_bfm) ::get(this, "", "GPI_drv_bfm", m_GPI_agent_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface SPI_drv_bfm from uvm_config_db. Have you set() it?")
  m_gpio_env_cfg.m_GPI_agent_cfg = m_GPI_agent_cfg;
  // GPIO Aux agent not present
  m_gpio_env_cfg.has_AUX_agent = 0;
  m_gpio_env_cfg.has_functional_coverage = 1;
  m_gpio_env_cfg.has_out_scoreboard = 1;
  m_gpio_env_cfg.has_in_scoreboard = 1;
  m_env_cfg.m_gpio_env_cfg = m_gpio_env_cfg;
  uvm_config_db #(gpio_env_config)::set(this, "*", "gpio_env_config", m_gpio_env_cfg);

  // AHB Agent
  m_ahb_agent_cfg = ahb_agent_config::type_id::create("m_ahb_agent_cfg");
  if (!uvm_config_db #(virtual ahb_monitor_bfm)::get(this, "", "AHB_mon_bfm", m_ahb_agent_cfg.mon_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface AHB_mon_bfm from uvm_config_db. Have you set() it?")
  if (!uvm_config_db #(virtual ahb_driver_bfm) ::get(this, "", "AHB_drv_bfm", m_ahb_agent_cfg.drv_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface AHB_drv_bfm from uvm_config_db. Have you set() it?")
  m_env_cfg.m_ahb_agent_cfg = m_ahb_agent_cfg;
  // Add in interrupt line
  ICPIT = intr_util::type_id::create("ICPIT");
  if (!uvm_config_db #(virtual intr_bfm)::get(this, "", "ICPIT_bfm", temp_intr_bfm))
    `uvm_fatal("VIF CONFIG", "Cannot get() interface ICPIT_bfm from uvm_config_db. Have you set() it?")
  ICPIT.set_bfm(temp_intr_bfm);
  m_env_cfg.ICPIT = ICPIT;
  m_spi_env_cfg.INTR = ICPIT;
  
  uvm_config_db #(pss_env_config)::set(this, "*", "pss_env_config", m_env_cfg);
  m_env = pss_env::type_id::create("m_env", this);

endfunction: build_phase

//
// Convenience function to configure the apb agent
//
// This can be overloaded by extensions to this base class
function void pss_test_base::configure_apb_agent(apb_agent_config cfg, int index, logic[31:0] start_address, logic[31:0] range);
  cfg.active = UVM_PASSIVE;
  cfg.has_functional_coverage = 0;
  cfg.has_scoreboard = 0;
  cfg.no_select_lines = 1;
  cfg.apb_index = index;
  cfg.start_address[0] = start_address;
  cfg.range[0] = range;
endfunction: configure_apb_agent

function void pss_test_base::assign_sequencers(pss_test_seq_base seq_);
  seq_.ahb = m_env.m_ahb_agent.m_sequencer;
  seq_.spi = m_env.m_spi_env.m_spi_agent.m_sequencer;
  seq_.gpi = m_env.m_gpio_env.m_GPI_agent.m_sequencer;

  seq_.m_cfg = m_env_cfg;
endfunction: assign_sequencers

task pss_test_base::run_phase(uvm_phase phase);

endtask: run_phase
