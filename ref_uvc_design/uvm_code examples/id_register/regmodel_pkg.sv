// ----------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
// Copyright 2004-2008 Synopsys, Inc.
// Copyright 2010 Cadence Design Systems, Inc.
// All Rights Reserved Worldwide
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ----------------------------------------------------------

package regmodel_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

//
// This example demonstrates how to model a register
// containing read-only fields and a register containing
// write-only fields at the same physical address.
//
// It also shows an ID Register working.
//

// The ID Register (field).
// Each successive 'read' operation returns the next item
// from a list. When the end of the list is reached, it wraps
// around to the beginning.
// This list is a0, a1, ...a9. (10 values)
class id_register_field extends uvm_reg_field;
  `uvm_object_utils(id_register_field)

  int id_register_pointer = 0;
  int id_register_pointer_max = 10;
  int id_register_value[] =
    '{'ha0, 'ha1, 'ha2, 'ha3, 'ha4,
      'ha5, 'ha6, 'ha7, 'ha8, 'ha9};

  int current_value;

  function new(string name = "id_register_field");
    super.new(name);
    current_value = id_register_value[0];
  endfunction

  task post_read(uvm_reg_item rw);
    if(value != current_value) begin
      `uvm_error("ID_REG_CHECK", $sformatf("Wrong ID value: id_ptr:%0d id_val:%0h read_vale:%0h", id_register_pointer, current_value, value))
    end
    id_register_pointer++;
    if (id_register_pointer >= id_register_pointer_max) begin
        id_register_pointer = 0;
    end
    current_value = id_register_value[id_register_pointer];
  endtask

  task post_write(uvm_reg_item rw);
    id_register_pointer = value;
    if (id_register_pointer >= id_register_pointer_max) begin
        id_register_pointer = 0;
    end
    current_value = id_register_value[id_register_pointer];
  endtask


endclass

// The ID Register.
// Just a register which has a special field - the
// ID Register field.
class id_register extends uvm_reg;
  id_register_field F1;

  `uvm_object_utils(id_register)

  function new(string name = "id_register");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
    F1 = id_register_field::type_id::create("F1",,
      get_full_name());
    F1.configure(this, 8, 0, "RW", 0, 8'ha0, 1, 0, 1);

  endfunction: build


endclass : id_register

class reg_RO extends uvm_reg;
  uvm_reg_field F1;
  uvm_reg_field F2;

  function new(string name = "RO");
     super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
     F1 = uvm_reg_field::type_id::create("F1");
     F2 = uvm_reg_field::type_id::create("F2");
     F1.configure(this, 8,  0, "RO", 0, 8'h00, 1, 0, 1);
     F2.configure(this, 8, 16, "RC", 0, 8'hFF, 1, 0, 1);
  endfunction: build

  `uvm_object_utils(reg_RO)
endclass : reg_RO

class reg_WO extends uvm_reg;
  rand uvm_reg_field F1;
  rand uvm_reg_field F2;

  function new(string name = "WO");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
    F1 = uvm_reg_field::type_id::create("F1");
    F2 = uvm_reg_field::type_id::create("F2");
    F1.configure(this,  8,  4, "WO", 0,   8'hAA, 1, 1, 1);
    F2.configure(this, 12, 12, "WO", 0, 12'hCCC, 1, 1, 1);
  endfunction: build

  `uvm_object_utils(reg_WO)
endclass : reg_WO


class block_B extends uvm_reg_block;
  rand reg_RO R;
  rand reg_WO W;
  id_register ID;

  function new(string name = "B");
    super.new(name, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();

    default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN);

    R = reg_RO::type_id::create("R");
    R.configure(this, null, "R_reg");
    R.build();

    W = reg_WO::type_id::create("W");
    W.configure(this, null, "W_reg");
    W.build();

    ID = id_register::type_id::create("ID");
    ID.configure(this, null, "ID_reg");
    ID.build();

    default_map.add_reg(ID, 'h000,  "RW");
    default_map.add_reg(R,  'h100,  "RO");
    default_map.add_reg(W,  'h100,  "WO");

    lock_model();
  endfunction : build
  `uvm_object_utils(block_B)
endclass : block_B
endpackage
