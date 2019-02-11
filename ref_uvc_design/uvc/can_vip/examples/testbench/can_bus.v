/*
Copyright (C) 2011 SysWip

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

module can_bus(
  tx0,
  rx0,
  fr0,
  tx1,
  rx1,
  fr1,
  tx2,
  rx2,
  fr2,
  tx3,
  rx3,
  fr3,
  tx4,
  rx4,
  fr4,
  tx5,
  rx5,
  fr5,
  tx6,
  rx6,
  fr6,
  tx7,
  rx7,
  fr7,
  tx8,
  rx8,
  fr8,
  tx9,
  rx9,
  fr9
);
  input  tx0, tx1, tx2, tx3, tx4, tx5, tx6, tx7, tx8, tx9;
  input  fr0, fr1, fr2, fr3, fr4, fr5, fr6, fr7, fr8, fr9;
  output rx0, rx1, rx2, rx3, rx4, rx5, rx6, rx7, rx8, rx9;

  tri1 tx0_i, tx1_i, tx2_i, tx3_i, tx4_i, tx5_i, tx6_i, tx7_i, tx8_i, tx9_i;
  tri1 can_h;
  wire force_recessive;
  tri0 fr0_i, fr1_i, fr2_i, fr3_i, fr4_i, fr5_i, fr6_i, fr7_i, fr8_i, fr9_i;
  
  assign force_recessive = fr0_i|fr1_i|fr2_i|fr3_i|fr4_i|fr5_i|fr6_i|fr7_i|fr8_i|fr9_i;
  
  assign fr0_i = fr0;
  assign fr1_i = fr1;
  assign fr2_i = fr2;
  assign fr3_i = fr3;
  assign fr4_i = fr4;
  assign fr5_i = fr5;
  assign fr6_i = fr6;
  assign fr7_i = fr7;
  assign fr8_i = fr8;
  assign fr9_i = fr9;
  
  assign tx0_i = tx0;
  assign tx1_i = tx1;
  assign tx2_i = tx2;
  assign tx3_i = tx3;
  assign tx4_i = tx4;
  assign tx5_i = tx5;
  assign tx6_i = tx6;
  assign tx7_i = tx7;
  assign tx8_i = tx8;
  assign tx9_i = tx9;

  assign can_h = tx0_i ? 1'bz : 1'b0;
  assign can_h = tx1_i ? 1'bz : 1'b0;
  assign can_h = tx2_i ? 1'bz : 1'b0;
  assign can_h = tx3_i ? 1'bz : 1'b0;
  assign can_h = tx4_i ? 1'bz : 1'b0;
  assign can_h = tx5_i ? 1'bz : 1'b0;
  assign can_h = tx6_i ? 1'bz : 1'b0;
  assign can_h = tx7_i ? 1'bz : 1'b0;
  assign can_h = tx8_i ? 1'bz : 1'b0;
  assign can_h = tx9_i ? 1'bz : 1'b0;

  assign rx0 = can_h|force_recessive;
  assign rx1 = can_h|force_recessive;
  assign rx2 = can_h|force_recessive;
  assign rx3 = can_h|force_recessive;
  assign rx4 = can_h|force_recessive;
  assign rx5 = can_h|force_recessive;
  assign rx6 = can_h|force_recessive;
  assign rx7 = can_h|force_recessive;
  assign rx8 = can_h|force_recessive;
  assign rx9 = can_h|force_recessive;

endmodule
