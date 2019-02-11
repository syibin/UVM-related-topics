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

package top_vseq_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import agent_a_pkg::*;
import agent_b_pkg::*;
import agent_c_pkg::*;

class top_vseq_base extends uvm_sequence #(uvm_sequence_item);

`uvm_object_utils(top_vseq_base)

uvm_sequencer #(a_seq_item) A1;
uvm_sequencer #(a_seq_item) A2;
uvm_sequencer #(b_seq_item) B;
uvm_sequencer #(c_seq_item) C;

function new(string name = "top_vseq_base");
  super.new(name);
endfunction

endclass: top_vseq_base

class vseq_A1_B_C extends top_vseq_base;

`uvm_object_utils(vseq_A1_B_C)

function new(string name = "vseq_A1_B_C");
  super.new(name);
endfunction

task body();
  a_seq a = a_seq::type_id::create("a");
  b_seq b = b_seq::type_id::create("b");
  c_seq c = c_seq::type_id::create("c");

  a.start(A1);
  fork
    b.start(B);
    c.start(C);
  join

endtask: body

endclass: vseq_A1_B_C

class vseq_A1_B_A2_A1 extends top_vseq_base;

`uvm_object_utils(vseq_A1_B_A2_A1)

function new(string name = "vseq_A1_B_A2_A1");
  super.new(name);
endfunction

task body();
  a_seq a = a_seq::type_id::create("a");
  b_seq b = b_seq::type_id::create("b");
  a_seq a2 = a_seq::type_id::create("a2");

  a.start(A1);
  fork
    b.start(B);
    a2.start(A2);
  join
  a.start(A1);

endtask: body

endclass: vseq_A1_B_A2_A1

endpackage: top_vseq_pkg
