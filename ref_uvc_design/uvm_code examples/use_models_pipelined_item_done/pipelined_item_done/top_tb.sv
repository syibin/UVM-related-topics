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
// Package contains a simple env containing the mbus_agent
// and the mbus_test
//
package mbus_pipelined_env_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import mbus_pipelined_agent_pkg::*;

class mbus_pipelined_env extends uvm_component;

`uvm_component_utils(mbus_pipelined_env)

function new(string name = "mbus_pipelined_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

mbus_pipelined_agent m_mbus_agent;

function void build_phase(uvm_phase phase);
  m_mbus_agent = mbus_pipelined_agent::type_id::create("m_bus_agent", this);
endfunction: build_phase

endclass: mbus_pipelined_env

class mbus_test extends uvm_test;

`uvm_component_utils(mbus_test)

function new(string name = "mbus_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

mbus_pipelined_env m_env;
mbus_pipelined_agent_config mbus_agent_cfg;

// Sequences which are global because they have error checking
// in them which needs to be interogated during the report_phase
mbus_unpipelined_seq     t_seq_1;
mbus_pipelined_seq       t_seq_2;
mbus_pipelined_check_seq t_seq_3;
mbus_pipelined_check_seq t_seq_4;

function void build_phase(uvm_phase phase);
//  set_config_int("*", "recording_detail", UVM_FULL);
  uvm_config_db #(int)::set(null, "*", "recording_detail", UVM_FULL);
  mbus_agent_cfg = mbus_pipelined_agent_config::type_id::create("mbus_agent_cfg");
  if (!uvm_config_db #(virtual mbus_pipelined_driver_bfm)::get(this, "", "mbus_pipelined_drv", mbus_agent_cfg.driver_bfm)) begin
    `uvm_fatal("Build", "uvm_config_db #(virtual mbus_pipelined_driver_bfm)::get(...) failed");
  end
  uvm_config_db #(mbus_pipelined_agent_config)::set(this, "*", "mbus_agent_config", mbus_agent_cfg);
  m_env = mbus_pipelined_env::type_id::create("menv", this);
endfunction: build_phase

task run_phase(uvm_phase phase);
  phase.raise_objection(this, "Starting test");
  t_seq_1 = mbus_unpipelined_seq::type_id::create("t_seq_1");
  t_seq_2 = mbus_pipelined_seq::type_id::create("t_seq_2");
  t_seq_3 = mbus_pipelined_check_seq::type_id::create("t_seq_3");
  t_seq_3.base_address = 32'h0010_0000;
  t_seq_4 = mbus_pipelined_check_seq::type_id::create("t_seq_4");
  t_seq_4.base_address = 32'h0012_0000;

  t_seq_1.start(m_env.m_mbus_agent.m_sequencer);
  t_seq_2.start(m_env.m_mbus_agent.m_sequencer);
  fork
    t_seq_3.start(m_env.m_mbus_agent.m_sequencer);
    t_seq_4.start(m_env.m_mbus_agent.m_sequencer);
  join
  phase.drop_objection(this, "Ending test");
endtask: run_phase

function void report_phase(uvm_phase phase);
  if ((t_seq_1.error_count == 0) && (t_seq_3.error_count == 0) && (t_seq_4.error_count == 0)) begin
    `uvm_info("** UVM TEST PASSED **", "No errors occurred", UVM_LOW)
  end
  else begin
    `uvm_error("** UVM TEST FAILED **", "Errors occurred")
  end
endfunction: report_phase

endclass: mbus_test

endpackage: mbus_pipelined_env_pkg

module top_tb;

import uvm_pkg::*;
import mbus_pipelined_env_pkg::*;

initial begin
  run_test("mbus_test");
end

endmodule: top_tb
