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
class pss_env extends uvm_env;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(pss_env)

  //------------------------------------------
  // Data Members
  //------------------------------------------
  pss_env_config m_cfg;
  //------------------------------------------
  // Sub Components
  //------------------------------------------
  spi_env m_spi_env;
  gpio_env m_gpio_env;
  ahb_agent m_ahb_agent;

  // Register layer adapter
  reg2ahb_adapter m_reg2ahb;
  // Register predictor
  uvm_reg_predictor#(ahb_seq_item) m_ahb2reg_predictor;

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "pss_env", uvm_component parent = null);
  // Only required if you have sub-components
  extern function void build_phase(uvm_phase phase);
  // Only required if you have sub-components which are connected
  extern function void connect_phase(uvm_phase phase);

endclass: pss_env

function pss_env::new(string name = "pss_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Only required if you have sub-components
function void pss_env::build_phase(uvm_phase phase);
  if (!uvm_config_db #(pss_env_config)::get(this, "", "pss_env_config", m_cfg) )
    `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration pss_env_config from uvm_config_db. Have you set() it?")

  uvm_config_db #(spi_env_config)::set(this, "m_spi_env*", "spi_env_config", m_cfg.m_spi_env_cfg);
  m_spi_env = spi_env::type_id::create("m_spi_env", this);

  uvm_config_db #(gpio_env_config)::set(this, "m_gpio_env*", "gpio_env_config", m_cfg.m_gpio_env_cfg);
  m_gpio_env = gpio_env::type_id::create("m_gpio_env", this);

  uvm_config_db #(ahb_agent_config)::set(this, "m_ahb_agent*", "ahb_agent_config", m_cfg.m_ahb_agent_cfg);
  m_ahb_agent = ahb_agent::type_id::create("m_ahb_agent", this);

  // Build the register model predictor
  m_ahb2reg_predictor = uvm_reg_predictor#(ahb_seq_item)::type_id::create("m_ahb2reg_predictor", this);
  m_reg2ahb = reg2ahb_adapter::type_id::create("m_reg2ahb");
endfunction: build_phase

// Only required if you have sub-components which are connected
function void pss_env::connect_phase(uvm_phase phase);
  // Only set up register sequencer layering if the pss_rb is the top block
  // If it isn't, then the top level environment will set up the correct sequencer
  // and predictor
  if(m_cfg.pss_rb.get_parent() == null) begin
    if(m_cfg.m_ahb_agent_cfg.active == UVM_ACTIVE) begin
      m_cfg.pss_rb.pss_map.set_sequencer(m_ahb_agent.m_sequencer, m_reg2ahb);
    end

    //
    // Register prediction part:
    //
    // Replacing implicit register model prediction with explicit prediction
    // based on APB bus activity observed by the APB agent monitor
    // Set the predictor map:
    m_ahb2reg_predictor.map = m_cfg.pss_rb.pss_map;
    // Set the predictor adapter:
    m_ahb2reg_predictor.adapter = m_reg2ahb;
    // Disable the register models auto-prediction
    m_cfg.pss_rb.pss_map.set_auto_predict(0);
    // Connect the predictor to the bus agent monitor analysis port
    m_ahb_agent.ap.connect(m_ahb2reg_predictor.bus_in);
  end
endfunction: connect_phase
