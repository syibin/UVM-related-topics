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
// This example demonstrates sequencer lock and grab.
//
// It builds on the priority example but adds a lock sequence and a grab
// sequence which run with a very low priority (50). The example can be run
// with a command line switch to show how lock and grab interact, but the
// transcript shown in the cookbook is for the default - SEQ_ARB_FIFO
//
// It contains a sequence which runs 6 sub-sequences on a driver
// which counts how many sequence_items it has received from each
// sub-sequencer. To add some interest, the sub-sequences have different
// priorities and are offset in time. seq_4, grab and lock are run in the same
// parallel thread:
//
// seq_1 - Has priority 500 (highest) and generates new items after a delay of #1;
// seq_2 - Has priority 500 (joint-highest) and generates new items after a delay of #2;
// seq_3 - Has priority 300 (medium) and generates new items after a delay of #3;
// seq_4 - Has priority 200 (lowest) and generates new items after a delay of #4;
// seq_5l  - Lock sequence has priority 50 (even lower)
// seq_5g  - Grab sequence has priority 50 (even lower)
//
// To run the different examples type the following at the vsim command line:
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
int grab_seq = 0;
int lock_seq = 0;

function new(string name = "seq_arb_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  seq_arb_item REQ;

  forever begin
    seq_item_port.get_next_item(REQ);
    case(REQ.seq_no)
      1: seq_1++;
      2: seq_2++;
      3: seq_3++;
      4: seq_4++;
      5: grab_seq++;
      6: lock_seq++;
    endcase
    `uvm_info("RCVD", 
	      $sformatf("Type: %0d S1:%0d S2:%0d S3:%0d S4:%0d GB:%0d LK:%0d", 
			REQ.seq_no,
			seq_1, seq_2, seq_3, seq_4, grab_seq, lock_seq), 
	      UVM_LOW);
    #10 seq_item_port.item_done(REQ);
  end
endtask: run_phase

function void report_phase(uvm_phase phase);
  if((seq_1 == 10) & (seq_2 == 10) & (seq_3 == 10) & (seq_4 == 3) & (grab_seq == 8) & (lock_seq == 4)) begin
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
  if(m_sequencer.is_blocked(this)) begin
    `uvm_info("is_blocked", "This sequence is blocked by a lock or a grab",
	      UVM_LOW);
  end
  repeat(1) begin
    start_item(REQ);
    finish_item(REQ);
  end
endtask: body

endclass: arb_seq

// The sequence which sends sequence items - four of these are run in parallel
class grab_seq extends uvm_sequence #(seq_arb_item);

`uvm_object_utils(grab_seq)

function new(string name = "grab_seq");
  super.new(name);
endfunction

task body;
  seq_arb_item REQ;

  if(m_sequencer.is_blocked(this)) begin
    `uvm_info("grab_seq", 
	      "This sequence IS BLOCKED by an existing lock in place",
	      UVM_LOW);
  end
  else begin
    `uvm_info("grab_seq", 
	      "This sequence is NOT blocked by an existing lock in place",
	      UVM_LOW);
  end

  // Grab call which blocks until grab has been granted
  m_sequencer.grab(this);

  if(m_sequencer.is_grabbed()) begin
    if(m_sequencer.current_grabber() != this) begin
      `uvm_info("grab_seq", 
		"Grab sequence waiting for current grab or lock to complete",
		UVM_LOW);
    end
  end

  REQ = seq_arb_item::type_id::create("REQ");
  REQ.seq_no = 5;
  repeat(4) begin
    start_item(REQ);
    finish_item(REQ);
  end

  // Ungrab which must be called to release the grab (lock)
  m_sequencer.ungrab(this);
endtask: body

endclass: grab_seq

class lock_seq extends uvm_sequence #(seq_arb_item);

`uvm_object_utils(lock_seq)

int seq_no;

function new(string name = "lock_seq");
  super.new(name);
endfunction

task body;
  seq_arb_item REQ;

  if(m_sequencer.is_blocked(this)) begin
    `uvm_info("lock_seq", "This sequence IS BLOCKED by an existing lock",
	      UVM_LOW);
  end
  else begin
    `uvm_info("lock_seq", "This sequence is NOT blocked by an existing lock",
	      UVM_LOW);
  end

  // Lock call - which blocks until it is granted
  m_sequencer.lock(this);

  if(m_sequencer.is_grabbed()) begin
    if(m_sequencer.current_grabber() != this) begin
      `uvm_info("lock_seq", 
		"Lock sequence waiting for current grab or lock to complete",
		UVM_LOW);
    end
  end

  REQ = seq_arb_item::type_id::create("REQ");
  REQ.seq_no = 6;
  repeat(4) begin
    start_item(REQ);
    finish_item(REQ);
  end

  // Unlock call - must be issued
  m_sequencer.unlock(this);
endtask: body

endclass: lock_seq

// Top level sequence which runs four sequences with different prioirty and time
// offsets. It also sets up the sequencer arbitration algorithm
class arb_example_seq extends uvm_sequence #(seq_arb_item);

`uvm_object_utils(arb_example_seq)

arb_seq seq_1, seq_2, seq_3, seq_4;
grab_seq seq_5g;
lock_seq seq_5l;

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
  seq_5g = grab_seq::type_id::create("seq_5g");
  seq_5l = lock_seq::type_id::create("seq_5l");


  m_sequencer.set_arbitration(arb_type);
  fork
    begin // Thread 1
      repeat(10) begin
	#1;
	seq_1.start(m_sequencer, this, 500); // Highest priority
      end
    end
    begin // Thread 2
      repeat(10) begin
	#2;
	seq_2.start(m_sequencer, this, 500); // Highest priority
      end
    end
    begin // Thread 3
      repeat(10) begin
	#3;
	seq_3.start(m_sequencer, this, 300); // Medium priority
      end
    end
    begin // Thread 4
      fork
	repeat(2) begin
          #4;
          seq_4.start(m_sequencer, this, 200); // Lowest priority
	end
	#10 seq_5g.start(m_sequencer, this, 50);
      join
      repeat(1) begin
	#4 seq_4.start(m_sequencer, this, 200);
      end
      fork
	seq_5l.start(m_sequencer, this, 200);
	#20 seq_5g.start(m_sequencer, this, 50);
      join
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

  phase.raise_objection(this, "Starting Grab-Lock test");
  if($value$plusargs("ARB_TYPE=%s", arb_type)) begin
    `uvm_info("Sequencer Arbitration selected:", arb_type, UVM_LOW);
  end
  else begin
    `uvm_warning("arb_test:", "The ARB_TYPE plusarg was not specified on the command line, using default");
    arb_type = "SEQ_ARB_FIFO";
  end

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
    phase.drop_objection(this, "Finishing Grab-Lock test");
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
