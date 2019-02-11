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

module testbench_top;
  
  // CAN TX/RX interface
  can_txrx_if can_txrx_if_0();
  can_txrx_if can_txrx_if_1();

  // CAN bus.
  can_bus u_can_bus(
    .tx0(can_txrx_if_0.tx),
    .rx0(can_txrx_if_0.rx),
    .fr0(can_txrx_if_0.fr),
    .tx1(can_txrx_if_1.tx),
    .rx1(can_txrx_if_1.rx),
    .fr1(can_txrx_if_1.fr),
    .tx2(),
    .rx2(),
    .fr2(),
    .tx3(),
    .rx3(),
    .fr3(),
    .tx4(),
    .rx4(),
    .fr4(),
    .tx5(),
    .rx5(),
    .fr5(),
    .tx6(),
    .rx6(),
    .fr6(),
    .tx7(),
    .rx7(),
    .fr7(),
    .tx8(),
    .rx8(),
    .fr8(),
    .tx9(),
    .rx9(),
    .fr9()
  );
  // Test
  test_16845 u_test_16845();

endmodule
