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
//
// This library contains the three test cases used in the sequence
// generation examples from the on-line cookbook:
//
// bus_test_base - Takes care of the common set up and configuration
//
// seq_rand_test - How to use sequence randomization to configure a sequence
//
// complete_transfer_test - Using sequence object persistance
//
// rand_transfer_test - Sequences executed in a random order
//
//

package test_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import bus_agent_pkg::*;
import bus_seq_lib_pkg::*;

// All of the example test cases inherit from this base class
//
class bus_test_base extends uvm_test;

`uvm_component_utils(bus_test_base)

bus_agent m_agent;
bus_agent_config m_cfg;

function new(string name = "bus_test_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_cfg = bus_agent_config::type_id::create("m_cfg");
  if(!uvm_config_db #(virtual bus_if)::get(this, "", "BUS_vif", m_cfg.BUS)) begin
    `uvm_error("Build_phase", "Unable to find BUS_vif")
  end
  uvm_config_db #(bus_agent_config)::set(this, "*", "config", m_cfg);
  m_agent = bus_agent::type_id::create("m_agent", this);
endfunction: build_phase

  function void check_phase(uvm_phase phase);
    int errcnt;
    
`ifdef UVM_POST_VERSION_1_1 // UVM 1.2
    uvm_coreservice_t coreservice = uvm_coreservice_t::get();
    uvm_report_server rpt_server = coreservice.get_report_server();
`else //UVM 1.1d
    uvm_report_server rpt_server = uvm_report_server::get_server();
`endif //  `ifdef UVM_POST_VERSION_1_1
    errcnt = rpt_server.get_severity_count(UVM_ERROR);
    if(errcnt!=0) begin
      `uvm_info("** UVM TEST FAILED **",$sformatf("Number of errors: %0d",errcnt), UVM_LOW)
    end
    else begin
      `uvm_info("** UVM TEST PASSED **",$sformatf("Number of errors: %0d",errcnt), UVM_LOW)
      end
  endfunction // check_phase
  
endclass: bus_test_base

//
// This test shows how to randomize the memory_trans_seq
// to set it up for a block transfer
//
class seq_rand_test extends bus_test_base;

`uvm_component_utils(seq_rand_test)

function new(string name = "seq_rand_test", uvm_component parent = null);
  super.new(name);
endfunction

task run_phase(uvm_phase phase);
  mem_trans_seq seq = mem_trans_seq::type_id::create("seq");

  phase.raise_objection(this, "Starting test");
  // Using randomization and constraints to set the initial values
  //
  // This could also be done directly
  //
  if(!seq.randomize() with {src_addr == 32'h0100_0800;
                               dst_addr inside {[32'h0101_0000:32'h0103_0000]};
                               transfer_size == 128;}) begin
    `uvm_error("run_phase", "seq randomization failure")
  end
  seq.start(m_agent.m_sequencer);
  phase.drop_objection(this, "Finishing test");
endtask: run_phase

endclass: seq_rand_test

class complete_transfer_test extends bus_test_base;

`uvm_component_utils(complete_transfer_test)

function new(string name = "complete_transfer_test", uvm_component parent = null);
  super.new(name);
endfunction

task run_phase(uvm_phase phase);
  rpt_mem_trans_seq seq = rpt_mem_trans_seq::type_id::create("seq");

  phase.raise_objection(this, "Starting test");
  seq.start(m_agent.m_sequencer);
  phase.drop_objection(this, "Finishing test");
endtask: run_phase

endclass: complete_transfer_test

class rand_transfer_test extends bus_test_base;

`uvm_component_utils(rand_transfer_test)

function new(string name = "rand_transfer_test", uvm_component parent = null);
  super.new(name);
endfunction

task run_phase(uvm_phase phase);
  rand_order_seq seq = rand_order_seq::type_id::create("seq");

  phase.raise_objection(this, "Starting test");
  repeat(3) begin
    seq.start(m_agent.m_sequencer);
  end
  phase.drop_objection(this, "Finishing test");
endtask: run_phase

endclass: rand_transfer_test

endpackage: test_lib_pkg
