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

class biquad_env extends uvm_component;

`uvm_component_utils(biquad_env)

apb_agent apb;
signal_agent signal;
biquad_functional_coverage fcov_monitor;

reg2apb_adapter reg_adapter;
uvm_reg_predictor #(apb_seq_item) reg_predictor;


biquad_env_config cfg;

extern function new(string name = "biquad_env", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);


endclass: biquad_env

function biquad_env::new(string name = "biquad_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void biquad_env::build_phase(uvm_phase phase);
  if(!uvm_config_db #(biquad_env_config)::get(this, "", "biquad_env_config", cfg)) begin
    `uvm_error("build_phase", "Unable to find biquad_env_config in uvm_config_db")
  end
  apb = apb_agent::type_id::create("apb", this);
  uvm_config_db #(apb_agent_config)::set(this, "apb*", "apb_agent_config", cfg.apb_cfg);
  signal = signal_agent::type_id::create("signal", this);
  uvm_config_db #(signal_agent_config)::set(this, "signal*", "signal_agent_config", cfg.signal_cfg);
  reg_adapter = reg2apb_adapter::type_id::create("reg_adapter");
  reg_predictor = uvm_reg_predictor #(apb_seq_item)::type_id::create("reg_predictor", this);
  fcov_monitor = biquad_functional_coverage::type_id::create("fcov_monitor", this);
endfunction: build_phase

function void biquad_env::connect_phase(uvm_phase phase);
  cfg.rm.map.set_sequencer(apb.m_sequencer, reg_adapter);
  reg_predictor.map = cfg.rm.map;
  reg_predictor.adapter = reg_adapter;
  apb.ap.connect(reg_predictor.bus_in);
  signal.ap.connect(fcov_monitor.analysis_export);
  fcov_monitor.cfg = cfg;
endfunction: connect_phase

