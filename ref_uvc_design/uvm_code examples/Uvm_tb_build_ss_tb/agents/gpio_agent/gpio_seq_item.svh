//------------------------------------------------------------
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
//------------------------------------------------------------
// Questa recording macro:

`define uvm_record_field(NAME,VALUE) \
   $add_attribute(recorder.get_handle(),VALUE,NAME);

//
// Class Description:
//
//
class gpio_seq_item extends uvm_sequence_item;

// UVM Factory Registration Macro
//
`uvm_object_utils(gpio_seq_item)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
rand logic[31:0] gpio;
rand bit[31:0] use_ext_clk;
rand bit[31:0] ext_clk_edge;

bit ext_clk; // State of external clock

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "gpio_seq_item");
extern function void do_copy(uvm_object rhs);
extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
extern function string convert2string();
extern function void do_print(uvm_printer printer);
extern function void do_record(uvm_recorder recorder);

endclass:gpio_seq_item

function gpio_seq_item::new(string name = "gpio_seq_item");
  super.new(name);
endfunction

function void gpio_seq_item::do_copy(uvm_object rhs);
  gpio_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  gpio = rhs_.gpio;
  use_ext_clk = rhs_.use_ext_clk;
  ext_clk_edge = rhs_.ext_clk_edge;
  ext_clk = rhs_.ext_clk;

endfunction:do_copy

function bit gpio_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  gpio_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_copy", "cast of rhs object failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
    gpio == rhs_.gpio &&
    use_ext_clk == rhs_.use_ext_clk &&
    ext_clk_edge == rhs_.ext_clk_edge &&
    ext_clk == ext_clk;

endfunction:do_compare

function string gpio_seq_item::convert2string();
  string s;

  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, "%s GPIO\t%0h\n use_ext_clk\t%0h\n ext_clk_edge\t%0h\n ext_clk\t%0b", s, gpio, use_ext_clk, ext_clk_edge, ext_clk);
  return s;

endfunction:convert2string

function void gpio_seq_item::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction:do_print

function void gpio_seq_item::do_record(uvm_recorder recorder);
  super.do_record(recorder);

  // Use the record macros to record the item fields:
  `uvm_record_field("GPIO", gpio)
  `uvm_record_field("use_ext_clk", use_ext_clk)
  `uvm_record_field("ext_clk_edge", ext_clk_edge)
  `uvm_record_field("ext_clk", ext_clk)

endfunction:do_record
