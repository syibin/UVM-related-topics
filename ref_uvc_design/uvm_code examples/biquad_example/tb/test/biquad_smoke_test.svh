//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
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

class biquad_smoke_test extends biquad_test;

`uvm_component_utils(biquad_smoke_test)

extern function new(string name = "biquad_smoke_test", uvm_component parent = null);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

endclass: biquad_smoke_test

function biquad_smoke_test::new(string name = "biquad_smoke_test", uvm_component parent = null);
  super.new(name, parent);
endfunction


task biquad_smoke_test::run_phase(uvm_phase phase);
  biquad_smoke_vseq vseq = biquad_smoke_vseq::type_id::create("vseq");

  vseq.apb = env.apb.m_sequencer;
  vseq.signal = env.signal.m_sequencer;
  vseq.rm = rm;
  vseq.cfg = cfg;

  phase.raise_objection(this);
  vseq.start(null);
  phase.drop_objection(this);

endtask: run_phase

function void biquad_smoke_test::report_phase(uvm_phase phase);
  if((env.fcov_monitor.lp_cg.LP_FILTER_cg.get_coverage() > 35) &&
     (env.fcov_monitor.hp_cg.HP_FILTER_cg.get_coverage() > 35) &&
     (env.fcov_monitor.bp_cg.BP_FILTER_cg.get_coverage() > 35)) begin
     `uvm_info("*** UVM TEST PASSED ***", "Smoke test achieved expected coverage", UVM_LOW)
  end
  else begin
    `uvm_error("*** UVM TEST FAILED ***", "Smoke test failed to achieve expected coverage")
  end

endfunction: report_phase
