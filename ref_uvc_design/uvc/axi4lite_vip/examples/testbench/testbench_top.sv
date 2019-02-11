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
  assign axi_m_if_0.awready = axi_s_if_0.awready;
  assign axi_m_if_0.wready  = axi_s_if_0.wready;
  assign axi_m_if_0.arready = axi_s_if_0.arready;
  assign axi_m_if_0.rvalid  = axi_s_if_0.rvalid;
  assign axi_m_if_0.bvalid  = axi_s_if_0.bvalid;
  assign axi_m_if_0.rdata   = axi_s_if_0.rdata;
  assign axi_m_if_0.bresp   = axi_s_if_0.bresp;
  assign axi_m_if_0.rresp   = axi_s_if_0.rresp;

  assign axi_s_if_0.awvalid = axi_m_if_0.awvalid;
  assign axi_s_if_0.wvalid  = axi_m_if_0.wvalid;
  assign axi_s_if_0.rready  = axi_m_if_0.rready;
  assign axi_s_if_0.arvalid = axi_m_if_0.arvalid;
  assign axi_s_if_0.bready  = axi_m_if_0.bready;
  assign axi_s_if_0.awaddr  = axi_m_if_0.awaddr;
  assign axi_s_if_0.wdata   = axi_m_if_0.wdata;
  assign axi_s_if_0.wstrb   = axi_m_if_0.wstrb;
  assign axi_s_if_0.araddr  = axi_m_if_0.araddr;
  // AXI master interface
  axi4lite_m_if axi_m_if_0(clk);
  // AXI slave interface
  axi4lite_s_if axi_s_if_0(clk);
  // Test
  test u_test();

endmodule
