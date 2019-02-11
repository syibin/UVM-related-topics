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

package env_top_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import env_1_pkg::*;
import env_2_pkg::*;

class env_top extends uvm_env;

`uvm_component_utils(env_top)

env_1 m_env_1;
env_2 m_env_2;

function new(string name = "env_top", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_env_1 = env_1::type_id::create("m_env_1", this);
  m_env_2 = env_2::type_id::create("m_env_2", this);
endfunction: build_phase

endclass: env_top

endpackage: env_top_pkg
