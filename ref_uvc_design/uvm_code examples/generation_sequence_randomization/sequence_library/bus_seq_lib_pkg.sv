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

// The following sequences are declared in this library package file:
//
// bus_seq_base - base class from which all others are extended,
//                used to illustrate polymorphism
//
// mem_trans_seq - Illustrates the use of rand fields in sequences
//
// rpt_mem_trans_seq - Illustrates how to use fields in sequence objects which
//                     contain persistant information
//
// fill_memory_seq - Fills up the DUT memory
//
// n_m_rw_seq - Writes to n locations, reads and checks m locations where n < m
//
// rwr_seq - Reads from one location, writes to another
//
// n_m_rw__interleaved_seq - Extended version of n_m_rw_seq that interleaves reads & writes
//
// rand_order_seq - Executes a set of sub-sequences in an random order
//

package bus_seq_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import bus_agent_pkg::*;

class bus_seq_base extends uvm_sequence #(bus_seq_item);

`uvm_object_utils(bus_seq_base)

function new(string name = "bus_seq_base");
  super.new(name);
endfunction

endclass: bus_seq_base

//
// This sequence shows how data members can be set to rand values
// to allow the sequence to either be randomized or set to a directed
// set of values in the controlling thread
//
// The sequence reads one block of memory (src_addr) into a buffer and then
// writes the buffer into another block of memory (dst_addr). The size
// of the buffer is determined by the transfer size
//
class mem_trans_seq extends bus_seq_base;

`uvm_object_utils(mem_trans_seq)

// Randomised variables
rand logic[31:0] src_addr;
rand logic[31:0] dst_addr;
rand int transfer_size;

// Internal buffer
logic[31:0] buffer[];

// Legal limit on the page size is 1023 transfers
//
// No point in doing a transfer of 0 transfers
//
constraint page_size {
  transfer_size inside {[1:1024]};
}

// Addresses need to be aligned to 32 bit transfers
constraint address_alignment {
  src_addr[1:0] == 0;
  dst_addr[1:0] == 0;
}

function new(string name = "mem_trans_seq");
  super.new(name);
endfunction

task body;
  bus_seq_item req = bus_seq_item::type_id::create("req");
  logic[31:0] dst_start_addr = dst_addr;

  buffer = new[transfer_size];

  `uvm_info("run:", $sformatf("Transfer block of %0d words from %0h-%0h to %0h-%0h",
      transfer_size, src_addr, src_addr+((transfer_size-1)*4),
      dst_addr, dst_addr+((transfer_size-1)*4)), UVM_LOW)

  // Fill the buffer
  for(int i = 0; i < transfer_size-1; i++) begin
    start_item(req);
    if(!req.randomize() with {addr == src_addr; read_not_write == 1; delay < 3;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    buffer[i] = req.read_data;
    src_addr = src_addr + 4; // Increment to the next location
  end
  // Empty the buffer
  for(int i = 0; i < transfer_size-1; i++) begin
    start_item(req);
    if(!req.randomize() with {addr == dst_addr; read_not_write == 0; write_data == buffer[i];delay < 3;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    dst_addr = dst_addr + 4; // Increment to the next location
  end
  dst_addr = dst_start_addr;
  // Check the buffer transfer
  for(int i = 0; i < transfer_size-1; i++) begin
    start_item(req);
    if(!req.randomize() with {addr == dst_addr; read_not_write == 1; write_data == buffer[i];delay < 3;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    if(buffer[i] != req.read_data) begin
      `uvm_error("run:", $sformatf("Error in transfer @%0h : Expected %0h, Actual %0h", dst_addr, buffer[i], req.read_data))
    end
    dst_addr = dst_addr + 4; // Increment to the next location
  end
  `uvm_info("run:", $sformatf("Finished transfer end addresses SRC: %0h DST:%0h",
                              src_addr, dst_addr), UVM_LOW)

endtask: body

endclass: mem_trans_seq

//
// This class shows how to reuse the values persistent within a sequence
// It runs the mem_trans_seq once with randomized values and then repeats it
// several times without further randomization until the memory limit is
// reached. This shows how the end address values are reused on each repeat.
//
class rpt_mem_trans_seq extends bus_seq_base;

`uvm_object_utils(rpt_mem_trans_seq)

function new(string name = "rpt_mem_trans_seq");
  super.new(name);
endfunction

task body;
  mem_trans_seq trans_seq = mem_trans_seq::type_id::create("trans_seq");

  // First transfer:
  if(!trans_seq.randomize() with {src_addr inside {[32'h0100_0000:32'h0100_FFFF]};
                                     dst_addr inside {[32'h0103_0000:(32'h0104_0000 - (transfer_size*4))]};
                                     transfer_size < 512;
                                     solve transfer_size before dst_addr;}) begin
    `uvm_error("body", "randomization failed for req")
  end
  trans_seq.start(m_sequencer);
  // Continue with next block whilst we can complete within range
  // Each block transfer continues from where the last one left off
  while ((trans_seq.dst_addr + (trans_seq.transfer_size*4)) < 32'h0104_0000) begin
    trans_seq.start(m_sequencer);
  end

endtask: body

endclass: rpt_mem_trans_seq

// This sequence fills up a block of memory in the DUT with random data
class fill_memory_seq extends bus_seq_base;

`uvm_object_utils(fill_memory_seq)

rand logic[31:0] start_addr;
rand int block_size;

constraint block_sys_limit {
  block_size inside {16, 32, 64, 128, 512, 1024};
}

constraint within_range {
  start_addr < (32'h0104_0000 - block_size*4);
  start_addr > 32'h0100_0000;
  solve block_size before start_addr;
  start_addr[1:0] == 0;
}

function new(string name = "fill_memory_seq");
  super.new(name);
endfunction

task body;
  bus_seq_item req = bus_seq_item::type_id::create("req");
  int next_addr;

  next_addr = start_addr;
  `uvm_info("Body", $sformatf("Starting memory fill from %0h - %0h", start_addr, (start_addr+(block_size-1)*4)), UVM_LOW)
  repeat(block_size) begin
    if(!req.randomize() with {read_not_write == 0; addr == next_addr; delay == 1;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    start_item(req);
    finish_item(req);
    next_addr = req.addr + 4;
  end

endtask: body

endclass: fill_memory_seq

// Reads from n memory locations, writes to m memory locations and checks the value read back
// n > m
class n_m_rw_seq extends bus_seq_base;

`uvm_object_utils(n_m_rw_seq)

rand int n;
rand int m;
rand logic[31:0] read_addr;
rand logic[31:0] write_addr;

constraint transfer_rules {
  n > m; // More reads than writes
  m > 1; // At least one write
  n inside {16, 32, 64, 128};
  read_addr > 32'h0100_0000;
  read_addr < (32'h0102_0000 - n*4); // Within limits
  write_addr < (32'h0104_0000 - m*4);
  write_addr > 32'h0102_0000;
  solve n before read_addr;
  solve m before write_addr;
  // Addresses must be aligned for 32 bit transfer
  write_addr[1:0] == 0;
  read_addr[1:0] == 0;
}

function new(string name = "n_m_rw_seq");
  super.new(name);
endfunction

task body;
  bus_seq_item req = bus_seq_item::type_id::create("req");
  logic[31:0] buffer[127:0];

  `uvm_info("Starting", "n_m_rw_seq", UVM_LOW)
  // Reads from n locations
  for(int i = 0; i < n; i++) begin
    start_item(req);
    if(!req.randomize() with {read_not_write == 1; addr == read_addr; delay == 1;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    buffer[i] = req.read_data;
    read_addr = read_addr + 4;
  end
  // Writes to m locations
  for(int i = 0; i < m; i++) begin
    start_item(req);
    if(!req.randomize() with {read_not_write == 0; addr == write_addr; delay == 1; write_data == buffer[i];}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    write_addr = write_addr + 4;
  end
  write_addr = write_addr - (m * 4);
  // Checks m locations
  for(int i = 0; i < m; i++) begin
    start_item(req);
    if(!req.randomize() with {read_not_write == 1; addr == write_addr; delay == 1;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    if(buffer[i] != req.read_data) begin
      `uvm_error("CHECK FAILED", $sformatf("@%0h Expected data:%0h Actual data: %0h", write_addr, buffer[i], req.read_data))
    end
    write_addr = write_addr + 4;
  end
endtask: body

endclass: n_m_rw_seq

// Reads from a memory location, writes to another memory location and checks the value read back
class rwr_seq extends bus_seq_base;

`uvm_object_utils(rwr_seq)

function new(string name = "rwr_seq");
  super.new(name);
endfunction

task body;
  bus_seq_item req = bus_seq_item::type_id::create("req");
  logic[31:0] buffer;

  `uvm_info("Starting", "rwr_seq", UVM_LOW)
  // Read from a random location
  start_item(req);
  if(!req.randomize() with {read_not_write == 1; addr inside {[32'h0100_0000:32'h0104_0000]};}) begin
    `uvm_error("body", "randomization failed for req")
  end
  finish_item(req);
  buffer = req.read_data;
  // Write to a random location
  start_item(req);
  if(!req.randomize() with {read_not_write == 0; write_data == buffer; addr inside {[32'h0100_0000:32'h0104_0000]};}) begin
    `uvm_error("body", "randomization failed for req")
  end
  finish_item(req);
  // Check that write worked
  start_item(req);
  req.read_not_write = 1;
  finish_item(req);
  if(req.read_data != buffer) begin
    `uvm_error("CHECK FAILED", $sformatf("@%0h Expected data:%0h Actual data: %0h", req.addr, buffer, req.read_data))
  end

endtask: body

endclass: rwr_seq

// Variant of n_m_rw sequence that interleaves the reads and writes
//
// Only re-using the constraints
//
class n_m_rw__interleaved_seq extends n_m_rw_seq;

`uvm_object_utils(n_m_rw__interleaved_seq)

function new(string name = "n_m_rw__interleaved_seq");
  super.new(name);
endfunction

//
task body;
  bus_seq_item req = bus_seq_item::type_id::create("req");
  logic[31:0] buffer;

  `uvm_info("Starting", "n_m_rw__interleaved_seq", UVM_LOW)
  for(int i = 0; i < m; i++) begin
    // Read from a location
    start_item(req);
    if(!req.randomize() with { read_not_write == 1; addr == read_addr; delay == 1;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    // Store result
    buffer = req.read_data;
    // Write result to another location
    start_item(req);
    if(!req.randomize() with { read_not_write == 0; addr == write_addr; write_data == buffer; delay == 1;}) begin
      `uvm_error("body", "randomization failed for req")
    end
    finish_item(req);
    // Check that the right result is read back
    start_item(req);
    req.read_not_write = 1;
    finish_item(req);
    if(req.read_data != buffer) begin
      `uvm_error("CHECK FAILED", $sformatf("@%0h Expected data:%0h Actual data: %0h", write_addr, buffer, req.read_data))
    end
    write_addr = write_addr+4;
    read_addr = read_addr+4;
  end
endtask: body

endclass: n_m_rw__interleaved_seq

//
// This sequence executes some sub-sequences in a random order
//
class rand_order_seq extends bus_seq_base;

`uvm_object_utils(rand_order_seq)

function new(string name = "");
  super.new(name);
endfunction

//
// The sub-sequences are created and put into an array of
// the common base type.
//
// Then the array order is shuffled before each sequence is
// randomized and then executed
//
task body;
  bus_seq_base seq_array[4];

  seq_array[0] = n_m_rw__interleaved_seq::type_id::create("seq_0");
  seq_array[1] = rwr_seq::type_id::create("seq_1");
  seq_array[2] = n_m_rw_seq::type_id::create("seq_2");
  seq_array[3] = fill_memory_seq::type_id::create("seq_3");

  // Shuffle the array contents into a random order:
  seq_array.shuffle();
  // Execute all the array items in turn
  foreach(seq_array[i]) begin
    if(!seq_array[i].randomize()) begin
      `uvm_error("body", "randomization failed for req")
    end
    seq_array[i].start(m_sequencer);
  end

endtask: body

endclass: rand_order_seq

endpackage: bus_seq_lib_pkg
