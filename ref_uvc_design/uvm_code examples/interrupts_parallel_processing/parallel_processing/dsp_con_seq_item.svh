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

class dsp_con_seq_item extends uvm_sequence_item;

`uvm_object_utils(dsp_con_seq_item)

rand bit[3:0] go;

function new(string name = "dsp_con_seq_item");
  super.new(name);
endfunction

function string convert2string();
  string s;

  s = super.convert2string;
  return $psprintf("%s\n go\t%b", s, go);
endfunction: convert2string

function void do_copy(uvm_object rhs);
  dsp_con_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy:", "Pre-copy cast failed")
  end
  super.copy(rhs);
  go = rhs_.go;
endfunction: do_copy

endclass: dsp_con_seq_item
