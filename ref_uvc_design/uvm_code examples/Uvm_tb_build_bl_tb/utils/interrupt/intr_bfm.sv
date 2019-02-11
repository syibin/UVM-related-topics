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
// Interface: intr_bfm
//
// 
interface intr_bfm (
   input logic       IRQ, 
   input logic [7:0] IREQ
);

  intr_pkg::intr_util proxy;

  always begin
    wait (IRQ == 1);
    proxy.notify_interrupt(IREQ);
    wait (IRQ == 0);
    proxy.notify_interrupt_cleared(IREQ);
  end

  function bit [7:0] get_req();
    return IREQ;
  endfunction : get_req
  
endinterface: intr_bfm
