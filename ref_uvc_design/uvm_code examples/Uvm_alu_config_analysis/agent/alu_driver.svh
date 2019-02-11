//------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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


//----------------------------------------------
class alu_driver extends uvm_driver #(alu_txn, alu_txn);
 `uvm_component_utils(alu_driver)
 //ports
 uvm_analysis_port   #(alu_txn) stim_ap;
 
 alu_agent_config m_cfg;
 semaphore pipeline_lock  = new(1);
 
 // virtual interface
 protected virtual alu_driver_bfm bfm;

 // constructor
 function new( string name, uvm_component parent) ;
  super.new( name , parent );
 endfunction


 
 function void build_phase(uvm_phase phase);
   if(m_cfg == null) begin   
     if(!uvm_config_db#(alu_agent_config)::get(this, "", s_alu_config_id, m_cfg)) begin
       begin
         `uvm_fatal("alu_driver", "Failed to get m_cfg");
       end
     end
   end
   bfm = m_cfg.drv_bfm;   
   stim_ap = new("stim_ap", this);

 endfunction
 
 // run task
 // has a response where sc_driver does not
 task run_phase(uvm_phase phase);
   fork
     do_txn(0);
     do_txn(1);
   join
 endtask // run_phase
  
 task do_txn(input int id);
   alu_txn stim_txn;
   alu_txn rsp_txn;
   rsp_txn = alu_txn::type_id::create("rsp");
  forever begin
    pipeline_lock.get();
    seq_item_port.get_next_item(stim_txn);
    stim_ap.write(stim_txn);
    bfm.drive(stim_txn, .use_index_id(1));
    seq_item_port.item_done();
    pipeline_lock.put(); // unlock semaphore
    bfm.get_response(stim_txn, rsp_txn);  
    rsp_txn.set_id_info(stim_txn);
    seq_item_port.put(rsp_txn);
  end  
 endtask
 
endclass

