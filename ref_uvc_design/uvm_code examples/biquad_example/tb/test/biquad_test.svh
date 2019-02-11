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

class biquad_test extends uvm_component;

`uvm_component_utils(biquad_test)

biquad_env env;

biquad_env_config cfg;
apb_agent_config apb_cfg;
signal_agent_config signal_cfg;

biquad_reg_block rm;

extern function new(string name = "biquad_test", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

endclass: biquad_test

function biquad_test::new(string name = "biquad_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void biquad_test::build_phase(uvm_phase phase);
  cfg = biquad_env_config::type_id::create("cfg");
  rm = biquad_reg_block::type_id::create("rm");
  rm.build();
  cfg.rm = rm;
  apb_cfg = apb_agent_config::type_id::create("apb_cfg");
  if(!uvm_config_db #(virtual apb_if)::get(this, "", "APB", apb_cfg.APB)) begin
    `uvm_error("build_phase", "Unable to locate APB virtual interface in uvm_config_db")
  end
  apb_cfg.start_address[0] = 0;
  apb_cfg.range[0] = 32'h40;
  cfg.apb_cfg = apb_cfg;
  signal_cfg = signal_agent_config::type_id::create("signal_cfg");
  if(!uvm_config_db #(virtual signal_if)::get(this, "", "SIGNAL", signal_cfg.SIGNAL)) begin
    `uvm_error("build_phase", "Unable to locate SIGNAL virtual interface in uvm_config_db")
  end
  cfg.signal_cfg = signal_cfg;
  env = biquad_env::type_id::create("env", this);
  uvm_config_db #(biquad_env_config)::set(this, "env*", "biquad_env_config", cfg);
endfunction: build_phase

task biquad_test::run_phase(uvm_phase phase);
  biquad_vseq vseq = biquad_vseq::type_id::create("vseq");

  vseq.apb = env.apb.m_sequencer;
  vseq.signal = env.signal.m_sequencer;
  vseq.rm = rm;
  vseq.cfg = cfg;

  phase.raise_objection(this);
  vseq.start(null);
  phase.drop_objection(this);

endtask: run_phase

function void biquad_test::report_phase(uvm_phase phase);
  if((env.fcov_monitor.lp_cg.LP_FILTER_cg.get_coverage() == 100) &&
     (env.fcov_monitor.hp_cg.HP_FILTER_cg.get_coverage() == 100) &&
     (env.fcov_monitor.bp_cg.BP_FILTER_cg.get_coverage() == 100)) begin
     `uvm_info("*** UVM TEST PASSED ***", "Smoke test achieved expected coverage", UVM_LOW)
  end
  else begin
    `uvm_error("*** UVM TEST FAILED ***", "Smoke test failed to achieve expected coverage")
  end
endfunction: report_phase