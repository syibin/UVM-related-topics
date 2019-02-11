//------------------------------------------------------------
//   Copyright 2011-2018 Mentor Graphics Corporation
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

package env_1_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import agent_a_pkg::*;
import agent_c_pkg::*;

class env_1 extends uvm_env;

`uvm_component_utils(env_1)

a_agent m_agent_a;
c_agent m_agent_c;

function new(string name = "env_1", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_agent_a = a_agent::type_id::create("m_agent_a", this);
  m_agent_c = c_agent::type_id::create("m_agent_c", this);
endfunction: build_phase

endclass: env_1

endpackage: env_1_pkg
