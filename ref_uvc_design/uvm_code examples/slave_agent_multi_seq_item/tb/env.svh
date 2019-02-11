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
class env extends uvm_env;

// UVM Factory Registration Macro
//
`uvm_component_utils(env)
//------------------------------------------
// Data Members
//------------------------------------------
apb_slave_agent slave_agent;
env_config m_cfg;

// Standard UVM Methods:
extern function new(string name = "env", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass:env

function env::new(string name = "env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void env::build_phase(uvm_phase phase);
  m_cfg = env_config::get_config(this);
  slave_agent = apb_slave_agent::type_id::create("slave_agent", this);
endfunction:build_phase

function void env::connect_phase(uvm_phase phase);
endfunction: connect_phase
