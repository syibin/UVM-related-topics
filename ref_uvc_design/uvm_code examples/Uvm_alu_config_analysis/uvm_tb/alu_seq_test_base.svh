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

class alu_seq_test_base extends alu_test_base;
 `uvm_component_utils(alu_seq_test_base)
  // handle to sequencer in the testbench
  uvm_sequencer #(alu_txn) seqr_handle;
  
  alu_agent_config m_cfg;
  bit pf;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
    m_cfg = new();
  endfunction

  //Be sure to call super.build_phase(phase)
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg.alu_seqr_name = "alu_seqr";
    //Get the inferfaces for the agents and place in config object
    if (!uvm_config_db #(virtual alu_monitor_bfm)::get(this, "", "alu_mon_bfm", m_cfg.mon_bfm))
      `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface alu_mon_bfm from uvm_config_db. Have you set() it?")
    if (!uvm_config_db #(virtual alu_driver_bfm)::get(this, "", "alu_drv_bfm", m_cfg.drv_bfm))
      `uvm_fatal("VIF CONFIG", "Cannot get() BFM interface alu_drv_bfm from uvm_config_db. Have you set() it?")
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    seqr_handle = t_env.alu_if_agent.sequencer;
  endfunction

  function void extract_phase(uvm_phase phase);
    pf  = t_env.sb.passfail();
  endfunction // extract_phase

  function void report_phase(uvm_phase phase);
    t_env.sb.summarize();
    if(pf == 1'b1) begin
      `uvm_info("** UVM TEST PASSED **", "PASSED: Congratulations!",UVM_NONE)
    end else begin
      `uvm_error("!! UVM TEST FAILED !!", "FAILED: Bummer!")
    end
  endfunction

endclass

