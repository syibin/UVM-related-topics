//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
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

class signal_seq_item extends uvm_sequence_item;

`uvm_object_utils(signal_seq_item)

// The driver starts a frequency sweep when it receives this
// item - no stimulus input

// For analysis
int freq;


// Standard UVM Methods:
extern function new(string name = "signal_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass: signal_seq_item

function signal_seq_item::new(string name = "signal_seq_item");
  super.new(name);
endfunction

function void signal_seq_item::do_copy(uvm_object rhs);
  signal_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  freq = rhs_.freq;

endfunction:do_copy

function bit signal_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  signal_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         freq == rhs_.freq;
  // Delay is not relevant to the comparison
endfunction:do_compare

function string signal_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  // Convert to string function reusing s:
  $sformat(s, "%s\n freq\t%0d\n ", s, freq);
  return s;

endfunction:convert2string

function void signal_seq_item::do_print(uvm_printer printer);
  if(printer.knobs.sprint == 0) begin
    $display(convert2string());
  end
  else begin
    printer.m_string = convert2string();
  end
endfunction:do_print

function void signal_seq_item:: do_record(uvm_recorder recorder);
  super.do_record(recorder);

  // Use the record macros to record the item fields:
  `uvm_record_field("freq", freq)
endfunction:do_record
