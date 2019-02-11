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
class pss_env_config extends uvm_object;

  localparam string s_my_config_id = "pss_env_config";
  localparam string s_no_config_id = "no config";
  localparam string s_my_config_type_error_id = "config type error";

  // UVM Factory Registration Macro
  //
  `uvm_object_utils(pss_env_config)


  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Configurations for the sub_components
  spi_env_config m_spi_env_cfg;
  gpio_env_config m_gpio_env_cfg;
  ahb_agent_config m_ahb_agent_cfg;

  // Register map
  pss_reg_block pss_rb;

  // Interrupt Utility
  intr_util ICPIT;

  //------------------------------------------
  // Methods
  //------------------------------------------
  extern static function pss_env_config get_config( uvm_component c);
    extern task wait_for_interrupt;
  extern function bit is_interrupt_cleared();

  // Standard UVM Methods:
  extern function new(string name = "pss_env_config");

endclass: pss_env_config

function pss_env_config::new(string name = "pss_env_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function pss_env_config pss_env_config::get_config( uvm_component c );
  pss_env_config t;

  if (!uvm_config_db #(pss_env_config)::get(c, "", s_my_config_id, t) )
    `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

task pss_env_config::wait_for_interrupt;
  ICPIT.wait_for_interrupt();
endtask: wait_for_interrupt

// Check that interrupt has cleared:
function bit pss_env_config::is_interrupt_cleared();
  return ICPIT.is_interrupt_cleared();
endfunction: is_interrupt_cleared
