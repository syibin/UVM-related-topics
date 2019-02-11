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


class alu_env extends uvm_env;
 `uvm_component_utils(alu_env)

 alu_agent alu_if_agent;  // alu agent
 scoreboard_ooo_imps sb;  // analysis group

 UVM_FILE log_file_id;

 function new( string name = "alu_env", uvm_component parent = null);
  super.new(name, parent);
 endfunction

 function void end_of_elaboration_phase(uvm_phase phase);
  log_file_id = $fopen("log_file.log");
  set_report_default_file_hier(log_file_id);
  set_report_severity_action_hier(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
  set_report_severity_action_hier(UVM_INFO, UVM_DISPLAY | UVM_LOG);
  set_report_severity_action_hier(UVM_ERROR, UVM_DISPLAY | UVM_COUNT | UVM_LOG);
  set_report_severity_action_hier(UVM_FATAL, UVM_DISPLAY | UVM_LOG | UVM_EXIT);
 endfunction
 
 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  alu_if_agent = alu_agent::type_id::create("alu_if_agent", this);
  sb = scoreboard_ooo_imps::type_id::create("sb", this);
 endfunction

 function void connect_phase(uvm_phase phase);  
  // connect alu agent to analysis group
  alu_if_agent.stim_ap.connect(sb.stim_axp);
  alu_if_agent.mon_ap.connect(sb.mon_axp);
  
 endfunction

 virtual function void report_phase(uvm_phase phase);     // report
  `uvm_info("alu_env" , "Finished Test \n", UVM_LOW)
 endfunction

endclass
