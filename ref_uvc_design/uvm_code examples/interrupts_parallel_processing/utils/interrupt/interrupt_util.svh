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
// Class Description:
//
//
class interrupt_util extends uvm_object;
  `uvm_object_utils(interrupt_util)

  // Virtual Interface
  protected virtual interrupt_if bfm;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  bit               interrupt_val = 0;
  bit [7:0]         interrupt_status;       
  event             interrupt_asserted, interrupt_deasserted;

  //------------------------------------------
  // Methods
  //------------------------------------------
  function new(string name = "interrupt_util");
    super.new(name);
  endfunction

  task wait_for_interrupt();
    @interrupt_asserted;
  endtask : wait_for_interrupt

  function bit is_interrupt_cleared();
    return (interrupt_val == 0);
  endfunction : is_interrupt_cleared

  // Proxy Methods:
  function void notify_interrupt(bit [7:0] status);
    -> interrupt_asserted;
    interrupt_val = 1;
    interrupt_status = status;
  endfunction : notify_interrupt

  function void notify_interrupt_cleared(bit [7:0] status);
    -> interrupt_deasserted;
    interrupt_val = 0;
    interrupt_status = status;
  endfunction : notify_interrupt_cleared
  
  // Helper Methods:
  function void set_bfm(virtual interrupt_if interrupt_bfm);
    bfm = interrupt_bfm;
    bfm.proxy = this;
  endfunction : set_bfm

  function bit [7:0] get_status();
    return interrupt_status;
  endfunction : get_status
  
  function bit [7:0] get_bfm_status();
    return bfm.get_status;
  endfunction : get_bfm_status

  task wait_for_clock( int n = 1 );
    bfm.wait_for_clock(n);
  endtask // wait_for_clock
  
endclass : interrupt_util
