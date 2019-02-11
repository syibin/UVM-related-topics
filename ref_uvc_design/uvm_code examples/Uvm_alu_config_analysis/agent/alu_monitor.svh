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

//----------------------------------------------
class alu_monitor extends uvm_component;
 //ports
 uvm_analysis_port #(alu_txn) mon_ap; 
 
 alu_agent_config m_cfg;

 `uvm_component_utils(alu_monitor)

 // virtual interface
 local virtual alu_monitor_bfm bfm;

 // constructor
 function new( string name = "alu_monitor", uvm_component parent = null) ;
   super.new( name , parent );
   mon_ap = new("mon_ap", this);
 endfunction

 function void set_bfm(virtual alu_monitor_bfm alu_bfm);
  bfm = alu_bfm;
  bfm.proxy = this;
 endfunction : set_bfm
 
 function void build_phase(uvm_phase phase);
   if(m_cfg == null) begin
     if(!uvm_config_db#(alu_agent_config)::get(this, "", s_alu_config_id, m_cfg)) begin
       begin
         `uvm_fatal("alu_monitor", "Failed to get m_cfg");
       end
     end
   end
 endfunction

 function void connect_phase(uvm_phase phase);
   bfm = m_cfg.mon_bfm;
   bfm.proxy = this;
 endfunction

 // run task
 task run_phase(uvm_phase phase);
   bfm.run();
 endtask // run_phase

  // Proxy Methods:
  function void write(alu_txn item);
    mon_ap.write(item);
  endfunction : write
  
endclass // alu_monitor

