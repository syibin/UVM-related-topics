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
  //Slave 0
  assign spi_s_if_0.sclk = spi_m_if_0.sclk;
  assign spi_s_if_0.ss   = spi_m_if_0.ss[0];
  assign spi_s_if_0.mosi = spi_m_if_0.mosi;
  //Slave 1
  assign spi_s_if_1.sclk = spi_m_if_0.sclk;
  assign spi_s_if_1.ss   = spi_m_if_0.ss[1];
  assign spi_s_if_1.mosi = spi_m_if_0.mosi;
  //Slave 2
  assign spi_s_if_2.sclk = spi_m_if_0.sclk;
  assign spi_s_if_2.ss   = spi_m_if_0.ss[2];
  assign spi_s_if_2.mosi = spi_m_if_0.mosi;
  //Slave 3
  assign spi_s_if_3.sclk = spi_m_if_0.sclk;
  assign spi_s_if_3.ss   = spi_m_if_0.ss[3];
  assign spi_s_if_3.mosi = spi_m_if_0.mosi;
  //Slave 4
  assign spi_s_if_4.sclk = spi_m_if_0.sclk;
  assign spi_s_if_4.ss   = spi_m_if_0.ss[4];
  assign spi_s_if_4.mosi = spi_m_if_0.mosi;
  //Slave 5
  assign spi_s_if_5.sclk = spi_m_if_0.sclk;
  assign spi_s_if_5.ss   = spi_m_if_0.ss[5];
  assign spi_s_if_5.mosi = spi_m_if_0.mosi;
  //Slave 6
  assign spi_s_if_6.sclk = spi_m_if_0.sclk;
  assign spi_s_if_6.ss   = spi_m_if_0.ss[6];
  assign spi_s_if_6.mosi = spi_m_if_0.mosi;
  //Slave 7
  assign spi_s_if_7.sclk = spi_m_if_0.sclk;
  assign spi_s_if_7.ss   = spi_m_if_0.ss[7];
  assign spi_s_if_7.mosi = spi_m_if_0.mosi;
  // Input MUX
  assign spi_m_if_0.miso = (~spi_m_if_0.ss[0]) ? spi_s_if_0.miso :
                           (~spi_m_if_0.ss[1]) ? spi_s_if_1.miso :
                           (~spi_m_if_0.ss[2]) ? spi_s_if_2.miso :
                           (~spi_m_if_0.ss[3]) ? spi_s_if_3.miso :
                           (~spi_m_if_0.ss[4]) ? spi_s_if_4.miso :
                           (~spi_m_if_0.ss[5]) ? spi_s_if_5.miso :
                           (~spi_m_if_0.ss[6]) ? spi_s_if_6.miso :
                                                 spi_s_if_7.miso;
  // SPI master interface
  spi_m_if spi_m_if_0();
  // SPI slave interfaces
  spi_s_if spi_s_if_0();
  spi_s_if spi_s_if_1();
  spi_s_if spi_s_if_2();
  spi_s_if spi_s_if_3();
  spi_s_if spi_s_if_4();
  spi_s_if spi_s_if_5();
  spi_s_if spi_s_if_6();
  spi_s_if spi_s_if_7();
  // Test
  test u_test();

endmodule
