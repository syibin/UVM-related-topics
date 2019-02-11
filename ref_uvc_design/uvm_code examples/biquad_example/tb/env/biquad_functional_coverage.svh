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

class biquad_functional_coverage extends uvm_subscriber #(signal_seq_item);

`uvm_component_utils(biquad_functional_coverage)

// Filter mode is defined in the env configuration object
// together with the register model content:
biquad_env_config cfg;

// Cover groups - one for each type of filter:
LP_FILTER_cg_wrapper lp_cg;
HP_FILTER_cg_wrapper hp_cg;
BP_FILTER_cg_wrapper bp_cg;

extern function new(string name = "biquad_functional_coverage", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern function void write(T t);

endclass: biquad_functional_coverage

function biquad_functional_coverage::new(string name = "biquad_functional_coverage", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void biquad_functional_coverage::build_phase(uvm_phase phase);
  lp_cg = LP_FILTER_cg_wrapper::type_id::create("Low_Pass_cg");
  hp_cg = HP_FILTER_cg_wrapper::type_id::create("High_Pass_cg");
  bp_cg = BP_FILTER_cg_wrapper::type_id::create("Band_Pass_cg");
endfunction: build_phase

function void biquad_functional_coverage::write(T t);
  // Update the filter co-efficients and then sample
  // according to the filter mode:
  case(cfg.mode)
    LP: begin
          lp_cg.b10 = cfg.rm.b10.c.value[23:0];
          lp_cg.b11 = cfg.rm.b11.c.value[23:0];
          lp_cg.b12 = cfg.rm.b12.c.value[23:0];
          lp_cg.a10 = cfg.rm.a11.c.value[23:0];
          lp_cg.a11 = cfg.rm.a12.c.value[23:0];
          lp_cg.sample(t.freq);
        end
    HP: begin
          hp_cg.b10 = cfg.rm.b10.c.value[23:0];
          hp_cg.b11 = cfg.rm.b11.c.value[23:0];
          hp_cg.b12 = cfg.rm.b12.c.value[23:0];
          hp_cg.a10 = cfg.rm.a11.c.value[23:0];
          hp_cg.a11 = cfg.rm.a12.c.value[23:0];
          hp_cg.sample(t.freq);
        end
    BP: begin
          bp_cg.b10 = cfg.rm.b10.c.value[23:0];
          bp_cg.b11 = cfg.rm.b11.c.value[23:0];
          bp_cg.b12 = cfg.rm.b12.c.value[23:0];
          bp_cg.a10 = cfg.rm.a11.c.value[23:0];
          bp_cg.a11 = cfg.rm.a12.c.value[23:0];
          bp_cg.sample(t.freq);
        end
  endcase
endfunction: write
