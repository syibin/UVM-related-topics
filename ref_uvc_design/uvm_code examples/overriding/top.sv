//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//
// This example shows how you can use two types of sequence
// override
//
// Type - which is the usual
// Instance - which requires a "trick" to add a third path argument
//            to the create method
//
package seq_override_test_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import a_agent_pkg::*;

class sot_env  extends uvm_env;

`uvm_component_utils(sot_env)

a_agent m_a_agent;

function new(string name = "skt_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_a_agent = a_agent::type_id::create("m_a_agent", this);
endfunction: build_phase

endclass: sot_env

class sot_test extends uvm_test;

`uvm_component_utils(sot_test)

sot_env m_env;

function new(string name = "sot_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

//
// The build method of a test class:
//
// Inheritance:
//
// a_seq <- b_seq <- c_seq
//
function void build_phase(uvm_phase phase);
  m_env = sot_env::type_id::create("m_env", this);
  // Set type override
  b_seq::type_id::set_type_override(c_seq::get_type());
  // Set instance override - Note the "path" argument see the line for s_a creation
  // in the run method
  a_seq::type_id::set_inst_override(c_seq::get_type(), "bob.s_a");
endfunction: build_phase

//
// Run method
//
task run_phase(uvm_phase phase);
  a_seq s_a; // Base type
  b_seq s_b; // b_seq extends a_seq
  c_seq s_c; // c_seq extends b_seq

  // Instance name is "s_a" - first argument,
  // path name is "bob" but is more usually get_full_name() - third argument
  s_a = a_seq::type_id::create("s_a",,"bob");
  // More usual create call
  s_b = b_seq::type_id::create("s_b");
  s_c = c_seq::type_id::create("s_c");

  phase.raise_objection(this, "starting test");
  s_a.start(m_env.m_a_agent.m_sequencer); // Results in c_seq being executed
  s_b.start(m_env.m_a_agent.m_sequencer); // Results in c_seq being executed
  s_c.start(m_env.m_a_agent.m_sequencer);
  phase.drop_objection(this, "finishing_test");

endtask: run_phase

endclass: sot_test

endpackage: seq_override_test_pkg

module top_tb;

import uvm_pkg::*;
import seq_override_test_pkg::*;

initial begin
  run_test("sot_test");
end

endmodule: top_tb
