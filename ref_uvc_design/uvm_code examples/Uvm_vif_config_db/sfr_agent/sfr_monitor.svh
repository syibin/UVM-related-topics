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
class sfr_monitor extends uvm_component;

`uvm_component_utils(sfr_monitor)

function new(string name = "sfr_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

virtual sfr_if SFR;
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
    @(posedge SFR.clk);
    if((SFR.we == 1) || (SFR.re == 1)) begin
      item = sfr_seq_item::type_id::create("item");
      item.we = SFR.we;
      item.re = SFR.re;
      item.address = SFR.address;
      item.write_data = SFR.write_data;
      item.read_data = SFR.read_data;
      ap.write(item);
    end
  end

endtask: run_phase
