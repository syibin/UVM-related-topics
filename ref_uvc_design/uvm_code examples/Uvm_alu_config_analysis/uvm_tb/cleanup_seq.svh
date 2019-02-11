//------------------------------------------------------------
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
//------------------------------------------------------------

`ifndef CLEANUP_SEQ
`define CLEANUP_SEQ

class cleanup_seq extends uvm_sequence #(alu_txn, alu_txn);
`uvm_object_utils(cleanup_seq)

  function new(string name="");
    super.new(name);
                  $display("here 1");

  endfunction

  task body();
    // does nothing
    `uvm_info("CLEANUP", "Cleanup Sequence", UVM_LOW)
  endtask 

endclass

`endif
