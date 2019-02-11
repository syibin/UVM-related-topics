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
//
// This example shows how to use sequence priorities to give
// different Interrupt Service Routine (ISR) sequences different
// priority levels. This allows a higher priority ISR to send
// bus sequence_items in preference to a lower priority ISR
//
// The example uses the bidirectional bus agent
//

// Need something to drive the bus interface that
// can be interrupted ...

package int_test_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import bidirect_bus_pkg::*;
import interrupt_pkg::*;

typedef enum {LOW = 200, MED = 300, HIGH = 400} int_priority_e;

class int_config extends uvm_object;

  `uvm_object_utils(int_config)

  interrupt_util INT[4];
  
  int int_0_count;
  int int_1_count;
  int int_2_count;
  int int_3_count;
  
  function new(string name = "int_config");
    super.new(name);
  endfunction

  //
  // Task: wait_for_clock
  //
  // This method waits for n clock cycles. This technique can be used for clocks,
  // resets and any other signals.
  //
  task wait_for_clock( int n = 1 );
    INT[0].wait_for_clock(n);
  endtask

  //
  // Task: wait_for_IRQ0
  //
  // This method waits for a rising edge on IRQ0
  //
  task wait_for_IRQ0();
    INT[0].wait_for_interrupt();
    int_0_count++;
  endtask: wait_for_IRQ0

  //
  // Task: wait_for_IRQ1
  //
  // This method waits for a rising edge on IRQ1
  //
  task wait_for_IRQ1();
    INT[1].wait_for_interrupt();
    int_1_count++;
  endtask: wait_for_IRQ1

  //
  // Task: wait_for_IRQ2
  //
  // This method waits for a rising edge on IRQ2
  //
  task wait_for_IRQ2();
    INT[2].wait_for_interrupt();
    int_2_count++;
  endtask: wait_for_IRQ2

  //
  // Task: wait_for_IRQ0
  //
  // This method waits for a rising edge on IRQ3
  //
  task wait_for_IRQ3();
    INT[3].wait_for_interrupt();
    int_3_count++;
  endtask: wait_for_IRQ3

endclass: int_config

// Interrupt service routine
//
class isr extends uvm_sequence #(bus_seq_item);

`uvm_object_utils(isr)

function new (string name = "isr");
  super.new(name);
endfunction

string id;
int i;
int isr_no;

bit error;
logic[31:0] read_data;

function void do_copy(uvm_object rhs);
  isr rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error(id, "do_copy failed")
  end
  id = rhs_.id;
  i = rhs_.i;
  isr_no = rhs_.isr_no;
endfunction: do_copy

task body;
  bus_seq_item req;

  req = bus_seq_item::type_id::create("req");
  `uvm_info(id, $sformatf("Entering ISR %0d", isr_no), UVM_LOW)
  if(!req.randomize() with {addr == 32'h0100_0020; read_not_write == 1;}) begin
    `uvm_error("body", "req randomization failed")
  end
  start_item(req);
  `uvm_info(id, "Read back status", UVM_LOW)
  finish_item(req);
  while(req.read_data[i] != 0) begin
    start_item(req);
    finish_item(req);
  end
  `uvm_info(id, $sformatf("Leaving ISR %0d", isr_no), UVM_LOW)

endtask: body

endclass: isr

// Sets the interrupts randomly via the DUT
//
class set_ints extends uvm_sequence #(bus_seq_item);

`uvm_object_utils(set_ints)

function new (string name = "set_ints");
  super.new(name);
endfunction

task body;
  bus_seq_item req;

  req = bus_seq_item::type_id::create("req");

  repeat(100) begin
    if(!req.randomize() with {addr inside {[32'h0100_0000:32'h0100_001C]}; read_not_write == 0;}) begin
      `uvm_error("body", "req randomization failed")
    end
    start_item(req);
    finish_item(req);
  end
endtask: body

endclass: set_ints

// Top level sequence with 4 ISR sequences running in parallel with
// the interrupt generation sequence
class int_test_seq extends uvm_sequence #(bus_seq_item);

`uvm_object_utils(int_test_seq)

function new (string name = "int_test_seq");
  super.new(name);
endfunction

task body;
  set_ints setup_ints; // Main sequence running on the bus
  isr ISR0, ISR1, ISR2, ISR3; // Interrupt service routines

  int_config i_cfg;

  setup_ints = set_ints::type_id::create("setup_ints");
  // ISR0 is the highest priority
  ISR0 = isr::type_id::create("ISR0");
  ISR0.id = "ISR0";
  ISR0.i = 0;
  // ISR1 is medium priority
  ISR1 = isr::type_id::create("ISR1");
  ISR1.id = "ISR1";
  ISR1.i = 1;
  // ISR2 is medium priority
  ISR2 = isr::type_id::create("ISR2");
  ISR2.id = "ISR2";
  ISR2.i = 2;
  // ISR3 is lowest priority
  ISR3 = isr::type_id::create("ISR3");
  ISR3.id = "ISR3";
  ISR3.i = 3;

  if(!uvm_config_db #(int_config)::get(null, get_full_name(), "int_config", i_cfg)) begin
    `uvm_error("body", "unable to get int_config object")
  end

  // Set up sequencer to use priority based on FIFO order
  m_sequencer.set_arbitration(UVM_SEQ_ARB_STRICT_FIFO);

  // A main thread, plus one for each interrupt ISR
  fork
    setup_ints.start(m_sequencer);
    forever begin // Highest priority
      i_cfg.wait_for_IRQ0();
      ISR0.isr_no++;
      ISR0.start(m_sequencer, this, HIGH);
    end
    forever begin // Medium priority
      i_cfg.wait_for_IRQ1();
      ISR1.isr_no++;
      ISR1.start(m_sequencer, this, MED);
    end
    forever begin // Medium priority
      i_cfg.wait_for_IRQ2();
      ISR2.isr_no++;
      ISR2.start(m_sequencer, this, MED);
    end
    forever begin // Lowest priority
      i_cfg.wait_for_IRQ3();
      ISR3.isr_no++;
      ISR3.start(m_sequencer, this, LOW);
    end
  join_any
  disable fork;
  
  if((ISR0.isr_no == i_cfg.int_0_count) & (ISR1.isr_no == i_cfg.int_1_count) & (ISR2.isr_no == i_cfg.int_2_count) & (ISR3.isr_no == i_cfg.int_3_count)) begin
    `uvm_info("** UVM TEST PASSED **", "All interrupts were serviced", UVM_LOW)
  end
  else begin
    `uvm_error("!! UVM TEST FAILED !!", "Not all interrupts were serviced")
  end

endtask: body

endclass: int_test_seq

class int_test extends uvm_component;

`uvm_component_utils(int_test)

bidirect_bus_agent m_agent;
bidirect_bus_agent_config m_bus_cfg;
int_config m_int_cfg;

function new(string name = "int_test", uvm_component parent = null);
  super.new(name, parent);
endfunction

  function void build_phase(uvm_phase phase);
    m_int_cfg = int_config::type_id::create("m_int_cfg");
    for (int ii = 0; ii < 4; ii++) begin
      virtual interrupt_if temp_int_if;
      interrupt_util int_util = interrupt_util::type_id::create($sformatf("int%0d_util", ii));
      if(!uvm_config_db #(virtual interrupt_if)::get(this, "", $sformatf("INT%0d_vif", ii), temp_int_if)) begin
        `uvm_error("build_phase", $sformatf("Interrupt virtual interface handle %0d not found", ii))
      end
      int_util.set_bfm(temp_int_if);
      m_int_cfg.INT[ii] = int_util;
    end
    uvm_config_db #(int_config)::set(this, "*", "int_config", m_int_cfg);
    m_bus_cfg = bidirect_bus_agent_config::type_id::create("m_bus_cfg");
    if(!uvm_config_db #(virtual bidirect_bus_driver_bfm)::get(this, "", "BUS_drv_bfm", m_bus_cfg.drv_bfm)) begin
      `uvm_error("build_phase", "BUS virtual interface handle not found")
    end
    uvm_config_db #(bidirect_bus_agent_config)::set(this, "*", "direct_bus_agent_config", m_bus_cfg);
    m_agent = bidirect_bus_agent::type_id::create("m_agent", this);
  endfunction: build_phase

task run_phase(uvm_phase phase);
  int_test_seq t_seq;

  phase.raise_objection(this, "Starting prioritisation test");
  t_seq = int_test_seq::type_id::create("t_seq");
  t_seq.start(m_agent.m_sequencer);

  phase.drop_objection(this, "Finishing prioritisation test");
endtask: run_phase

endclass: int_test

endpackage: int_test_pkg

module hdl_top;

  interrupt_if INT[4]();
  bus_if BUS();
  bidirect_bus_driver_bfm BUS_drv_bfm(
   .clk        (BUS.clk),
   .resetn     (BUS.resetn),
   .addr       (BUS.addr),
   .write_data (BUS.write_data),
   .rnw        (BUS.rnw),
   .valid      (BUS.valid),
   .ready      (BUS.ready),
   .read_data  (BUS.read_data),
   .error      (BUS.error)
);
                                      
  gpio_if GPIO();
  bidirect_bus_slave DUT(.bus(BUS), .gpio(GPIO));

  assign  GPIO.gp_ip[0] = INT[0].irq;
  assign  GPIO.gp_ip[1] = INT[1].irq;
  assign  GPIO.gp_ip[2] = INT[2].irq;
  assign  GPIO.gp_ip[3] = INT[3].irq;
  assign INT[0].clk = BUS.clk;
  assign INT[1].clk = BUS.clk;
  assign INT[2].clk = BUS.clk;
  assign INT[3].clk = BUS.clk;

// Free running clock
initial
  begin
    BUS.clk = 0;
    forever begin
      #10 BUS.clk = ~BUS.clk;
    end
  end

// Reset
initial
  begin
    BUS.resetn = 0;
    repeat(3) begin
      @(posedge BUS.clk);
    end
    BUS.resetn = 1;
  end

// Interrupts
initial
  begin
    @(posedge BUS.resetn);
    repeat(1000) begin
      @(negedge BUS.clk);
      randcase
        1: INT[0].irq = 1;
        2: INT[1].irq = 1;
        2: INT[2].irq = 1;
        10: INT[3].irq = 1;
        80: begin
          INT[0].irq = 0;
          INT[1].irq = 0;
          INT[2].irq = 0;
          INT[3].irq = 0;
        end
      endcase
    end
  end

  initial begin
    import uvm_pkg::uvm_config_db;
    uvm_config_db #(virtual bidirect_bus_driver_bfm)::set(null, "uvm_test_top", "BUS_drv_bfm" , BUS_drv_bfm);
  end

  for (genvar ii = 0; ii < 4; ii++)
    initial begin : int_gen_block
      import uvm_pkg::uvm_config_db;
      uvm_config_db #(virtual interrupt_if)::set(null, "uvm_test_top", $sformatf("INT%0d_vif", ii) , INT[ii]);
    end
endmodule: hdl_top

module hvl_top();
  import uvm_pkg::*;
  import bidirect_bus_pkg::*;
  import int_test_pkg::*;

  // UVM start up:
  initial begin
    run_test("int_test");
  end

endmodule : hvl_top
