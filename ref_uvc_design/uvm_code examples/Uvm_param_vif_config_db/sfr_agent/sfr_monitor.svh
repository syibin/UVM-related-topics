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
class sfr_monitor #(SFR_ADDR_WIDTH = 8, SFR_DATA_WIDTH = 8) extends uvm_component;

typedef sfr_monitor #(SFR_ADDR_WIDTH, SFR_DATA_WIDTH) this_t;

`uvm_component_param_utils(this_t)

function new(string name = "sfr_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

virtual sfr_monitor_bfm #(SFR_ADDR_WIDTH, SFR_DATA_WIDTH) SFR;
uvm_analysis_port #(sfr_seq_item) ap;

extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: sfr_monitor

function void sfr_monitor::build_phase(uvm_phase phase);
  ap = new("ap", this);
endfunction: build_phase

task sfr_monitor::run_phase(uvm_phase phase);
  sfr_seq_item item;

  forever begin
    item = sfr_seq_item::type_id::create("item");
    SFR.monitor(item);
    ap.write(item);
  end

endtask: run_phase
