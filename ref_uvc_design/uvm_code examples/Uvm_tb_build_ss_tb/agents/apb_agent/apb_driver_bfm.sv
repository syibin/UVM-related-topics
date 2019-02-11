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
// BFM Interface Description:
//
//
interface apb_driver_bfm (
  input         PCLK,
  input         PRESETn,

  output logic [31:0] PADDR,
  input  logic [31:0] PRDATA,
  output logic [31:0] PWDATA,
  output logic [15:0] PSEL, // Only connect the ones that are needed
  output logic        PENABLE,
  output logic        PWRITE,
  input  logic        PREADY
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
apb_agent_config m_cfg;
//------------------------------------------
// Methods
//------------------------------------------

function void clear_sigs();
  PSEL <= 0;
  PENABLE <= 0;
  PADDR <= 0;
endfunction : clear_sigs
  
task drive (apb_seq_item req);
  int psel_index;
  
  repeat(req.delay)
    @(posedge PCLK);
  psel_index = sel_lookup(req.addr);
  if(psel_index >= 0) begin
    PSEL[psel_index] <= 1;
    PADDR <= req.addr;
    PWDATA <= req.data;
    PWRITE <= req.we;
    @(posedge PCLK);
    PENABLE <= 1;
    while (!PREADY)
      @(posedge PCLK);
    if(PWRITE == 0)
      begin
        req.data = PRDATA;
      end
  end
  else begin
    `uvm_error("RUN", $sformatf("Access to addr %0h out of APB address range", req.addr))
    req.error = 1;
  end
endtask : drive

// Looks up the address and returns PSEL line that should be activated
// If the address is invalid, a non positive integer is returned to indicate an error
function int sel_lookup(logic[31:0] address);
  for(int i = 0; i < m_cfg.no_select_lines; i++) begin
    if((address >= m_cfg.start_address[i]) && (address <= (m_cfg.start_address[i] + m_cfg.range[i]))) begin
      return i;
    end
  end
  return -1; // Error: Address not found
endfunction: sel_lookup
  
endinterface: apb_driver_bfm

