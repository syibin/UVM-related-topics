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
class gpio_reg_test extends gpio_test_base;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(gpio_reg_test)

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "gpio_reg_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: gpio_reg_test

function gpio_reg_test::new(string name = "gpio_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void gpio_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_env_cfg.has_in_scoreboard = 0;
endfunction: build_phase

task gpio_reg_test::run_phase(uvm_phase phase);
  reg_test_vseq test_seq = reg_test_vseq::type_id::create("test_seq");
  assign_seqs(test_seq);

  phase.raise_objection(this, "gpio_reg_test");

  test_seq.start(null);

  #100ns;
  phase.drop_objection(this, "gpio_reg_test");
endtask: run_phase
