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
//
// This package contains the sequences targetting the bus
// interface of the SPI block - Not all are used by the test cases
//
// It uses the UVM register model
//
package spi_bus_sequence_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import spi_env_pkg::*;
import spi_reg_pkg::*;

// Base class that used by all the other sequences in the
// package:
//
// Gets the handle to the register model - spi_rm
//
// Contains the data and status fields used by most register
// access methods
//
class spi_bus_base_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(spi_bus_base_seq)

  // SPI Register block
  spi_reg_block spi_rb;

  // SPI env configuration object (containing a register model handle)
  spi_env_config m_cfg;

  // Properties used by the various register access methods:
  rand uvm_reg_data_t data;  // For passing data
  uvm_status_e status;       // Returning access status

  function new(string name = "spi_bus_base_seq");
    super.new(name);
  endfunction

  // Common functionality:
  // Getting a handle to the register model
  task body;
    if(m_cfg == null) begin
      `uvm_fatal(get_full_name(), "spi_env_config is null")
    end
    spi_rb = m_cfg.spi_rb;
  endtask: body

endclass: spi_bus_base_seq

//
// Data load sequence:
//
// load all rxtx locations with
// random data in a random order
//
class data_load_seq extends spi_bus_base_seq;

  `uvm_object_utils(data_load_seq)

  function new(string name = "data_load_seq");
    super.new(name);
  endfunction

  uvm_reg data_regs[]; // Array of registers


  task body;
    super.body;
    // Set up the data register handle array
    data_regs = '{spi_rb.rxtx0, spi_rb.rxtx1, spi_rb.rxtx2, spi_rb.rxtx3};
    // Randomize order
    data_regs.shuffle();
    foreach(data_regs[i]) begin
      // Randomize register content and then update
      if(!data_regs[i].randomize()) begin
        `uvm_error("body", $sformatf("Randomization error for data_regs[%0d]", i))
      end
      data_regs[i].update(status, .path(UVM_FRONTDOOR), .parent(this));
    end

  endtask: body

endclass: data_load_seq

//
// Data unload sequence - reads back the data rx registers
// all of them in a random order
//
class data_unload_seq extends spi_bus_base_seq;

  `uvm_object_utils(data_unload_seq)

  uvm_reg data_regs[];

  function new(string name = "data_unload_seq");
    super.new(name);
  endfunction

  task body;
    super.body;
    // Set up the data register handle array
    data_regs = '{spi_rb.rxtx0, spi_rb.rxtx1, spi_rb.rxtx2, spi_rb.rxtx3};
    // Randomize access order
    data_regs.shuffle();
    // Use mirror in order to check that the value read back is as expected
    foreach(data_regs[i]) begin
      data_regs[i].mirror(status, UVM_CHECK, .parent(this));
    end
  endtask: body

endclass: data_unload_seq

//
// Div load sequence - loads one of the target
//                     divisor values
//
class div_load_seq extends spi_bus_base_seq;

  `uvm_object_utils(div_load_seq)

  function new(string name = "div_load_seq");
    super.new(name);
  endfunction

  // Interesting divisor values:
  constraint div_values {data[15:0] inside {16'h0, 16'h1, 16'h2, 16'h4, 16'h8, 16'h10, 16'h20, 16'h40, 16'h80};}

  task body;
    super.body;
    // Randomize the local data value
    if(!this.randomize()) begin
      `uvm_error("body", "Randomization error for this")
    end
    // Write to the divider register
    spi_rb.divider.write(status, data, .parent(this));
  endtask: body

endclass: div_load_seq

//
// Ctrl set sequence - loads one control params
//                     but does not set the go bit
//
class ctrl_set_seq extends spi_bus_base_seq;

  `uvm_object_utils(ctrl_set_seq)

  function new(string name = "ctrl_set_seq");
    super.new(name);
  endfunction

  // Controls whether interrupts are enabled or not
  bit int_enable = 0;

  task body;
    super.body;
    // Constrain to interesting data length values
//    if(!spi_rb.ctrl.randomize() with {char_len.value inside {0, 1, [31:33], [63:65], [95:97], 126, 127};}) begin
    if(!spi_rb.ctrl.randomize() with {char_len.value inside {[1:31]};}) begin
      `uvm_error("body", "Control register randomization failed")
    end
    // Set up interrupt enable
    spi_rb.ctrl.ie.set(int_enable);
    // Don't set the go_bsy bit
    spi_rb.ctrl.go_bsy.set(0);
    // Write the new value to the control register
    spi_rb.ctrl.update(status, .path(UVM_FRONTDOOR), .parent(this));
    // Get a copy of the register value for the SPI agent
    data = spi_rb.ctrl.get();
  endtask: body

endclass: ctrl_set_seq

//
// Ctrl go sequence - sets the transfer in motion
//                    uses previously set control value
//
class ctrl_go_seq extends spi_bus_base_seq;

  `uvm_object_utils(ctrl_go_seq)

  function new(string name = "ctrl_go_seq");
    super.new(name);
  endfunction

  task body;
    super.body;
    // Set the go_bsy bit and go!
    spi_rb.ctrl.go_bsy.set(1);
    spi_rb.ctrl.update(status, .path(UVM_FRONTDOOR), .parent(this));
  endtask: body

endclass: ctrl_go_seq

// Slave Select setup sequence
//
// Random values set for slave select
//
class slave_select_seq extends spi_bus_base_seq;

  `uvm_object_utils(slave_select_seq)

  function new(string name = "slave_select_seq");
    super.new(name);
  endfunction

  task body;
    super.body;
    if(!spi_rb.ss.randomize() with {cs.value != 8'h0;}) begin
      `uvm_error("body", "Randomization failure for ss")
    end
    spi_rb.update(status, .path(UVM_FRONTDOOR), .parent(this));
  endtask: body

endclass: slave_select_seq

// Slave Unselect setup sequence
//
// Writes 0 to the slave select register
//
class slave_unselect_seq extends spi_bus_base_seq;

  `uvm_object_utils(slave_unselect_seq)

  function new(string name = "slave_unselect_seq");
    super.new(name);
  endfunction

  task body;
    super.body;
    spi_rb.ss.write(status, 32'h0, .parent(this));
  endtask: body

endclass: slave_unselect_seq

//
// Transfer complete by polling sequence
//
// Does successive reads from the control register
// to determine when the transfer has completed
//
class tfer_over_by_poll_seq extends spi_bus_base_seq;

  `uvm_object_utils(tfer_over_by_poll_seq)

  function new(string name = "tfer_over_by_poll_seq");
    super.new(name);
  endfunction

  task body;
    data_unload_seq empty_buffer;
    slave_unselect_seq ss_deselect;

    super.body;

    // Poll the GO_BSY bit in the control register
    while(spi_rb.ctrl.go_bsy.value[0] == 1) begin
      spi_rb.ctrl.read(status, data, .parent(this));
    end
    ss_deselect = slave_unselect_seq::type_id::create("ss_deselect");
    ss_deselect.m_cfg = m_cfg;

    ss_deselect.start(m_sequencer);

    empty_buffer = data_unload_seq::type_id::create("empty_buffer");
    empty_buffer.m_cfg = m_cfg;

    empty_buffer.start(m_sequencer);
  endtask: body

endclass: tfer_over_by_poll_seq

//
// Sequence to configure the SPI randomly
//
class SPI_config_seq extends spi_bus_base_seq;

  `uvm_object_utils(SPI_config_seq)

  function new(string name = "SPI_config_seq");
    super.new(name);
  endfunction

  bit interrupt_enable;

  task body;
    super.body;

    // Randomize the register model to get a new config
    // Constraining the generated value within ranges
    if(!spi_rb.randomize() with {spi_rb.ctrl.go_bsy.value == 0;
                                 spi_rb.ctrl.ie.value == interrupt_enable;
                                 spi_rb.ss.cs.value != 0;
//                                 spi_rb.ctrl.char_len.value inside {0, 1, [31:33], [63:65], [95:97], 126, 127};
                                 spi_rb.ctrl.char_len.value inside {[1:31]};
                                 spi_rb.ctrl.tx_neg.value == 0;
                                 spi_rb.ctrl.rx_neg.value == 1;                                 
                                 spi_rb.divider.ratio.value inside {16'h0, 16'h1, 16'h2, 16'h4, 16'h8, 16'h10, 16'h20, 16'h40, 16'h80};
                                }) begin
      `uvm_error("body", "spi_rb randomization failure")
    end
    // This will write the generated values to the HW registers
    spi_rb.update(status, .path(UVM_FRONTDOOR), .parent(this));
    data = spi_rb.ctrl.get();
  endtask: body

endclass: SPI_config_seq

//
// Sequence to configure the SPI randomly
// writing configuration values in a random order
//
class SPI_config_rand_order_seq extends spi_bus_base_seq;

  `uvm_object_utils(SPI_config_rand_order_seq)

  function new(string name = "SPI_config_rand_order_seq");
    super.new(name);
  endfunction

  bit interrupt_enable;
  uvm_reg spi_regs[$];

  task body;
    super.body;

    spi_rb.get_registers(spi_regs);
    // Randomize the register model to get a new config
    // Constraining the generated value within ranges
    if(!spi_rb.randomize() with {spi_rb.ctrl.go_bsy.value == 0;
                                 spi_rb.ctrl.ie.value == interrupt_enable;
                                 spi_rb.ss.cs.value != 0;
//                                 spi_rb.ctrl.char_len.value inside {0, 1, [31:33], [63:65], [95:97], 126, 127};
                                 spi_rb.ctrl.char_len.value inside {[1:31]};
                                 spi_rb.divider.ratio.value inside {16'h0, 16'h1, 16'h2, 16'h4, 16'h8, 16'h10, 16'h20, 16'h40, 16'h80};
                                }) begin
      `uvm_error("body", "spi_rb randomization failure")
    end
    // This will write the generated values to the HW registers
    // in a random order
    spi_regs.shuffle();
    foreach(spi_regs[i]) begin
      spi_regs[i].update(status, .path(UVM_FRONTDOOR), .parent(this));
    end
    // Get the configured version of the control register
    data = spi_rb.ctrl.get();
  endtask: body

endclass: SPI_config_rand_order_seq

endpackage: spi_bus_sequence_lib_pkg
