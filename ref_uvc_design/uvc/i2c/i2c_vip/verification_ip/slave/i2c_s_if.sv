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

interface i2c_s_if(inout tri1 sda);
  // I2C bus signals
  wire   scl;
  // Tri-state buffer control
  logic  sda_oe;
  // Tri-state buffers
  assign sda = sda_oe ? 1'bz : 1'b0;

endinterface
