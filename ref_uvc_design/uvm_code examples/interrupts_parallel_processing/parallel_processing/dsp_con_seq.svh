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

// DSP Control Sequence
//
// Each DSP processor in the chain generates an interrupt
// when it has completed processing
//
// The sequence then starts the next accelerator
//
class dsp_con_seq extends uvm_sequence #(dsp_con_seq_item);

`uvm_object_utils(dsp_con_seq)

dsp_con_config cfg;
dsp_con_seq_item req;
int wait_cycles_done = 0;

function new(string name = "dsp_con_seq");
  super.new(name);
endfunction

// Wait for the interrupts to fire
// then start up the next DSP block
task body;

  if(!uvm_config_db #(dsp_con_config)::get(null, get_full_name(), "dsp_con_agent_config", cfg)) begin
    `uvm_error("body", "unable to get dsp_con_config")
  end

  req = dsp_con_seq_item::type_id::create("req");

  cfg.wait_for_reset;
  repeat(2) begin
    do_go(4'h1);       // Start Accelerator 0
    cfg.wait_for_irq0; // Accelerator 0 complete
    do_go(4'h2);       // Start Accelerator 1
    cfg.wait_for_irq1; // Accelerator 1 complete
    do_go(4'h4);       // Start Accelerator 2
    cfg.wait_for_irq2; // Accelerator 2 complete
    do_go(4'h8);       // Start Accelerator 3
    cfg.wait_for_irq3; // Accelerator 3 complete
  end
  cfg.wait_for_clock;

  wait_cycles_done = 1;
endtask: body

// Toggles the go or start bit
task do_go(bit[3:0] go);
  req.go = go;
  start_item(req);
  finish_item(req);
endtask

endclass:dsp_con_seq
