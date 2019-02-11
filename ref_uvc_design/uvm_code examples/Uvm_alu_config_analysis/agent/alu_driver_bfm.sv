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
interface alu_driver_bfm (input clk,
                          output logic [15:0] val1,
                          output logic[15:0] val2,
                          output logic valid_i,
                          input valid_o,
                          output op_type_t mode,
                          input shortint unsigned result,
                          output logic[31:0] txn_id);


 
  task drive (alu_txn stim_txn, bit use_index_id = 0);
    @ (negedge clk);
    #5; // since can't do nonblocking in Monitor //TODO
    val1 <= stim_txn.val1;
    val2 <= stim_txn.val2;
    mode <= stim_txn.mode;        
//    v_alu_if.txn_id = stim_txn.txn_id;
    if (use_index_id)
      txn_id = stim_txn.index_id();
    else
      txn_id = stim_txn.get_transaction_id();
      valid_i <= 1;  // set valid_i
    @ (posedge clk)
      valid_i <= 0;  // clear valid_i
  endtask : drive

  task get_response(alu_txn stim_txn, alu_txn rsp_txn);
    @(negedge clk iff (valid_o == 1 && 
                       txn_id == stim_txn.index_id()))
      begin
        rsp_txn.val1  = val1;
        rsp_txn.val2  = val2;
        rsp_txn.mode  = mode;
        rsp_txn.id      = stim_txn.index_id();
      end
  endtask : get_response
    
endinterface : alu_driver_bfm

