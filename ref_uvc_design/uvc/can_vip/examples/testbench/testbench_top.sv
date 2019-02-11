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
  can_txrx_if can_txrx_if_2();
  can_txrx_if can_txrx_if_3();
  can_txrx_if can_txrx_if_4();
  // CAN bus.
    can_bus u_can_bus(
    .tx0(can_txrx_if_0.tx),
    .rx0(can_txrx_if_0.rx),
    .fr0(can_txrx_if_0.fr),
    .tx1(can_txrx_if_1.tx),
    .rx1(can_txrx_if_1.rx),
    .fr1(can_txrx_if_1.fr),
    .tx2(can_txrx_if_2.tx),
    .rx2(can_txrx_if_2.rx),
    .fr2(can_txrx_if_2.fr),
    .tx3(can_txrx_if_3.tx),
    .rx3(can_txrx_if_3.rx),
    .fr3(can_txrx_if_3.fr),
    .tx4(can_txrx_if_4.tx),
    .rx4(can_txrx_if_4.rx),
    .fr4(can_txrx_if_4.fr),
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
  test u_test();

endmodule
