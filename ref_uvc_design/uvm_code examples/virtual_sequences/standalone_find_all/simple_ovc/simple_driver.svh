//------------------------------------------------------------
//   Copyright 2007-2018 Mentor Graphics Corporation
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

  // CLASS: simple_driver
  // A simple driver. Just get an item, and "pretend"
  // to send it out on a bus. Delay some time, and print
  // a message.
  class simple_driver extends uvm_driver #(simple_item);
    `uvm_component_utils(simple_driver)
  
    int registers[int] = '{default: 0}; // Sparse Array
                                        //   of Registers.
    int memory[int]    = '{default: 0}; // Sparse Array 
                                        //   of Memory.
  
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    task bus_cycle(bus_op_t op, int addr, inout int data);
      if (op == BUS_R) begin
        data = memory[addr];
        #10;
      end
      else begin
        memory[addr] = data;
        #5;
      end
    endtask
  
    task run_phase(uvm_phase phase);
      simple_item item, rsp;
      `uvm_info("run", "...starting", UVM_MEDIUM)
      forever begin 
        seq_item_port.get_next_item(item);
   
        // ------------------------------------------------
        // An actual READ or WRITE cycle on a bus would
        // occur here. Instead we fake it.
        // ------------------------------------------------
        bus_cycle(item.op, item.addr, item.data);
        // ------------------------------------------------
        // End of Bus cycle.
        // ------------------------------------------------
        `uvm_info("completed", item.convert2string() , UVM_MEDIUM );
        seq_item_port.item_done();
      end
    endtask: run_phase
  endclass : simple_driver
