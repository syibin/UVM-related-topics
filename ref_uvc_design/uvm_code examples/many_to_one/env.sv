//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

`include "uvm_macros.svh"

package env_pkg;

import uvm_pkg::*;

import abc_pkg::*;
import c_pkg::*;


//---------------------------------------------------------------------------
//
// CLASS: env
//
//---------------------------------------------------------------------------

class env extends uvm_env;
  `uvm_component_utils( env );

  ABC_layering abc;
  C_agent c_agent;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    abc = ABC_layering::type_id::create("abc",this);
    c_agent = C_agent::type_id::create("c_agent",this);
  endfunction

  function void connect_phase( uvm_phase phase );
    abc.connect_to_C_agent( c_agent );
//
// OR ...
//
// abc.c_agent = c_agent;
// c_agent.ap.connect( abc.analysis_export );
//
  endfunction

endclass

endpackage

