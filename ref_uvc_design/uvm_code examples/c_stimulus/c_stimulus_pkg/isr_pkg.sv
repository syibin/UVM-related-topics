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
//
// package: isr_package
//
// Auxillary package to support Interrupt Routines for
// c code interacting with a UVM testbench using the
// c_stimulus_pkg.
//
// When an HW interrupt occurs, the c_stimulus_pkg register
// calls are blocked from making further register accesses
// until the ISR has completed.
//
package isr_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// Needed to access functions:
import c_stimulus_pkg::*;

//
// task: interrupt_service_routine
//
// Raises the interrupt_in_progress flag to block register
// accesses via the c_stimulus_pkg, then calls the c-side
// interrupt service routine via start_isr()
//
// At the end, it drops the interrupt_in_progress flag to
// unblock the c_stimulus_pkg register accesses

task interrupt_service_routine;

  interrupt_in_progress = 1;

  start_isr();

  interrupt_in_progress = 0;

endtask: interrupt_service_routine

//
// task: c_reg_read
//
// Task with same signature as the c_stimulus_pkg, but called
// from the isr using the isr_pkg context.
//
// Reads data from address, cannot be blocked
//
task automatic c_reg_read(input int address, output int data);
  uvm_reg_data_t reg_data;
  uvm_status_e status;
  uvm_reg read_reg;

  read_reg = get_register_from_address(address);
  if(read_reg == null) begin
    `uvm_error("ISR::c_reg_read", $sformatf("Register not found at address: %0h", address))
    data = 0;
    return;
  end

  read_reg.read(status, reg_data);

  data = reg_data;

endtask: c_reg_read

//
// task: c_reg_read
//
// Task with same signature as the c_stimulus_pkg, but called
// from the isr using the isr_pkg context.
//
// Writes data to address, cannot be blocked
//
task automatic c_reg_write(input int address, input int data);
  uvm_reg_data_t reg_data;
  uvm_status_e status;
  uvm_reg write_reg;

  write_reg = get_register_from_address(address);
  if(write_reg == null) begin
    `uvm_error("ISR::c_reg_write", $sformatf("Register not found at address: %0h", address))
    return;
  end

  write_reg.write(status, reg_data);
endtask: c_reg_write

// DPI Access
//
// DPI exports:
export "DPI-C" task c_reg_write;
export "DPI-C" task c_reg_read;

// DPI imports:
// This task has to be called in the SystemVerilog to
// start the c side of things
import "DPI-C" context task start_isr();

endpackage: isr_pkg
