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

class setup_coefficients extends uvm_sequence #(apb_seq_item);

`uvm_object_utils(setup_coefficients)

biquad_reg_block rm;

rand bit[23:0] a11;
rand bit[23:0] a12;
rand bit[23:0] b10;
rand bit[23:0] b11;
rand bit[23:0] b12;

uvm_status_e status;
uvm_reg_data_t data;

function new(string name = "setup_coefficients");
  super.new(name);
endfunction

task body;

  data = a11;
  rm.a11.write(status, data, .parent(this));
  data = a12;
  rm.a12.write(status, data, .parent(this));
  data = b10;
  rm.b10.write(status, data, .parent(this));
  data = b11;
  rm.b11.write(status, data, .parent(this));
  data = b12;
  rm.b12.write(status, data, .parent(this));

endtask: body

endclass: setup_coefficients