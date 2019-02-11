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
class gpio_test extends gpio_test_base;

  // UVM Factory Registration Macro
  //
  `uvm_component_utils(gpio_test)

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods:
  extern function new(string name = "gpio_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: gpio_test

function gpio_test::new(string name = "gpio_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Build the env, create the env configuration
// including any sub configurations and assigning virtural interfaces
function void gpio_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase

task gpio_test::run_phase(uvm_phase phase);
  check_reset_seq reset_test_seq = check_reset_seq::type_id::create("reset_test_seq");
  gpio_toggle_test_seq gpio_toggle_seq = gpio_toggle_test_seq::type_id::create("gpio_toggle_seq");
  phase.raise_objection(this, "gpio_test");

  reset_test_seq.start(m_env.m_v_sqr.apb);
  gpio_toggle_seq.start(m_env.m_v_sqr.apb);

  #100ns;
  phase.drop_objection(this, "gpio_test");
endtask: run_phase
