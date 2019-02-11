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

package pss_test_seq_lib_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import ahb_agent_pkg::*;
import spi_agent_pkg::*;
import gpio_agent_pkg::*;
import gpio_bus_sequence_lib_pkg::*;
import gpio_test_sequence_lib_pkg::*;
import spi_bus_sequence_lib_pkg::*;
import spi_test_seq_lib_pkg::*;
import pss_env_pkg::*;

class pss_test_seq_base extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(pss_test_seq_base)

  function new(string name = "pss_test_seq_base");
    super.new(name);
  endfunction

  // The sequencers I need
  ahb_sequencer ahb;
  spi_sequencer spi;
  gpio_sequencer gpi;

  pss_env_config m_cfg;

  task body;

    if((ahb==null) || (spi==null) || (gpi==null)) begin
      `uvm_fatal("NULL_SEQ", "A sequencer handle is null. This is bad!");
    end

    // Useful to get to the interrupt line ...
    if (m_cfg == null) begin
      `uvm_fatal("CONFIG_LOAD", "Configuration is null. This is bad!");
    end
  endtask: body

endclass:pss_test_seq_base

class gpio_outputs_vseq extends pss_test_seq_base;

  `uvm_object_utils(gpio_outputs_vseq)

  function new(string name = "gpio_outputs_vseq");
    super.new(name);
  endfunction

  task body;
    output_test_seq GP_OPs = output_test_seq::type_id::create("GP_OPs");

    // Get the virtual sequencer handles assigned
    super.body();

    begin
      repeat(200) begin
        GP_OPs.start(ahb);
      end
    end

  endtask: body

endclass: gpio_outputs_vseq

class spi_int_vseq extends pss_test_seq_base;

`uvm_object_utils(spi_int_vseq)

logic[31:0] control;

function new(string name = "spi_intr_vseq");
  super.new(name);
endfunction

  task body;
    // Sequences to be used
    ctrl_go_seq go = ctrl_go_seq::type_id::create("go");
    SPI_config_rand_order_seq spi_config = SPI_config_rand_order_seq::type_id::create("spi_config");
    tfer_over_by_poll_seq wait_unload = tfer_over_by_poll_seq::type_id::create("wait_unload");
    spi_rand_seq spi_transfer = spi_rand_seq::type_id::create("spi_transfer");
    ahb_write_seq ahb_write = ahb_write_seq::type_id::create("ahb_write");
    ahb_read_seq ahb_read = ahb_read_seq::type_id::create("ahb_read");

    go.m_cfg = m_cfg.m_spi_env_cfg;
    spi_config.m_cfg = m_cfg.m_spi_env_cfg;
    wait_unload.m_cfg = m_cfg.m_spi_env_cfg;

    super.body;

    control = 0;

    // Set up the interrupt controller for the SPI interrupts
    ahb_write.addr = 32'h200;
    ahb_write.data = 32'h1;
    ahb_read.addr = 32'h204;
    ahb_write.start(ahb);

    repeat(10) begin
      spi_config.interrupt_enable = 1;
      spi_config.start(m_sequencer);
      control = spi_config.data;
      
      spi_transfer.BITS = control[6:0];
      spi_transfer.rx_edge = control[9];
      fork
        spi_transfer.start(spi);      
      join_none
      go.start(m_sequencer);
      begin
        m_cfg.wait_for_interrupt;
        ahb_read.start(ahb);
        wait_unload.start(m_sequencer);          
        if(!m_cfg.is_interrupt_cleared()) begin
          `uvm_error("INT_ERROR", "Interrupt not cleared by register read/write");
        end
      end
    end
  endtask

endclass



endpackage: pss_test_seq_lib_pkg
