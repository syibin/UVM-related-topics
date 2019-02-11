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

interface wshb_s_if(input bit clk);
  // WISHBONE Slave signals
  logic  [63:0] dat_i;
  logic  [63:0] dat_o;
  logic  [31:0] adr_i;
  logic         cyc_i;
  logic  [7:0]  sel_i;
  logic         stb_i;
  logic         we_i;
  logic         ack_o;
  logic         err_o;
  logic         rty_o;
  // Clock edge alignment
  sequence sync_posedge;
     @(posedge clk) 1;
  endsequence
  // Clocking block 0 positive edge
  clocking cb @(posedge clk);
    // WISHBONE Slave signals
    output dat_o;
    output ack_o;
    output err_o;
    output rty_o;
    input  adr_i;
    input  sel_i;
    input  stb_i;
    input  we_i;
    input  cyc_i;
    input  dat_i;
  endclocking
  // Clocking block 1 negative edge
  clocking cb_n @(negedge clk);
    // WISHBONE Slave signals
    output dat_o;
    output ack_o;
    output err_o;
    output rty_o;
    input  adr_i;
    input  sel_i;
    input  stb_i;
    input  we_i;
    input  cyc_i;
    input  dat_i;
  endclocking
  // Clock edge alignment
  task clockAlign();
    wait(sync_posedge.triggered);
  endtask
  //
endinterface
