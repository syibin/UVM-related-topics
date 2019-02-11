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

`ifndef ANALYSIS_GROUP_BASE
`define ANALYSIS_GROUP_BASE

virtual class analysis_group_base extends uvm_component;
`uvm_component_utils(analysis_group_base)

 uvm_analysis_export #(alu_txn) mon_axp;
 uvm_analysis_export #(alu_txn) stim_axp;

 function new( string name , uvm_component p);
  super.new( name , p );
 endfunction

 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);  
  // create  ports
  mon_axp  = new("mon_axp",  this);
  stim_axp = new("stim_axp", this);
 endfunction // build_phase

  virtual function bit passfail();
    `uvm_error("SCOREBOARD","Must override analysis_group_base::passfail")
    return 0;
  endfunction

  virtual function void summarize();
    `uvm_error("SCOREBOARD","Must override analysis_group_base::passfail")
  endfunction // summarize
  
endclass;
`endif
