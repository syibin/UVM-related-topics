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
interface spi_driver_bfm (
  input  logic       clk,
  input  logic [7:0] cs,
  output logic       miso,
  input  logic       mosi
);

`include "uvm_macros.svh"
import uvm_pkg::*;
import spi_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

task wait_cs_isknown();
  miso = 1;
  while(cs === 8'hxx) begin
    #1;
  end
endtask : wait_cs_isknown

task drive(spi_seq_item req);
  int no_bits;
  
  while(cs == 8'hff) begin
    @(cs);
  end
  `uvm_info("SPI_DRV_RUN:", $sformatf("Starting transmission: %0h RX_NEG State %b, no of bits %0d", req.spi_data, req.RX_NEG, req.no_bits), UVM_LOW)
  no_bits = req.no_bits;
  if(no_bits == 0) begin
    no_bits = 128;
  end
  miso <= req.spi_data[0];
  for(int i = 1; i < no_bits-1; i++) begin
    if(req.RX_NEG == 1) begin
      @(posedge clk);
    end
    else begin
      @(negedge clk);
    end
    miso <= req.spi_data[i];
    if(cs == 8'hff) begin
      break;
    end
  end
endtask : drive
  
endinterface: spi_driver_bfm
