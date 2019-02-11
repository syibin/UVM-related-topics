//------------------------------------------------------------
//   Copyright 2007-2018 Mentor Graphics Corporation
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

  // CLASS: simple_item
  // Has data, address and operation (R/W).
  class simple_item extends uvm_sequence_item;

    // Variable: op
    // Controls whether a READ or a WRITE happens.
    rand bus_op_t op;

    // Variable: addr
    // 32 bits of address.
    rand int unsigned addr;

    // Variable: data
    // 32 bits of data.
    rand int unsigned data;
  
    // Variable: c1
    // Address is constrained by c1 to be less than 'h2000
    constraint c1 { addr < 16'h2000; }

    // Variable: c2
    // Data is constrained by c2 to be less than 'h100
    constraint c2 { data < 16'h100; }
  
    `uvm_object_utils(simple_item)
  
    function new (string name = "simple_item");
      super.new(name);
    endfunction : new
  
    function void do_copy(uvm_object rhs);
      simple_item item;
      super.do_copy(rhs);
      if (!$cast(item, rhs)) return;
      op = item.op;
      addr = item.addr;
      data = item.data;
    endfunction

    function string convert2string();
      return $psprintf("(%s) , ADDR=%4x, DATA=%8x", 
        op, addr, data);
    endfunction
  endclass : simple_item
