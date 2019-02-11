/*
Copyright (C) 2012 SysWip

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

`timescale 1ns/10ps

interface axi4lite_s_if(input bit clk);
  // Slave write address channel
  logic  [31:0] awaddr;
  logic         awvalid;
  logic         awready;
  // Slave write data channel
  logic  [127:0]wdata;
  logic  [15:0] wstrb;
  logic         wvalid;
  logic         wready;
  // Slave write response channel
  logic  [1:0]  bresp;
  logic         bvalid;
  logic         bready;
  // Slave read address channel
  logic  [31:0] araddr;
  logic         arvalid;
  logic         arready;
  // Slave read data channel
  logic  [127:0]rdata;
  logic  [1:0]  rresp;
  logic         rvalid;
  logic         rready;
  // Clock edge alignment
  sequence sync_posedge;
     @(posedge clk) 1;
  endsequence
  // Clocking block
  clocking cb @(posedge clk);
    // Slave write address channel
    input  awaddr;
    input  awvalid;
    output awready;
    // Slave write data channel
    input  wdata;
    input  wstrb;
    input  wvalid;
    output wready;
    // Slave write response channel
    output bresp;
    output bvalid;
    input  bready;
    // Slave read address channel
    input  araddr;
    input  arvalid;
    output arready;
    // Slave read data channel
    output rdata;
    output rresp;
    output rvalid;
    input  rready;
  endclocking
  // Clock edge alignment
  task clockAlign();
    wait(sync_posedge.triggered);
  endtask
  //
endinterface
