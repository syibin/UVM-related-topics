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
  //
  wire sda;
  //
  assign i2c_s_if_0.scl     = i2c_m_if_0.scl;
  assign i2c_s_if_1.scl     = i2c_m_if_0.scl;
  assign i2c_s_if_2.scl     = i2c_m_if_0.scl;
  // I2C master interface
  i2c_m_if i2c_m_if_0(.sda(sda));
  // I2C slave interface
  i2c_s_if i2c_s_if_0(.sda(sda));
  i2c_s_if i2c_s_if_1(.sda(sda));
  i2c_s_if i2c_s_if_2(.sda(sda));
  // Test
  test u_test(.i2c_ifc_m(i2c_m_if_0),
              .i2c_ifc_s_0(i2c_s_if_0),
              .i2c_ifc_s_1(i2c_s_if_1),
              .i2c_ifc_s_2(i2c_s_if_2));

endmodule
