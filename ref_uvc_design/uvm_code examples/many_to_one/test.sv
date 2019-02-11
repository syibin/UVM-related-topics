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

import uvm_pkg::*;
import env_pkg::*;
import a_pkg::*;

//---------------------------------------------------------------------------
//
// CLASS: test
//
//---------------------------------------------------------------------------

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase( uvm_phase phase );
    e = env::type_id::create("env", this );
  endfunction

  task run_phase( uvm_phase phase );
    A_seq a_seq = A_seq::type_id::create("a_seq");

    phase.raise_objection( this );
    a_seq.start( e.abc.a_sequencer );
    #20;
    phase.drop_objection( this );
  endtask

  function void report_phase( uvm_phase phase );
    `uvm_info("** UVM TEST PASSED **", "Layered sequence completed successfully", UVM_LOW)
  endfunction: report_phase

endclass


//---------------------------------------------------------------------------
//
// MODULE: top
//
//---------------------------------------------------------------------------

module top;
  initial begin
    run_test();
  end
endmodule
