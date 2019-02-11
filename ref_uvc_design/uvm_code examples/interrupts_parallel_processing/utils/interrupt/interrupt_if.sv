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
// Interface: interrupt_if
//
// 
interface interrupt_if;

  interrupt_pkg::interrupt_util proxy;

  logic       clk;
  logic       irq;
  logic [7:0] status;
  

  //
  // Interrupt notifications are pushed to the interrupt_util proxy handle.
  //
  always begin
    wait (irq == 1);
    proxy.notify_interrupt(status);
    wait (irq == 0);
    proxy.notify_interrupt_cleared(status);
  end

  //
  // Task: get_status
  //
  // This method returns the value of the status.
  //
  function bit [7:0] get_status();
    return status;
  endfunction : get_status
  
  //
  // Task: wait_for_clock
  //
  // This method waits for n clock cycles.
  //
  task automatic wait_for_clock( int n = 1 );
    repeat( n ) @( posedge clk );
  endtask // wait_for_clock
  
endinterface: interrupt_if
