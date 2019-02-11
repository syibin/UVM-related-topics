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

class scoreboard_ooo_imps extends analysis_group_base;
`uvm_component_utils(scoreboard_ooo_imps)

 // analysis component handles
 comparator_ooo_imps #(alu_txn) comp;
 alu_tlm predictor;

 function new (string name = "scoreboard_ooo_imps", uvm_component parent = null);
  super.new( name , parent);
 endfunction

 function void build_phase(uvm_phase phase);
  super.build_phase(phase);  
  //generate analysis objects
  comp =  comparator_ooo_imps #(alu_txn)::type_id::create("comp", this);
  predictor = alu_tlm::type_id::create("predictor", this);
 endfunction
 
 function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  
  // connect up scoreboard analysis exports
  mon_axp.connect(comp.after_axp );
  predictor.results_ap.connect(comp.before_axp);
  
  // connect up predictor to stim
  stim_axp.connect(predictor.analysis_export);
      
 endfunction // connect_phase

  function bit passfail();
    if((comp.get_mismatches == 0) && (comp.get_total_missing == 0))
      return 1'b1;
    else
      return 0;
  endfunction // passfail

  function void summarize();
    `uvm_info("SCOREBOARD",$sformatf("\tMatches = %0d\
\n\t\tMismatches = %0d\n\t\tMissing = %0d",
				     comp.get_matches(),
				     comp.get_mismatches(),
				     comp.get_total_missing()),UVM_LOW)
  endfunction
endclass
