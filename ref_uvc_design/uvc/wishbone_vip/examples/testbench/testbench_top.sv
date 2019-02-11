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

module testbench_top;
  // Clock generator
  bit clk;
  initial begin
    forever #5 clk = ~clk;
  end
  //
  assign wshb_m_if_0.dat_i = wshb_s_if_0.dat_o;
  assign wshb_m_if_0.ack_i = wshb_s_if_0.ack_o;
  assign wshb_m_if_0.err_i = wshb_s_if_0.err_o;
  assign wshb_m_if_0.rty_i = wshb_s_if_0.rty_o;
  //
  assign wshb_s_if_0.adr_i = wshb_m_if_0.adr_o;
  assign wshb_s_if_0.dat_i = wshb_m_if_0.dat_o;
  assign wshb_s_if_0.cyc_i = wshb_m_if_0.cyc_o;
  assign wshb_s_if_0.sel_i = wshb_m_if_0.sel_o;
  assign wshb_s_if_0.stb_i = wshb_m_if_0.stb_o;
  assign wshb_s_if_0.we_i  = wshb_m_if_0.we_o;
  // Wishbone master interface
  wshb_m_if wshb_m_if_0(clk);
  // Wishbone slave interface
  wshb_s_if wshb_s_if_0(clk);
  // Test
  test u_test();

endmodule
