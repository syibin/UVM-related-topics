//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

class dsp_con_test extends uvm_test;

`uvm_component_utils(dsp_con_test)

dsp_con_agent m_agent;
dsp_con_config m_cfg;

function new(string name = "dsp_con_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

// Get the virtual interfaces and build the agent
//
function void build_phase(uvm_phase phase);
  m_cfg = dsp_con_config::type_id::create("m_cfg");
  for (int ii = 0; ii < 4; ii++) begin
    virtual interrupt_if temp_int_if;
    interrupt_util int_util = interrupt_util::type_id::create($sformatf("int%0d_util", ii));
    if(!uvm_config_db #(virtual interrupt_if)::get(this, "", $sformatf("IRQ%0d_vif", ii), temp_int_if)) begin
      `uvm_error("build_phase", $sformatf("Interrupt virtual interface handle %0d not found", ii))
    end
    int_util.set_bfm(temp_int_if);
    m_cfg.INT[ii] = int_util;
  end
  if(!uvm_config_db #(virtual dsp_con_driver_bfm)::get(this, "", "dsp_con_drv_bfm", m_cfg.drv_bfm)) begin
    `uvm_error("build_phase", "Unable to get CONTROL_vif")
  end
  uvm_config_db #(dsp_con_config)::set(this, "*", "dsp_con_agent_config", m_cfg);
  m_agent = dsp_con_agent::type_id::create("m_agent", this);
endfunction: build_phase

task run_phase(uvm_phase phase);
  dsp_con_seq t_seq;

  phase.raise_objection(this, "Starting parallel processing test");
  t_seq = dsp_con_seq::type_id::create("t_seq");
  t_seq.start(m_agent.m_sequencer);
  if(t_seq.wait_cycles_done == 1) begin
    `uvm_info("** UVM TEST PASSED **", $sformatf("All wait for Interrupts done"), UVM_LOW)
  end
  else begin
    `uvm_error("** UVM TEST FAILED **", $sformatf(""))
  end  
  phase.drop_objection(this, "Finishing parallel processing test");
endtask: run_phase

endclass: dsp_con_test
