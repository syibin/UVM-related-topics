/*
Copyright (C) 2009 SysWip

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

interface wshb_m_if(input bit clk);
  // WISHBONE Master signals
  logic  [63:0] dat_i;
  logic  [63:0] dat_o;
  logic  [31:0] adr_o;
  logic         cyc_o;
  logic  [7:0]  sel_o;
  logic         stb_o;
  logic         we_o;
  logic         ack_i;
  logic         err_i;
  logic         rty_i;
  // Clock edge alignment
  sequence sync_posedge;
     @(posedge clk) 1;
  endsequence
  // Clocking block
  clocking cb @(posedge clk);
    // WISHBONE Master signals
    output dat_o;
    output adr_o;
    output cyc_o;
    output sel_o;
    output stb_o;
    output we_o;
    input  ack_i;
    input  err_i;
    input  rty_i;
    input  dat_i;
  endclocking
  // Clock edge alignment
  task clockAlign();
    wait(sync_posedge.triggered);
  endtask
  //
endinterface
