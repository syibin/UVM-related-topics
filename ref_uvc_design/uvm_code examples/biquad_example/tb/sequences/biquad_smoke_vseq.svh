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

class biquad_smoke_vseq extends biquad_vseq;

`uvm_object_utils(biquad_smoke_vseq)

function new(string name = "biquad_smoke_vseq");
  super.new(name);
endfunction

task body;
  c_setup.rm = rm;
  setup_coefficients();

  cfg.mode = LP;
  c_setup.a11 = c_a11[24];
  c_setup.a12 = c_a12[24];
  c_setup.b10 = c_b10[24];
  c_setup.b11 = c_b11[24];
  c_setup.b12 = c_b12[24];
  c_setup.start(apb);
  `uvm_info("biquad_smoke_test::body", "Starting frequency sweep for Low Pass filter configuration", UVM_LOW)
  f_sweep.start(signal);

  cfg.mode = HP;
  c_setup.a11 = c_a11[48];
  c_setup.a12 = c_a12[48];
  c_setup.b10 = c_b10[48];
  c_setup.b11 = c_b11[48];
  c_setup.b12 = c_b12[48];
  c_setup.start(apb);
  `uvm_info("biquad_smoke_test::body", "Starting frequency sweep for High Pass filter configuration", UVM_LOW)
  f_sweep.start(signal);

  cfg.mode = BP;
  c_setup.a11 = c_a11[96];
  c_setup.a12 = c_a12[96];
  c_setup.b10 = c_b10[96];
  c_setup.b11 = c_b11[96];
  c_setup.b12 = c_b12[96];
  c_setup.start(apb);
  `uvm_info("biquad_smoke_test::body", "Starting frequency sweep for Band Pass filter configuration", UVM_LOW)
  f_sweep.start(signal);

endtask: body

endclass: biquad_smoke_vseq
