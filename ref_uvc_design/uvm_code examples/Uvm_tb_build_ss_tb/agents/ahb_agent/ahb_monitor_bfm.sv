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
interface ahb_monitor_bfm (
    input        HCLK,
    input        HRESETn,

    input logic [31:0] HADDR,
    input logic  [1:0] HTRANS,
    input logic        HWRITE,
    input logic  [2:0] HSIZE,
    input logic  [2:0] HBURST,
    input logic  [3:0] HPROT,
    input logic [31:0] HWDATA,
    input logic [31:0] HRDATA,
    input logic  [1:0] HRESP,
    input logic        HREADY,
    input logic        HSEL
);

  import ahb_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
ahb_monitor proxy;

//------------------------------------------
// Methods
//------------------------------------------

// BFM Methods:
task run();
  ahb_seq_item item;
  ahb_seq_item cloned_item;

  item = ahb_seq_item::type_id::create("item");

  forever begin
    // Detect the protocol event on the TBAI virtual interface
    @(posedge HCLK iff((HREADY == 1) && (HTRANS == AHB_NON_SEQ)));
    item.HADDR = HADDR;
    item.HWRITE = ahb_rw_e'(HWRITE);
    @(posedge HCLK iff(HREADY == 1));
    if(item.HWRITE == AHB_WRITE) begin
      item.DATA = HWDATA;
    end
    else begin
      item.DATA = HRDATA;
    end
    item.HRESP = ahb_resp_e'(HRESP);
    // Clone and publish the cloned item to the subscribers
    $cast(cloned_item, item.clone());
    proxy.notify_transaction(cloned_item);
  end
endtask: run

endinterface: ahb_monitor_bfm
