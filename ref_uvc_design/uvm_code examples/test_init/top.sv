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

package test_top_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import env_top_pkg::*;
import top_vseq_pkg::*;
import agent_a_pkg::*;
import agent_b_pkg::*;
import agent_c_pkg::*;

class test_top_base extends uvm_test;

`uvm_component_utils(test_top_base)

env_top m_env;

function new(string name = "test_top_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_env = env_top::type_id::create("m_env", this);
endfunction: build_phase

// Initialise the virtual sequence handles
function void init_vseq(top_vseq_base vseq);
  vseq.A1 = m_env.m_env_1.m_agent_a.m_sequencer;
  vseq.C = m_env.m_env_1.m_agent_c.m_sequencer;
  vseq.A2 = m_env.m_env_2.m_agent_a.m_sequencer;
  vseq.B = m_env.m_env_2.m_agent_b.m_sequencer;
endfunction: init_vseq

endclass: test_top_base

class init_vseq_from_test extends test_top_base;

`uvm_component_utils(init_vseq_from_test)

function new(string name = "init_vseq_from_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  vseq_A1_B_C vseq = vseq_A1_B_C::type_id::create("vseq");
  vseq_A1_B_A2_A1 vseq_2 = vseq_A1_B_A2_A1::type_id::create("vseq_2");


  phase.raise_objection(this);

  init_vseq(vseq);  // Using method from test base class to assign sequence handles
  vseq.start(null); // null because no target sequencer
  init_vseq(vseq_2);
  vseq_2.start(null);
  phase.drop_objection(this);
endtask: run_phase

function void report_phase(uvm_phase phase);
  if((m_env.m_env_1.m_agent_a.m_driver.i == 9) &&
     (m_env.m_env_1.m_agent_c.m_driver.i == 5) &&
     (m_env.m_env_2.m_agent_a.m_driver.i == 3) &&
     (m_env.m_env_2.m_agent_b.m_driver.i == 20)) begin
     `uvm_info("** UVM TEST PASSED **", "All transactions delivered correctly", UVM_NONE)
  end
  else begin
     `uvm_error("** UVM TEST FAILED **", "Wrong number of transactions delivered")
  end
endfunction: report_phase


endclass: init_vseq_from_test

endpackage: test_top_pkg

module top_tb;

import uvm_pkg::*;
import test_top_pkg::*;

initial
  run_test();

endmodule: top_tb
