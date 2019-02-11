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
// Class Description:
//
//
class spi_c_int_test extends spi_test_base;

// UVM Factory Registration Macro
//
`uvm_component_utils(spi_c_int_test)

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "spi_c_int_test", uvm_component parent = null);
extern task run_phase(uvm_phase phase);

endclass: spi_c_int_test

function spi_c_int_test::new(string name = "spi_c_int_test", uvm_component parent = null);
  super.new(name, parent);
endfunction


//
// This task starts the c program that then calls back into
// the UVM simulation
//
// It also monitors the interrupt line from the SPI block
// and calls the interrupt service routine when it is asserted
//
task spi_c_int_test::run_phase(uvm_phase phase);
  spi_tfer_seq spi_seq = spi_tfer_seq::type_id::create("spi_seq");


  phase.raise_objection(this, "Test Started");
  `uvm_info("run_phase", "starting c code", UVM_LOW)

  set_c_stimulus_register_block(spi_rm);

  fork
    start_c_code();
    // Respond to SPI transfers:
    begin
      forever begin
        spi_seq.BITS = 0;
        spi_seq.rx_edge = 0;
        spi_seq.start(m_env.m_spi_agent.m_sequencer);
        spi_seq.BITS = spi_rm.ctrl_reg.char_len.get();
        spi_seq.rx_edge = spi_rm.ctrl_reg.rx_neg.get();
        spi_seq.start(m_env.m_spi_agent.m_sequencer);
      end
    end
    begin
      forever begin
        m_env_cfg.wait_for_interrupt();
        interrupt_service_routine();
      end
    end
  join_any
  `uvm_info("run_phase", "c code finished", UVM_LOW)
  phase.drop_objection(this, "Test Finished");

endtask: run_phase
