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
class gpio_agent_config extends uvm_object;

localparam string s_my_config_id = "gpio_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

// UVM Factory Registration Macro
//
`uvm_object_utils(gpio_agent_config)

// BFM Virtual Interfaces
virtual gpio_monitor_bfm mon_bfm;
virtual gpio_driver_bfm  drv_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
// Is the agent active or passive
uvm_active_passive_enum active = UVM_ACTIVE;
// Does the external clock interface need to be monitored or not
bit monitor_external_clock = 0;

//------------------------------------------
// Methods
//------------------------------------------
extern static function gpio_agent_config get_config( uvm_component c );
// Standard UVM Methods:
extern function new(string name = "gpio_agent_config");

endclass: gpio_agent_config

function gpio_agent_config::new(string name = "gpio_agent_config");
  super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function gpio_agent_config gpio_agent_config::get_config( uvm_component c );
  gpio_agent_config t;

  if (!uvm_config_db #(gpio_agent_config)::get(c, "", s_my_config_id, t) )
     `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

  return t;
endfunction
