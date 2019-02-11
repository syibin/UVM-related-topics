//------------------------------------------------------------
//   Copyright 2012-2018 Mentor Graphics Corporation
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
//
// Version 1.0 - First release: 29th June 2012
//
// package: c_stimulus_pkg
//
// Provided to allow c based test stimulus to be written that can
// make DUT register accesses via bus agents in the UVM testbench.
//
// The pre-requisite for using this package is that there is a UVM
// register model in place in the test bench.
//
// The c code must use the reg_api API layer which interacts with this package
//

package c_stimulus_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

uvm_reg_block register_model;

bit interrupt_in_progress = 0;

//
// function: set_c_stimulus_register_block
//
// Sets the register model handle to the UVM environment register
// model so that c based register accesses can use the register model
//
function void set_c_stimulus_register_block(uvm_reg_block rm);
  register_model = rm;
endfunction: set_c_stimulus_register_block


//
// function: get_register_from_address
//
// Uses the register model to make an lookup of the register
// associated with the address passed to the function.
//
// Returns a handle to the addressed register
//
function uvm_reg get_register_from_address(int address);
  uvm_reg_map reg_maps[$];
  uvm_reg found_reg;

  if(register_model == null) begin
    `uvm_error("c_reg_read", "Register model not mapped for the c_stimulus package")
  end

  register_model.get_maps(reg_maps);
  foreach(reg_maps[i]) begin
    found_reg = reg_maps[i].get_reg_by_offset(address);
    if(found_reg != null) begin
      break;
    end
  end

  return found_reg;

endfunction: get_register_from_address

//
// task: c_reg_read
//
// Reads data from register at address
//
// Blocked if an interrupt is in progress

task automatic c_reg_read(input int address, output int data);
  uvm_reg_data_t reg_data;
  uvm_status_e status;
  uvm_reg read_reg;

  read_reg = get_register_from_address(address);
  if(read_reg == null) begin
    `uvm_error("c_reg_read", $sformatf("Register not found at address: %0h", address))
    data = 0;
    return;
  end

  if(interrupt_in_progress == 1) begin
    wait(interrupt_in_progress == 0);
  end
  read_reg.read(status, reg_data);

  data = reg_data;

endtask: c_reg_read

//
// task: c_reg_write
//
// Writes data to register at address
//
// Blocked if an interrupt is in progress

task automatic c_reg_write(input int address, input int data);
  uvm_reg_data_t reg_data;
  uvm_status_e status;
  uvm_reg write_reg;

  write_reg = get_register_from_address(address);
  if(write_reg == null) begin
    `uvm_error("c_reg_write", $sformatf("Register not found at address: %0h", address))
    return;
  end

  reg_data = data;
  if(interrupt_in_progress == 1) begin
    wait(interrupt_in_progress == 0);
  end
  write_reg.write(status, reg_data);
endtask: c_reg_write

//
// task: wait_1n
//
// Wait for n * 1ns
//
task wait_1ns(int n = 1);
  repeat(n) begin
    #1ns;
  end
endtask: wait_1ns

// DPI Access
//
// DPI exports:
export "DPI-C" task c_reg_write;
export "DPI-C" task c_reg_read;
export "DPI-C" task wait_1ns;

// DPI imports:
// This task has to be called in the SystemVerilog to
// start the c side of things
import "DPI-C" context task start_c_code();

endpackage: c_stimulus_pkg
