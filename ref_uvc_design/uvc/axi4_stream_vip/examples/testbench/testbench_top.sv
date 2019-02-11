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

module testbench_top;
  // Clock generator
  bit clk;
  initial begin
    forever #5 clk = ~clk;
  end
  //
  assign axi4_str_m_if_0.tready         = axi4_str_s_if_0.tready;
  assign axi4_str_s_if_0.tvalid         = axi4_str_m_if_0.tvalid;
  assign axi4_str_s_if_0.tdata          = axi4_str_m_if_0.tdata;
  assign axi4_str_s_if_0.tlast          = axi4_str_m_if_0.tlast;
  assign axi4_str_s_if_0.tkeep          = axi4_str_m_if_0.tkeep;
  assign axi4_str_s_if_0.tstrb          = axi4_str_m_if_0.tstrb;
  assign axi4_str_s_if_0.tuser          = axi4_str_m_if_0.tuser;
  assign axi4_str_s_if_0.tid            = axi4_str_m_if_0.tid;
  assign axi4_str_s_if_0.tdest          = axi4_str_m_if_0.tdest;
  // AXI4 stream master(source) interface
  axi4_str_m_if axi4_str_m_if_0(clk);
  // AXI4 stream slave(sink) interface
  axi4_str_s_if axi4_str_s_if_0(clk);
  // AXI4 stream Monitor interface
  axi4_str_monitor_if axi4_str_monitor_if_0(clk);
  // Test
  test u_test();

endmodule
