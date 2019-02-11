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
class spi_env_config extends uvm_object;

  localparam string s_my_config_id = "spi_env_config";
  localparam string s_no_config_id = "no config";
  localparam string s_my_config_type_error_id = "config type error";

  // UVM Factory Registration Macro
  //
  `uvm_object_utils(spi_env_config)

  // Interrupt Utility - used in the wait for interrupt task
  //
  intr_util INTR;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  // Whether env analysis components are used:
  bit has_functional_coverage = 0;
  bit has_spi_functional_coverage = 1;
  bit has_reg_scoreboard = 0;
  bit has_spi_scoreboard = 1;

  // Configurations for the sub_components
  apb_agent_config m_apb_agent_cfg;
  spi_agent_config m_spi_agent_cfg;

  // SPI Register block
  spi_reg_block spi_rb;

  //------------------------------------------
  // Methods
  //------------------------------------------
  extern static function spi_env_config get_config( uvm_component c);
    extern task wait_for_interrupt;
  extern function bit is_interrupt_cleared;
  // Standard UVM Methods:
  extern function new(string name = "spi_env_config");

endclass: spi_env_config

function spi_env_config::new(string name = "spi_env_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function spi_env_config spi_env_config::get_config( uvm_component c );
  spi_env_config t;

  if (!uvm_config_db #(spi_env_config)::get(c, "", s_my_config_id, t) )
    `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction

// This task is a convenience method for sequences waiting for the interrupt
// signal
task spi_env_config::wait_for_interrupt;
  INTR.wait_for_interrupt();
endtask: wait_for_interrupt

// Check that interrupt has cleared:
function bit spi_env_config::is_interrupt_cleared;
  return INTR.is_interrupt_cleared();
endfunction: is_interrupt_cleared
