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


class alu_seq extends uvm_sequence #(alu_txn, alu_txn);
`uvm_object_utils(alu_seq)
 alu_txn txn, rsp;
 rand op_type_t op;
  alu_agent_config m_cfg;

 function new(string name = "alu_seq");
  super.new(name);
 endfunction

 task body();
  while (!done[op]) begin
    txn = alu_txn::type_id::create("txn");
    start_item(txn);
    if(!(txn.randomize() with {mode == op;}))
       `uvm_fatal("alu_seq", "Randomize error");
    finish_item(txn);
    get_response(rsp);
  end
 endtask

endclass


