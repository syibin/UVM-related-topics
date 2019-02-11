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

interface axi4_str_monitor_if(input bit clk);
  // Avalon ST Streaming Interfaces Slave(sink) signals
  logic  [255:0] tdata;
  logic          tvalid;
  logic          tready;
  logic          tlast;
  logic  [31:0]  tstrb;
  logic  [31:0]  tkeep;
  logic  [255:0] tuser;
  logic  [7:0]   tid;
  logic  [7:0]   tdest;
  // Clock edge alignment
  sequence sync_posedge;
     @(posedge clk) 1;
  endsequence
  // Clocking block
  clocking cb @(posedge clk);
    input  tdata;
    input  tvalid;
    input  tlast;
    input  tstrb;
    input  tkeep;
    input  tuser;
    input  tid;
    input  tdest;
    input  tready;
  endclocking
  // Clock edge alignment
  task clockAlign();
    wait(sync_posedge.triggered);
  endtask
  //
endinterface
