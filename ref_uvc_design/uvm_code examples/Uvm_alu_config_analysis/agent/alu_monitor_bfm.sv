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

import alu_agent_pkg::*;
//----------------------------------------------
interface alu_monitor_bfm (input clk,
                           input[15:0] val1,
                           input[15:0] val2,
                           input valid_i,
                           input valid_o,
                           input op_type_t mode,
                           input shortint unsigned result,
                           input[31:0] txn_id);

  import alu_agent_pkg::*;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  alu_monitor proxy;
  

 // run task
 task run();
  alu_txn result_txn;
  forever begin
   @ (negedge clk)
   if(valid_o) begin
    result_txn = alu_txn::type_id::create("result_txn");
    result_txn.result = result;
    result_txn.val1 = val1;
    result_txn.val2 = val2;
    result_txn.mode = mode;
    result_txn.id   = txn_id;
    proxy.write(result_txn);
   end
  end  
 endtask
endinterface : alu_monitor_bfm

