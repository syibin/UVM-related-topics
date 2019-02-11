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
class gpio_env_config extends uvm_object;

localparam string s_my_config_id = "gpio_env_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(gpio_env_config)


//------------------------------------------
// Data Members
//------------------------------------------
// Enables for the sub-components
bit has_apb_agent = 1;
bit has_GPO_agent = 1;
bit has_GPOE_agent = 1;
bit has_GPI_agent = 1;
bit has_AUX_agent = 1;
bit has_scoreboard = 1;
bit has_functional_coverage = 1;
bit has_out_scoreboard = 1;
bit has_in_scoreboard = 1;
// Configurations for the sub_components
apb_agent_config m_apb_agent_cfg;
gpio_agent_config m_GPO_agent_cfg;
gpio_agent_config m_GPOE_agent_cfg;
gpio_agent_config m_GPI_agent_cfg;
gpio_agent_config m_AUX_agent_cfg;

// Interrupt virtual interface
virtual intr_if INTR;

// Register model
gpio_reg_block gpio_rb;

//------------------------------------------
// Methods
//------------------------------------------
extern task wait_for_interrupt;
extern static function gpio_env_config get_config( uvm_component c);
// Standard UVM Methods:
extern function new(string name = "gpio_env_config");
endclass: gpio_env_config

// Externally declared methods
function gpio_env_config::new(string name = "gpio_env_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function gpio_env_config gpio_env_config::get_config( uvm_component c );
  gpio_env_config t;

  if (!uvm_config_db #(gpio_env_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

// Wait for interrupt:
//
task gpio_env_config::wait_for_interrupt;
  INTR.wait_for_interrupt();
endtask: wait_for_interrupt
