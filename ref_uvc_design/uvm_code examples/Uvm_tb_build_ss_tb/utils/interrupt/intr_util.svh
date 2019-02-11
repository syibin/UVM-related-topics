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
class intr_util extends uvm_object;
  `uvm_object_utils(intr_util)
  
  function new(string name = "intr_util");
    super.new(name);
  endfunction    

  // Virtual Interface
  protected virtual intr_bfm m_bfm;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  bit               intr_val = 0;
  bit [7:0]         intr_req;       
  event             intr_asserted, intr_deasserted;

  //------------------------------------------
  // Methods
  //------------------------------------------
  task wait_for_interrupt();
    @intr_asserted;
  endtask : wait_for_interrupt

  function bit is_interrupt_cleared();
    return (intr_val == 0);
  endfunction : is_interrupt_cleared

  // Proxy Methods:
  function void notify_interrupt(bit [7:0] req);
    -> intr_asserted;
    intr_val = 1;
    intr_req = req;
  endfunction : notify_interrupt

  function void notify_interrupt_cleared(bit [7:0] req);
    -> intr_deasserted;
    intr_val = 0;
    intr_req = req;
  endfunction : notify_interrupt_cleared
  
  // Helper Methods:
  function void set_bfm(virtual intr_bfm bfm);
    m_bfm = bfm;
    m_bfm.proxy = this;
  endfunction : set_bfm
  
endclass : intr_util
