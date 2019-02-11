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

package biquad_reg_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class co_efficient_reg extends uvm_reg;

`uvm_object_utils(co_efficient_reg)

rand uvm_reg_field c;

function new(string name = "co_efficient_reg");
  super.new(name, 24, UVM_NO_COVERAGE);
endfunction

function void build();
  c = uvm_reg_field::type_id::create("c");
  c.configure(this, 24, 0, "RW", 0, 24'h0, 1, 1, 0);
endfunction: build

endclass: co_efficient_reg

class biquad_reg_block extends uvm_reg_block;

`uvm_object_utils(biquad_reg_block)

rand co_efficient_reg a11;
rand co_efficient_reg a12;
rand co_efficient_reg b10;
rand co_efficient_reg b11;
rand co_efficient_reg b12;

uvm_reg_map map;

function new(string name = "biquad_reg_block");
  super.new(name, UVM_NO_COVERAGE);
endfunction

function void build();
  a12 = co_efficient_reg::type_id::create("a12");
  a12.build();
  a12.configure(this);
  a11 = co_efficient_reg::type_id::create("a11");
  a11.build();
  a11.configure(this);
  b10 = co_efficient_reg::type_id::create("b10");
  b10.build();
  b10.configure(this);
  b11 = co_efficient_reg::type_id::create("b11");
  b11.build();
  b11.configure(this);
  b12 = co_efficient_reg::type_id::create("b12");
  b12.build();
  b12.configure(this);

  map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);
  map.add_reg(a11, 32'h0, "RW");
  map.add_reg(a12, 32'h4, "RW");
  map.add_reg(b10, 32'h8, "RW");
  map.add_reg(b11, 32'hc, "RW");
  map.add_reg(b12, 32'h10, "RW");

  lock_model();
endfunction: build

endclass: biquad_reg_block




endpackage: biquad_reg_pkg