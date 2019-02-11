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
// A very simple AHB driver only capable of single reads and writes
//
//
interface ahb_driver_bfm (
    input         HCLK,
    input         HRESETn,

    output logic [31:0] HADDR,
    output logic  [1:0] HTRANS,
    output logic        HWRITE,
    output logic  [2:0] HSIZE,
    output logic  [2:0] HBURST,
    output logic  [3:0] HPROT,
    output logic [31:0] HWDATA,
    input  logic [31:0] HRDATA,
    input  logic  [1:0] HRESP,
    input  logic        HREADY,
    output logic        HSEL
);

  import ahb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

function void clear_sigs();
  HADDR <= 0;
  HTRANS <= 0;
  HWRITE <= 0;
  HSIZE <= 2;
  HBURST <= AHB_SINGLE;
  HPROT <= 0;
  HWDATA <= 0;
  HSEL <= 0;
endfunction : clear_sigs

task wait_reset();
  @(posedge HRESETn);
endtask : wait_reset

task drive (ahb_seq_item req);
  @(posedge HCLK);
  HADDR <= req.HADDR;
  HWRITE <= req.HWRITE;
  HTRANS <= AHB_NON_SEQ;
  @(posedge HCLK iff(HREADY == 1));
  HADDR <= 0;
  HWRITE <= 0;
  HTRANS <= AHB_IDLE;
  if(req.HWRITE == AHB_WRITE) begin
    HWDATA <= req.DATA;
  end
  @(posedge HCLK iff(HREADY == 1));
  if(req.HWRITE == AHB_READ) begin
    req.DATA = HRDATA;
  end
endtask : drive

endinterface: ahb_driver_bfm

