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

package gpio_bus_sequence_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import gpio_reg_pkg::*;
import gpio_env_pkg::*;

// This base class provides read and write methods
class gpio_bus_base_sequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(gpio_bus_base_sequence)

  string reg_name = "gpio_reg_file.GPO_reg";

  gpio_env_config m_cfg;
  gpio_reg_block gpio_rb;

  // Properties used by the various register access methods:
  rand  uvm_reg_data_t data; // For passing data
  uvm_status_e status;       // Returning access status

  function new(string name = "gpio_bus_base_sequence");
    super.new(name);
  endfunction

  // This gets the env config object via the sequencer
  task body();
    if (m_cfg==null)
       `uvm_fatal("CONFIG_LOAD", "gpio_env_config is null. Have you set() it?")
    gpio_rb = m_cfg.gpio_rb;
  endtask: body

  task read(uvm_reg _reg);
    _reg.read(status, data, .parent(this));
  endtask

  task write(uvm_reg _reg, uvm_reg_data_t _data);
    _reg.write(status, data, .parent(this));
  endtask

  task random_write(uvm_reg _reg);
    // Randomize the local data value
    if(!this.randomize()) begin
      `uvm_error("body", "Randomization error for this")
    end
    // Write to the register
    write(_reg, data);
  endtask

endclass: gpio_bus_base_sequence

class gpio_reg_rand extends gpio_bus_base_sequence;

  `uvm_object_utils(gpio_reg_rand)

  rand int iterations;

  function new(string name = "gpio_reg_rand");
    super.new(name);
  endfunction

  task body;
    uvm_reg regs[];
    
    super.body();
    regs = '{gpio_rb.gpio_out, gpio_rb.gpio_oe, gpio_rb.gpio_inte, gpio_rb.gpio_ptrig,
                     gpio_rb.gpio_aux, gpio_rb.gpio_ctrl, gpio_rb.gpio_ints, gpio_rb.gpio_eclk,
                     gpio_rb.gpio_nec};
    repeat(iterations) begin
      regs.shuffle();
      randcase
        1:regs[0].read(status, data, .parent(this));
        1:begin
            // Randomize the local data value
            if(!this.randomize()) begin
              `uvm_error("body", "Randomization error for this")
            end
            // Write to the register
            regs[0].write(status, data, .parent(this));
          end
      endcase
    end
  endtask: body

endclass: gpio_reg_rand

// Hammers the GPO and GPOE registers
class output_test_seq extends gpio_bus_base_sequence;

  `uvm_object_utils(output_test_seq)

  function new(string name = "output_test_seq");
    super.new(name);
  endfunction

  task body;
    super.body();
    // Randomize the register model to get a new config
    if(!gpio_rb.randomize()) begin
      `uvm_error("body", "gpio_rb randomization failure")
    end
    // This will write the generated values to the HW registers
    gpio_rb.update(status, .path(UVM_FRONTDOOR), .parent(this));

  endtask: body

endclass: output_test_seq

// Hammers the AUX registers
class aux_reg_seq extends gpio_bus_base_sequence;

  `uvm_object_utils(aux_reg_seq)

  function new(string name = "aux_reg_seq");
    super.new(name);
  endfunction

  task body;
    super.body();

    // Randomize the local data value
    if(!this.randomize()) begin
      `uvm_error("body", "Randomization error for this")
    end
    // Write to the register
    gpio_rb.gpio_aux.write(status, data, .parent(this));
  endtask: body

endclass: aux_reg_seq

// Interrupt service routine - fairly directed
class gpio_isr extends gpio_bus_base_sequence;

  `uvm_object_utils(gpio_isr)

  function new(string name = "isr");
    super.new(name);
  endfunction

  task body;
    super.body();

    // This ISR is getting called because an int has occurred
    // Read from the ISR, then clear any set bits
    //
    m_sequencer.grab(this); // Exclusive access

    read(gpio_rb.gpio_ints);

    write(gpio_rb.gpio_ints, 0);

    m_sequencer.ungrab(this); // Release hold on sequencer
  endtask: body

endclass: gpio_isr

// Random toggling of all the registers associated with the
// input stream
class gpio_input_test_seq extends gpio_bus_base_sequence;

  `uvm_object_utils(gpio_input_test_seq)

  rand int iterations;

  function new(string name = "gpio_input_test_seq");
    super.new("");
  endfunction

  task body;
    super.body();

    repeat(20) begin
      random_write(gpio_rb.gpio_in);
    end

    write(gpio_rb.gpio_eclk, 32'hFFFF_FFFF);

    repeat(20) begin
      random_write(gpio_rb.gpio_in);
    end

    write(gpio_rb.gpio_nec, 32'hFFFF_FFFF);

    repeat(20) begin
      random_write(gpio_rb.gpio_in);
    end

    write(gpio_rb.gpio_inte, 32'hFFFF_FFFF);

    repeat(20) begin
        read(gpio_rb.gpio_ints);
    end

    write(gpio_rb.gpio_ctrl, 32'h1);

    repeat(20) begin
      random_write(gpio_rb.gpio_ints);
    end

    write(gpio_rb.gpio_ptrig, 32'hFFFF_FFFF);

    repeat(20) begin
      read(gpio_rb.gpio_ints);
    end

//    repeat(iterations) begin
//      regs.shuffle();
//      randcase
//        10:random_write(regs[0]);
//        1:read(regs[0]);
//      endcase
//    end
  endtask: body

endclass: gpio_input_test_seq

class gpio_toggle_test_seq extends gpio_bus_base_sequence;

  `uvm_object_utils(gpio_toggle_test_seq)

  function new(string name = "gpio_toggle_test_seq");
    super.new(name);
  endfunction

  task body;
    super.body();
    gpio_rb.gpio_out.write(status, 32'haa55_aa55, .parent(this));
    gpio_rb.gpio_oe.write(status, 32'h55aa_55aa, .parent(this));
    gpio_rb.gpio_out.write(status, 32'h55aa_55aa, .parent(this));
    gpio_rb.gpio_oe.write(status, 32'haa55_aa55, .parent(this));
  endtask: body

endclass: gpio_toggle_test_seq

class diag_outputs extends gpio_bus_base_sequence;

  `uvm_object_utils(diag_outputs)

  function new(string name = "diag_outputs");
    super.new(name);
  endfunction

  task body;

    super.body();
    gpio_rb.gpio_out.write(status, 32'haaaa_aaaa, .parent(this));
    gpio_rb.gpio_out.write(status, 32'h5555_5555, .parent(this));
    #100ns;
    gpio_rb.gpio_aux.write(status, 32'hffff_ffff, .parent(this));
  endtask: body

endclass: diag_outputs

endpackage: gpio_bus_sequence_lib_pkg
