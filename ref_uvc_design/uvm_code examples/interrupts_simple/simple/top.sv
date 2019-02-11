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
// This example illustrates a simple interrupt service routine sequence
//
// It has an interface with 4 interrupts, when one of those
// interrupts occurs the ISR sequence then resets the interrupt
// source
//
// The ISR does a grab to gain exclusive access to the
// sequencer
//
// The other sequence running is setting interrupts randomly
// via a GPIO interface
//

// Need something to drive the bus interface that
// can be interrupted ...

package int_test_pkg;

  import uvm_pkg::*;
`include "uvm_macros.svh"

  import bidirect_bus_pkg::*;
  import interrupt_pkg::*;

class int_config extends uvm_object;

  `uvm_object_utils(int_config)

  interrupt_util INT[4];
  
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
  endtask: wait_for_IRQ0

  //
  // Task: wait_for_IRQ1
  //
  // This method waits for a rising edge on IRQ1
  //
  task wait_for_IRQ1();
    INT[1].wait_for_interrupt();
  endtask: wait_for_IRQ1

  //
  // Task: wait_for_IRQ2
  //
  // This method waits for a rising edge on IRQ2
  //
  task wait_for_IRQ2();
    INT[2].wait_for_interrupt();
  endtask: wait_for_IRQ2

  //
  // Task: wait_for_IRQ0
  //
  // This method waits for a rising edge on IRQ3
  //
  task wait_for_IRQ3();
    INT[3].wait_for_interrupt();
  endtask: wait_for_IRQ3

endclass: int_config

//
// Interrupt service routine
//
// Looks at the interrupt sources to determine what to do
//
class isr extends uvm_sequence #(bus_seq_item);

`uvm_object_utils(isr)

function new (string name = "isr");
  super.new(name);
endfunction

rand logic[31:0] addr;
rand logic[31:0] write_data;
rand bit read_not_write;
rand int delay;

bit error;
logic[31:0] read_data;

logic[31:0] temp_read_data;

int error_count = 0;

task body;
  bus_seq_item req;

  m_sequencer.grab(this); // Grab => Immediate exclusive access to sequencer

  req = bus_seq_item::type_id::create("req");

  // Read from the GPO register to determine the cause of the interrupt
  if(!req.randomize() with {addr == 32'h0100_0000; read_not_write == 1;}) begin
		error_count++;
    `uvm_error("body", "randomization failure with req")
  end
  start_item(req);
  finish_item(req);

  // Test the bits and reset if active
  //
  // Note that the order of the tests implements a priority structure
  //
  req.read_not_write = 0;
  if(req.read_data[0] == 1)
    begin
      `uvm_info("ISR:BODY", "IRQ0 detected", UVM_LOW)
      req.write_data[0] = 0;
      start_item(req);
      finish_item(req);
    end
  if(req.read_data[1] == 1)
    begin
      `uvm_info("ISR:BODY", "IRQ1 detected", UVM_LOW)
      req.write_data[1] = 0;
      start_item(req);
      finish_item(req);
    end
  if(req.read_data[2] == 1)
    begin
      `uvm_info("ISR:BODY", "IRQ2 detected", UVM_LOW)
       req.write_data[2] = 0;
      start_item(req);
      finish_item(req);
    end
  if(req.read_data[3] == 1)
    begin
      `uvm_info("ISR:BODY", "IRQ3 detected", UVM_LOW)
      req.write_data[3] = 0;
      start_item(req);
      finish_item(req);
    end

  temp_read_data = req.read_data;

  req.read_not_write = 1;
  if(temp_read_data[0] == 1)
    begin
      start_item(req);
      finish_item(req);
      if (req.read_data[0] != 0) begin
           error_count++;
          `uvm_error("ISR:BODY", "IRQ0 not cleared")
      end else begin
          `uvm_info("ISR:BODY", "IRQ0 cleared", UVM_LOW)
      end
    end
  if(temp_read_data[1] == 1)
    begin
      start_item(req);
      finish_item(req);
      if (req.read_data[1] != 0) begin
           error_count++;
          `uvm_error("ISR:BODY", "IRQ1 not cleared")
      end else begin
          `uvm_info("ISR:BODY", "IRQ1 cleared", UVM_LOW)
      end
    end
  if(temp_read_data[2] == 1)
    begin
      start_item(req);
      finish_item(req);
      if (req.read_data[2] != 0) begin
           error_count++;
          `uvm_error("ISR:BODY", "IRQ2 not cleared")
      end else begin
          `uvm_info("ISR:BODY", "IRQ2 cleared", UVM_LOW)
      end
    end
  if(temp_read_data[3] == 1)
    begin
      start_item(req);
      finish_item(req);
      if (req.read_data[3] != 0) begin
           error_count++;
          `uvm_error("ISR:BODY", "IRQ3 not cleared")
      end else begin
          `uvm_info("ISR:BODY", "IRQ3 cleared", UVM_LOW)
      end
    end

  m_sequencer.ungrab(this); // Ungrab the sequencer, let other sequences in

endtask: body


endclass: isr

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
        `uvm_error("body", "req randomization failure")
      end
      start_item(req);
      finish_item(req);
    end
  endtask: body

endclass: set_ints

  //
  // Sequence runs a bus intensive sequence on one thread
  // which is interrupted by one of four interrupts
  //
class int_test_seq extends uvm_sequence #(bus_seq_item);

  `uvm_object_utils(int_test_seq)

  int error_count = 0;

  function new (string name = "int_test_seq");
    super.new(name);
  endfunction

  task body;
    set_ints setup_ints; // Sequence: Main activity on the bus interface
    isr ISR;             // Interrupt service routine
    int_config i_cfg;    // Config containing wait_for_IRQx tasks

    setup_ints = set_ints::type_id::create("setup_ints");
    ISR = isr::type_id::create("ISR");
    if(!uvm_config_db #(int_config)::get(null, get_full_name(), "int_config", i_cfg)) begin
      `uvm_error("body", "failed to get int_config")
    end
    // Forked process - two levels of forking
    fork
      setup_ints.start(m_sequencer); // Main bus activity
      begin
        forever begin
          fork // Waiting for one or more of 4 interrupts
            i_cfg.wait_for_IRQ0();
            i_cfg.wait_for_IRQ1();
            i_cfg.wait_for_IRQ2();
            i_cfg.wait_for_IRQ3();
          join_any
          disable fork;
          ISR.start(m_sequencer); // Start the ISR
        end
      end
    join_any // At the end of the main bus activity sequence
    disable fork;

    error_count = ISR.error_count;
 
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

    phase.raise_objection(this, "Starting interrupt sequence");
    t_seq = int_test_seq::type_id::create("t_seq");
    t_seq.start(m_agent.m_sequencer);
    
    if(t_seq.error_count == 0) begin
      `uvm_info("** UVM TEST PASSED **", $sformatf("No Read Write mismatches"), UVM_LOW)
    end
    else begin
      `uvm_error("** UVM TEST FAILED **", $sformatf("Read Write mismatches"))
    end    
    
    phase.drop_objection(this, "Finishing interrupt sequence");
  endtask: run_phase

endclass: int_test

endpackage: int_test_pkg

module hdl_top;

  interrupt_if INT [4]();
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

  assign INT[0].irq = GPIO.gp_op[0];
  assign INT[1].irq = GPIO.gp_op[1];
  assign INT[2].irq = GPIO.gp_op[2];
  assign INT[3].irq = GPIO.gp_op[3];
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
