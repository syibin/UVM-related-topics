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

//-----------------------------------------------
// Parallel add, sub, mul, div 
class test_all_parallel extends alu_seq_test_base;
`uvm_component_utils(test_all_parallel)

 main_seq m_seq;  // the main sequence

 function new(string name, uvm_component parent);
  super.new(name,parent);
 endfunction

 function void build_phase(uvm_phase phase);
  //Configuration
   m_cfg.lock_num  = 5;
   uvm_config_db #(alu_agent_config)::set(this, "t_env.*", s_alu_config_id, m_cfg);
  // factory overrides
//  alu_seq::type_id::set_type_override(alu_seq_pipe::type_id::get());
//  factory.print(1);     

  // create main sequence
  m_seq =  main_seq::type_id::create("m_seq"); 

  super.build_phase(phase);
 endfunction

 task run_phase(uvm_phase phase);
   phase.raise_objection(this, "Starting Main Sequence");
  // start up the main sequence
   m_seq.start( seqr_handle , null);
   phase.drop_objection(this, "Main Sequence Done");
 endtask

endclass

