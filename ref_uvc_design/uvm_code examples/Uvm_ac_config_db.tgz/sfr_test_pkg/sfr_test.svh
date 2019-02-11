//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
class sfr_test extends uvm_component;

`uvm_component_utils(sfr_test)

function new(string name = "sfr_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

sfr_env_config env_cfg;
sfr_config_object sfr_agent_cfg;

sfr_env env;

extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: sfr_test

function void sfr_test::build_phase(uvm_phase phase);
  env_cfg = sfr_env_config::type_id::create("env_cfg");
  sfr_agent_cfg = sfr_config_object:: type_id::create("sfr_agent_cfg");
  if(!uvm_config_db #(sfr_master_abstract)::get(this, "", "SFR_MASTER", sfr_agent_cfg.SFR_MASTER)) begin
    `uvm_error("BUILD_PHASE", "Unable to find virtual interface sfr_master_bfm in the uvm_config_db")
  end
  if(!uvm_config_db #(sfr_monitor_abstract)::get(this, "", "SFR_MONITOR", sfr_agent_cfg.SFR_MONITOR)) begin
    `uvm_error("BUILD_PHASE", "Unable to find virtual interface sfr_master_bfm in the uvm_config_db")
  end
  sfr_agent_cfg.is_active = 1;
  env_cfg.sfr_agent_cfg = sfr_agent_cfg;
  env = sfr_env::type_id::create("env", this);
  env.cfg = env_cfg;
endfunction: build_phase

task sfr_test::run_phase(uvm_phase phase);
  sfr_test_seq seq = sfr_test_seq::type_id::create("seq");

  phase.raise_objection(this);

  seq.start(env.agent.sequencer);

  phase.drop_objection(this);

endtask: run_phase
