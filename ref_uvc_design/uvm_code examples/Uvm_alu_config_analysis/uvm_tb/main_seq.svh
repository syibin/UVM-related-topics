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

`ifndef MAIN_SEQ
`define MAIN_SEQ


class main_seq extends uvm_sequence #(alu_txn, alu_txn);
`uvm_object_utils(main_seq)
 function new(string name="");
  super.new(name);
 endfunction

 init_seq init_s;
 main_stim_seq main_stim_s;
 cleanup_seq cleanup_s;

 task body();
  `uvm_info("COMPOSITE SEQUENCE","Starting add, sub, Mul, div sequences",
	    UVM_LOW)   
   // start sequences
   init_s = init_seq::type_id::create("init_s");
   main_stim_s = main_stim_seq::type_id::create("main_stim_s");
   cleanup_s = cleanup_seq::type_id::create("cleanup_s");
   init_s.start(m_sequencer, this);
   main_stim_s.start(m_sequencer, this);
   cleanup_s.start(m_sequencer, this);
 endtask

endclass


`endif
