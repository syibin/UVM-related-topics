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
// Interface Description:
//
//
interface apb_slave_driver_bfm (input PCLK,
                                input PRESETn,
                                input [31:0] PADDR,
                                output logic[31:0] PRDATA,
                                input[31:0] PWDATA,
                                input[31:0] PSEL,
                                input PENABLE,
                                input PWRITE,
                                output logic PREADY,
                                output logic PSLVERR);
  
  import apb_slave_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
  int apb_index = 0;
  
//------------------------------------------
// Methods
//------------------------------------------
  function void set_apb_index(int index);
    apb_index = index;
  endfunction : set_apb_index

  task reset();
    while (!PRESETn) begin
      PREADY <= 1'b0;
      PSLVERR <= 1'b0;
      @(posedge PCLK);
    end
  endtask : reset

  task setup_phase(apb_slave_setup_item req);
    @(posedge PCLK);
    while (PSEL[apb_index] != 1'b1) @(posedge PCLK);
    req.addr = PADDR;
    req.rw = PWRITE;
    if (req.rw) req.wdata = PWDATA;
  endtask : setup_phase

  task access_phase(apb_slave_access_item rsp);
    repeat (rsp.delay + 1) @(posedge PCLK);
    if ( ! rsp.rw) PRDATA <= rsp.rdata;
    PREADY <= 1'b1;
    PSLVERR <= rsp.slv_err;
    while (PENABLE != 1'b1) @(posedge PCLK);
    @(posedge PCLK);
    PREADY <= 1'b0;
    PSLVERR <= 1'b0;
  endtask : access_phase

endinterface: apb_slave_driver_bfm
