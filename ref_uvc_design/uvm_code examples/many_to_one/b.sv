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

package b_pkg;

import uvm_pkg::*;


//---------------------------------------------------------------------------
//
// CLASS: B_item
//
//---------------------------------------------------------------------------
class B_item extends uvm_sequence_item;
  `uvm_object_utils(B_item)

  rand byte fb[$];
  rand byte burst_len;

  constraint small_burst_len_range { burst_len > 1 && burst_len < 10; }
  constraint byte_zero_is_length { fb[0] == burst_len; }
  constraint length_is_consistent { burst_len == fb.size() - 1; }

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
    string s = "{";
    foreach (fb[i]) s = {s, $psprintf(" %2h",fb[i])};
    return {s,"}"};
  endfunction
endclass



typedef uvm_sequencer #(B_item) B_sequencer;

endpackage
