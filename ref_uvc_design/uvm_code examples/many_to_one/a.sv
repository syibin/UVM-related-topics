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

package a_pkg;

import uvm_pkg::*;


//---------------------------------------------------------------------------
//
// CLASS: A_item
//
//---------------------------------------------------------------------------

class A_item extends uvm_sequence_item;
  `uvm_object_utils(A_item)

  function new(string name="");
    super.new(name);
  endfunction

  rand byte fa;

  virtual function string convert2string();
    return $psprintf("fa=%2h",fa);
  endfunction

endclass

//---------------------------------------------------------------------------
//
// CLASS: A_seq
//
// The sequence we want to reuse
//
//---------------------------------------------------------------------------

class A_seq extends uvm_sequence #(A_item);
  `uvm_object_utils(A_seq);

  function new(string name="");
    super.new(name);
  endfunction

  virtual task body();
    A_item a;

    for(int i = 0; i<7; i++) begin
      a = A_item::type_id::create($psprintf("A_item%0d",i),,
                                  get_full_name());

      start_item(a);
      if( !a.randomize() with { fa != 8'hFF;}) begin
        `uvm_error("randomization error" , a.convert2string() );
      end
      `uvm_info(get_name(),{"Executing ",a.convert2string()},UVM_MEDIUM)
      finish_item(a);
    end

    a = A_item::type_id::create("A terminator ",,get_full_name());

    start_item(a);
    a.fa = 8'hFF;
    `uvm_info(get_name(),{"Terminating A_seq ",a.convert2string()},UVM_MEDIUM)
    finish_item(a);

  endtask
endclass

typedef uvm_sequencer #(A_item) A_sequencer;

endpackage
