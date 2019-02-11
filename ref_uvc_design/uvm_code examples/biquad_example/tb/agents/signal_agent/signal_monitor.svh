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

class signal_monitor extends uvm_component;

`uvm_component_utils(signal_monitor)

uvm_analysis_port #(signal_seq_item) ap;

virtual signal_if SIGNAL;

extern function new(string name = "signal_monitor", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: signal_monitor

function signal_monitor::new(string name = "signal_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void signal_monitor::build_phase(uvm_phase phase);
  ap = new("ap", this);
endfunction: build_phase

task signal_monitor::run_phase(uvm_phase phase);
  signal_seq_item analysis_sample;

  forever begin
    @(SIGNAL.f);
    analysis_sample = signal_seq_item::type_id::create("analysis_sample");
    analysis_sample.freq = SIGNAL.f;
    ap.write(analysis_sample);
  end

endtask: run_phase