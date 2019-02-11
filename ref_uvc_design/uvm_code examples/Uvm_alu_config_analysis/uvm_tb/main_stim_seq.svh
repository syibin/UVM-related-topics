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

`ifndef MAIN_STIM_SEQ
`define MAIN_STIM_SEQ

class main_stim_seq extends uvm_sequence #(alu_txn, alu_txn);
`uvm_object_utils(main_stim_seq)

 function new(string name="");
   super.new(name);
 endfunction

 alu_seq ADD_s;
 alu_seq SUB_s;
 alu_seq MUL_s;
 alu_seq DIV_s;

 task body();
  fork
    begin
      ADD_s = alu_seq::type_id::create("ADD_s");
      if(!(ADD_s.randomize() with {ADD_s.op == ADD;}))
        `uvm_fatal("Main_stim_seq", "Randomization error")
      ADD_s.start(m_sequencer, this);
    end
    begin
      SUB_s = alu_seq::type_id::create("SUB_s");
      if(!(SUB_s.randomize() with {SUB_s.op == SUB;}))
        `uvm_fatal("Main_stim_seq", "Randomization error")
      SUB_s.start(m_sequencer, this);
    end
    begin
      MUL_s = alu_seq::type_id::create("MUL_s");
      if(!(MUL_s.randomize() with {MUL_s.op == MUL;}))
        `uvm_fatal("Main_stim_seq", "Randomization error")
      MUL_s.start(m_sequencer, this);
    end
    begin
      DIV_s = alu_seq::type_id::create("DIV_s");
      if(!(DIV_s.randomize() with {DIV_s.op == DIV;}))
        `uvm_fatal("Main_stim_seq", "Randomization error")
      DIV_s.start(m_sequencer, this);
    end
  join
 endtask 

endclass
`endif
