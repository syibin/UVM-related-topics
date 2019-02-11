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

package env_2_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import agent_a_pkg::*;
import agent_b_pkg::*;

class env_2 extends uvm_env;

`uvm_component_utils(env_2)

b_agent m_agent_b;
a_agent m_agent_a;

function new(string name = "env_2", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_agent_b = b_agent::type_id::create("m_agent_b", this);
  m_agent_a = a_agent::type_id::create("m_agent_a", this);
endfunction: build_phase

endclass: env_2

endpackage: env_2_pkg
