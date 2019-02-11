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
class sfr_env extends uvm_component;

`uvm_component_utils(sfr_env)

function new(string name = "sfr_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

sfr_env_config cfg;
sfr_scoreboard sb;
sfr_agent agent;

extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: sfr_env

function void sfr_env::build_phase(uvm_phase phase);
  if(cfg == null) begin
    if(!uvm_config_db #(sfr_env_config)::get(this, "", "CFG", cfg)) begin
      `uvm_error("BUILD_PHASE", "Unable to find environment configuration object in the uvm_config_db")
    end
  end
  sb = sfr_scoreboard::type_id::create("sb", this);
  agent = sfr_agent::type_id::create("agent", this);
  agent.cfg = cfg.sfr_agent_cfg;
endfunction: build_phase

function void sfr_env::connect_phase(uvm_phase phase);
  agent.ap.connect(sb.analysis_export);
endfunction: connect_phase
