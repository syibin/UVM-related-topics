//------------------------------------------------------------
//   Copyright 2012-2018 Mentor Graphics Corporation
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
class send_10_test extends spi_test_base;

// UVM Factory Registration Macro
//
`uvm_component_utils(send_10_test)

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "send_10_test", uvm_component parent = null);
extern task run_phase(uvm_phase phase);

endclass: send_10_test

function send_10_test::new(string name = "send_10_test", uvm_component parent = null);
  super.new(name, parent);
endfunction


//
// This task starts the c program that then calls back into
// the UVM simulation
//
task send_10_test::run_phase(uvm_phase phase);
  send_10_char_vseq spi_seq = send_10_char_vseq::type_id::create("spi_seq");


  phase.raise_objection(this, "Test Started");
  spi_seq.start(null);
  phase.drop_objection(this, "Test Finished");

endtask: run_phase
