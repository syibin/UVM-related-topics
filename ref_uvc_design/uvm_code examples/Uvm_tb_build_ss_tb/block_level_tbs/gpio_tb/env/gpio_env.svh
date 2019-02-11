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
class gpio_env extends uvm_env;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(gpio_env)
  //------------------------------------------
  // Data Members
  //------------------------------------------
  apb_agent m_apb_agent;
  gpio_agent m_GPO_agent;
  gpio_agent m_GPOE_agent;
  gpio_agent m_GPI_agent;
  gpio_agent m_AUX_agent;
  gpio_out_scoreboard m_out_sb;
  gpio_in_scoreboard m_in_sb;
  gpio_env_config m_cfg;

  // Register layer adapter
  reg2apb_adapter m_reg2apb;
  // Register predictor
  uvm_reg_predictor#(apb_seq_item) m_apb2reg_predictor;
  
  //------------------------------------------
  // Constraints
  //------------------------------------------

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "gpio_env", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass:gpio_env


function gpio_env::new(string name = "gpio_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void gpio_env::build_phase(uvm_phase phase);
  if (!uvm_config_db #(gpio_env_config)::get(this, "", "gpio_env_config", m_cfg) )
    `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration gpio_env_config from uvm_config_db. Have you set() it?")
  if(m_cfg.has_apb_agent) begin
    uvm_config_db #(apb_agent_config)::set(this,"m_apb_agent*", "apb_agent_config", m_cfg.m_apb_agent_cfg);
    m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
    
    // Build the register model predictor
    m_apb2reg_predictor = uvm_reg_predictor#(apb_seq_item)::type_id::create("m_apb2reg_predictor", this);
    m_reg2apb = reg2apb_adapter::type_id::create("m_reg2apb");
  end
  if(m_cfg.has_GPO_agent) begin
    uvm_config_db #(gpio_agent_config)::set(this,"m_GPO_agent*", "gpio_agent_config", m_cfg.m_GPO_agent_cfg);
    m_GPO_agent = gpio_agent::type_id::create("m_GPO_agent", this);
  end
  if(m_cfg.has_GPOE_agent) begin
    uvm_config_db #(gpio_agent_config)::set(this,"m_GPOE_agent*", "gpio_agent_config", m_cfg.m_GPOE_agent_cfg);
    m_GPOE_agent = gpio_agent::type_id::create("m_GPOE_agent", this);
  end
  if(m_cfg.has_GPI_agent) begin
    uvm_config_db #(gpio_agent_config)::set(this,"m_GPI_agent*", "gpio_agent_config", m_cfg.m_GPI_agent_cfg);
    m_GPI_agent = gpio_agent::type_id::create("m_GPI_agent", this);
  end
  if(m_cfg.has_AUX_agent) begin
    uvm_config_db #(gpio_agent_config)::set(this,"m_AUX_agent*", "gpio_agent_config", m_cfg.m_AUX_agent_cfg);
    m_AUX_agent = gpio_agent::type_id::create("m_AUX_agent", this);
  end
  if(m_cfg.has_out_scoreboard) begin
    m_out_sb = gpio_out_scoreboard::type_id::create("m_out_sb", this);
  end
  if(m_cfg.has_in_scoreboard) begin
    m_in_sb = gpio_in_scoreboard::type_id::create("m_in_sb", this);
  end
endfunction:build_phase

function void gpio_env::connect_phase(uvm_phase phase);
  if(m_cfg.m_apb_agent_cfg.active == UVM_ACTIVE) begin
    // Only set up register sequencer layering if the top level env
    if(m_cfg.gpio_rb.get_parent() == null) begin
      m_cfg.gpio_rb.gpio_reg_block_map.set_sequencer(m_apb_agent.m_sequencer, m_reg2apb);
    end
  end

  // Replacing implicit register model prediction with explicit prediction
  // based on APB bus activity observed by the APB agent monitor
  // Set the predictor map:
  m_apb2reg_predictor.map = m_cfg.gpio_rb.gpio_reg_block_map;
  // Set the predictor adapter:
  m_apb2reg_predictor.adapter = m_reg2apb;
  // Disable the register models auto-prediction
  m_cfg.gpio_rb.gpio_reg_block_map.set_auto_predict(0);
  // Connect the predictor to the bus agent monitor analysis port
  m_apb_agent.ap.connect(m_apb2reg_predictor.bus_in);
  
  if(m_cfg.has_out_scoreboard) begin
    m_out_sb.gpio_rb = m_cfg.gpio_rb;
    m_GPO_agent.ap.connect(m_out_sb.GPO_fifo.analysis_export);
    m_GPOE_agent.ap.connect(m_out_sb.GPOE_fifo.analysis_export);
    if(m_cfg.has_AUX_agent) begin
      m_AUX_agent.ap.connect(m_out_sb.AUX_fifo.analysis_export);
    end
  end
  if(m_cfg.has_in_scoreboard) begin
    m_in_sb.gpio_rb = m_cfg.gpio_rb;
    m_GPI_agent.ap.connect(m_in_sb.gpi_int.analysis_export);
    if(m_cfg.m_GPI_agent_cfg.monitor_external_clock == 1) begin
      m_GPI_agent.ext_ap.connect(m_in_sb.gpi_ext.analysis_export); //MIKE
    end
  end
endfunction: connect_phase

function void gpio_env::report_phase(uvm_phase phase);
  if((m_cfg.has_in_scoreboard == 1)) begin
    if((m_in_sb.gpi_read_error == 0) & (m_in_sb.ints_read_error == 0) & (m_out_sb.gpo_error_count == 0) & (m_out_sb.gpoe_error_count == 0)
     & (m_out_sb.aux_error_count == 0)) begin
       `uvm_info("** UVM TEST PASSED **", "No scoreboard errors reported", UVM_LOW)
    end
    else begin
      `uvm_error("!! UVM TEST FAILED !!", "Scoreboard errors reported")
    end
  end
  else begin
    if((m_out_sb.gpo_error_count == 0) & (m_out_sb.gpoe_error_count == 0)
     & (m_out_sb.aux_error_count == 0)) begin
       `uvm_info("** UVM TEST PASSED **", "No scoreboard errors reported", UVM_LOW)
    end
    else begin
      `uvm_error("!! UVM TEST FAILED !!", "Scoreboard errors reported")
    end  
  end
endfunction
