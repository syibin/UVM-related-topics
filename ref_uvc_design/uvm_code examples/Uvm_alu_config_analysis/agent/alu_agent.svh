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
class alu_agent extends uvm_component;
`uvm_component_utils(alu_agent)   
 uvm_analysis_port #(alu_txn) stim_ap;
 uvm_analysis_port #(alu_txn) mon_ap;
 
 uvm_sequencer #(alu_txn) sequencer;
 alu_driver driver;
 alu_monitor monitor;
 alu_fc_monitor fcm;
 
 alu_agent_config cfg;
   
 function new( string name = "alu_agent" , uvm_component parent = null);
  super.new(name, parent);
 endfunction

 function void build_phase(uvm_phase phase); 
   // create agent ports
   stim_ap = new("stim_ap", this);
   mon_ap =  new("mon_ap",  this);
   sequencer = uvm_sequencer #(alu_txn)::type_id::create("sequencer", this);
   driver = alu_driver::type_id::create("driver", this);
   monitor = alu_monitor::type_id::create("monitor", this);
   fcm = alu_fc_monitor::type_id::create("fcm", this);
 endfunction

 function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // connect sequence controller and driver
  driver.seq_item_port.connect(sequencer.seq_item_export);
  
    // connect up analysis ports 
  driver.stim_ap.connect(stim_ap);
  monitor.mon_ap.connect(mon_ap);
  monitor.mon_ap.connect(fcm.analysis_export);

 endfunction

   
endclass
