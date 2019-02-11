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
// This example demonstrates the 6 sequence priority algorithms
// available via the uvm_sequencer.
//
// It contains a sequence which runs 4 sub-sequences on a driver
// which counts how many sequence_items it has received from each
// sub-sequencer. To add some interest, the sub-sequences have different
// priorities and are offset in time:
//
// seq_1 - Has priority 500 (highest) and generates new items after a delay of #1;
// seq_2 - Has priority 500 (joint-highest) and generates new items after a delay of #2;
// seq_3 - Has priority 300 (medium) and generates new items after a delay of #3;
// seq_4 - Has priority 200 (lowest) and generates new items after a delay of #4;
//
// To run the different examples then the following needs to typed at the vsim command line:
//
// vsim +ARB_TYPE=<arb_type> top -do "run -all"
//
// Where ARB_TYPE is one of SEQ_ARB_FIFO, SEQ_ARB_WEIGHTED, SEQ_ARB_RANDOM,
//                          SEQ_ARB_STRICT_FIFO, SEQ_ARB_STRICT_RANDOM,
//                          SEQ_ARB_USER
//
// The driver will display a log of how many sequence items have been received
// from each sequence.
//
// The user arbitration method implemented for the SEQ_ARB_USER option is to always
// select the item last added to the sequence_item queue. This is the inverse of
// the default algorithm (SEQ_ARB_FIFO).

package seq_arb_priorities_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// This item carries the number of the sequence from
// which it was sent
class seq_arb_item extends uvm_sequence_item;

int seq_no;

`uvm_object_utils(seq_arb_item)

function new(string name = "seq_arb_item");
  super.new(name);
endfunction

endclass: seq_arb_item

// Receives sequence items the sequences and and keeps a running total
class seq_arb_driver extends uvm_driver #(seq_arb_item);

`uvm_component_utils(seq_arb_driver)

// Counters to keep track of sequence accesses
int seq_1 = 0;
int seq_2 = 0;
int seq_3 = 0;
int seq_4 = 0;

function new(string name = "seq_arb_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  seq_arb_item REQ;

  forever begin
    seq_item_port.get(REQ);
    case(REQ.seq_no)
      1: seq_1++;
      2: seq_2++;
      3: seq_3++;
      4: seq_4++;
    endcase
    `uvm_info("RCVD", $sformatf("Totals: SEQ_1:%0d SEQ_2:%0d SEQ_3:%0d SEQ_4:%0d", seq_1, seq_2, seq_3, seq_4), UVM_LOW)
    #10;
  end
endtask: run_phase

function void report_phase(uvm_phase phase);
  if((seq_1 == 4) & (seq_2 == 4) & (seq_3 == 4) & (seq_4 == 4)) begin
    `uvm_info("SEQ_ARB_TEST", "* UVM TEST PASSED *", UVM_LOW)
  end
  else begin
    `uvm_error("SEQ_ARB_TEST", "! UVM TEST FAILED !")
  end

endfunction


endclass: seq_arb_driver

// This sequencer implementation contains an overloaded user_priority_arbitration method
// to illustrate how to implement the SEQ_ARB_USER approach
class seq_arb_sequencer extends uvm_sequencer #(seq_arb_item);

`uvm_component_utils(seq_arb_sequencer)

function new(string name = "seq_arb_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

// This method overrides the default user method
// It returns the last item in the sequence queue rather than the first
// Note that the following code is inside a compile switch since UVM 1800 uses ints rather than
// integers - this is to allow UVM 1.2 to run if a +define+UVM_1_2 is used when compiling
`ifdef UVM_1_2
function integer user_priority_arbitration(integer avail_sequences[$]);
  integer end_index;
  end_index = avail_sequences.size() - 1;
  return (avail_sequences[end_index]);
endfunction // user_priority_arbitration
`else
function int user_priority_arbitration(int avail_sequences[$]);
  int end_index;
  end_index = avail_sequences.size() - 1;
  return (avail_sequences[end_index]);
endfunction // user_priority_arbitration
`endif

endclass: seq_arb_sequencer

// The sequence which sends sequence items - four of these are run in parallel
class arb_seq extends uvm_sequence #(seq_arb_item);

`uvm_object_utils(arb_seq)

int seq_no;

function new(string name = "arb_seq");
  super.new(name);
endfunction

task body;
  seq_arb_item REQ;

  REQ = seq_arb_item::type_id::create("REQ");
  REQ.seq_no = seq_no;
  repeat(1) begin
    start_item(REQ);
    finish_item(REQ);
  end
endtask: body

endclass: arb_seq

// Top level sequence which runs four sequences with different prioirty and time
// offsets. It also sets up the sequencer arbitration algorithm
class arb_example_seq extends uvm_sequence #(seq_arb_item);

`uvm_object_utils(arb_example_seq)

arb_seq seq_1, seq_2, seq_3, seq_4;
// SEQ_ARB_TYPE changed to UVM_SEQ_ARB_TYPE in UVM1.2
UVM_SEQ_ARB_TYPE arb_type;

   
function new(string name = "arb_example_seq");
  super.new(name);
endfunction

task body;
  seq_1 = arb_seq::type_id::create("seq_1");
  seq_1.seq_no = 1;
  seq_2 = arb_seq::type_id::create("seq_2");
  seq_2.seq_no = 2;
  seq_3 = arb_seq::type_id::create("seq_3");
  seq_3.seq_no = 3;
  seq_4 = arb_seq::type_id::create("seq_4");
  seq_4.seq_no = 4;

  m_sequencer.set_arbitration(arb_type);
  fork
    begin
      repeat(4) begin
        #1;
        seq_1.start(m_sequencer, this, 500); // Highest priority
      end
    end
    begin
      repeat(4) begin
        #2;
        seq_2.start(m_sequencer, this, 500); // Highest priority
      end
    end
    begin
      repeat(4) begin
        #3;
        seq_3.start(m_sequencer, this, 300); // Medium priority
      end
    end
    begin
      repeat(4) begin
        #4;
        seq_4.start(m_sequencer, this, 200); // Lowest priority
      end
    end
  join

endtask: body

endclass: arb_example_seq

// Overall test class that builds the test bench and sets the arbitration
// algorithm according to the ARB_TYPE plusarg
class arb_test extends uvm_component;

`uvm_component_utils(arb_test)

seq_arb_driver m_driver;
seq_arb_sequencer m_sequencer;
arb_example_seq m_seq;

function new(string name = "arb_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_driver = seq_arb_driver::type_id::create("m_driver", this);
  m_sequencer = seq_arb_sequencer::type_id::create("m_sequencer", this);
  m_seq = arb_example_seq::type_id::create("m_seq", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
endfunction: connect_phase

task run_phase(uvm_phase phase);
  string arb_type;

  phase.raise_objection(this, "Starting arbitration test");
  if($value$plusargs("ARB_TYPE=%s", arb_type)) begin
    `uvm_info("Sequencer Arbitration selected:", {"UVM_", arb_type}, UVM_LOW);
  end
  else begin
    uvm_report_fatal("arb_test:", "The ARB_TYPE plusarg was not specified on the command line");
  end

// SEQ_ARB_TYPE changed to UVM_SEQ_ARB_TYPE in UVM1.2
   
  case(arb_type)
    "SEQ_ARB_FIFO": m_seq.arb_type = UVM_SEQ_ARB_FIFO;
    "SEQ_ARB_WEIGHTED": m_seq.arb_type = UVM_SEQ_ARB_WEIGHTED;
    "SEQ_ARB_RANDOM": m_seq.arb_type = UVM_SEQ_ARB_RANDOM;
    "SEQ_ARB_STRICT_FIFO": m_seq.arb_type = UVM_SEQ_ARB_STRICT_FIFO;
    "SEQ_ARB_STRICT_RANDOM": m_seq.arb_type = UVM_SEQ_ARB_STRICT_RANDOM;
    "SEQ_ARB_USER": m_seq.arb_type = UVM_SEQ_ARB_USER;
  endcase
  
  m_seq.start(m_sequencer);
  #100;
  phase.drop_objection(this, "Finishing arbitration test");
endtask: run_phase

endclass: arb_test

endpackage: seq_arb_priorities_pkg

// Top level test bench
module top;

import uvm_pkg::*;
import seq_arb_priorities_pkg::*;

initial
  begin
    run_test("arb_test");
  end

endmodule: top
