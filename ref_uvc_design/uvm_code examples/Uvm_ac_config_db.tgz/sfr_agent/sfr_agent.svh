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
class sfr_agent extends uvm_component;

`uvm_component_utils(sfr_agent)

uvm_analysis_port #(sfr_seq_item) ap;

uvm_sequencer #(sfr_seq_item) sequencer;

sfr_driver driver;
sfr_monitor monitor;

sfr_config_object cfg;

function new(string name = "sfr_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass: sfr_agent

function void sfr_agent::build_phase(uvm_phase phase);
  if(cfg == null) begin
    if(!uvm_config_db #(sfr_config_object)::get(this, "", "SFR_CFG", cfg)) begin
      `uvm_error("BUILD_PHASE", "Unable to find sfr agent config object in the uvm_config_db")
    end
  end
  ap = new("ap", this);
  monitor = sfr_monitor::type_id::create("monitor", this);
  if(cfg.is_active == 1) begin
    driver = sfr_driver::type_id::create("driver", this);
    sequencer = uvm_sequencer #(sfr_seq_item)::type_id::create("sequencer", this);
  end
endfunction: build_phase

function void sfr_agent::connect_phase(uvm_phase phase);
  monitor.SFR = cfg.SFR_MONITOR;
  monitor.ap.connect(ap);
  if(cfg.is_active == 1) begin
    driver.SFR = cfg.SFR_MASTER;
    driver.seq_item_port.connect(sequencer.seq_item_export);
  end
endfunction: connect_phase
