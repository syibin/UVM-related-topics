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

class alu_tlm extends uvm_subscriber #(alu_txn);
 `uvm_component_utils(alu_tlm)

 uvm_analysis_port #(alu_txn) results_ap;

 function new(string name, uvm_component parent );
  super.new( name , parent );
 endfunction

 function void build_phase(uvm_phase phase);
  results_ap = new("results_ap", this);
 endfunction

 function void write( alu_txn t);
  alu_txn out_txn;
  case(t.mode)
   ADD: t.result = t.val1 + t.val2;
   SUB: t.result = t.val1 - t.val2;
   MUL: t.result = t.val1 * t.val2;
   DIV: t.result = t.val1 / t.val2;
  endcase      
  $cast(out_txn,t.clone());
  results_ap.write(out_txn);
 endfunction

endclass

