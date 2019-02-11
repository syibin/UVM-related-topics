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

class signal_sweep_seq extends uvm_sequence #(signal_seq_item);

`uvm_object_utils(signal_sweep_seq)

extern function new(string name = "signal_sweep_seq");
extern task body;

endclass: signal_sweep_seq

function signal_sweep_seq::new(string name = "signal_sweep_seq");
  super.new(name);
endfunction

task signal_sweep_seq::body;

  signal_seq_item item = signal_seq_item::type_id::create("item");

  start_item(item);
  finish_item(item);

endtask: body