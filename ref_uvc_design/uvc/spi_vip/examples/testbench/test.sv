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

import SPI_M::*;
import SPI_S::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit8 packet[$];

program test ();
  initial begin
    //
    packet dataIn, expData, dataOut;
    SPI_s_env spi_s[8];
    SPI_m_env spi_m;
    int devNum, burstSize, msb;
    Packet pkt = new();
    Checker chk = new();
    // Create spi master and 8 slaves
    spi_m    = new(testbench_top.spi_m_if_0);
    spi_s[0] = new(testbench_top.spi_s_if_0);
    spi_s[1] = new(testbench_top.spi_s_if_1);
    spi_s[2] = new(testbench_top.spi_s_if_2);
    spi_s[3] = new(testbench_top.spi_s_if_3);
    spi_s[4] = new(testbench_top.spi_s_if_4);
    spi_s[5] = new(testbench_top.spi_s_if_5);
    spi_s[6] = new(testbench_top.spi_s_if_6);
    spi_s[7] = new(testbench_top.spi_s_if_7);
    // Start master and slave vips
    spi_m.startEnv();
    for (int i = 0; i < 8; i++) begin
      spi_s[i].startEnv();
    end
    for (int mode = 0; mode < 4; mode++) begin
      //
      spi_m.setMode(mode);
      for (int j = 0; j < 8; j++) begin
        spi_s[j].setMode(mode);
      end
      for (int i = 0; i < 100; i++) begin
        burstSize = pkt.genRndNum(1, 16);
        msb = pkt.genRndNum(0, 1);
        spi_m.setConfig(msb, burstSize);
        for (int j = 0; j < 8; j++) begin
          spi_s[j].setConfig(msb, burstSize);
        end
        // Master writes to the slave.
        repeat (10) begin
          devNum = pkt.genRndNum(0, 7);
          pkt.genFullRndPkt(1, 200, burstSize, dataIn);
          $display("Slave Number = %d", devNum);
          $display("Packet Length = %d bytes", dataIn.size());
          spi_m.readWriteData(devNum, dataIn, dataOut);
          spi_s[devNum].getData(dataOut, dataIn.size());
          void'(chk.CheckPkt(dataOut, dataIn));
        end
        // Master reads from the slave.
        repeat (10) begin
          devNum = pkt.genRndNum(0, 7);
          pkt.genFullRndPkt(1, 200, burstSize, dataIn);
          $display("Slave Number = %d", devNum);
          $display("Packet Length = %d bytes", dataIn.size());
          //pkt.PrintPkt("Data In", dataIn);
          spi_s[devNum].putData(dataIn);
          spi_m.readWriteData(devNum, dataIn, dataOut, dataIn.size());
          // Clear dummy data from slave buffer
          spi_s[devNum].getData(expData, dataIn.size());
          void'(chk.CheckPkt(dataOut, dataIn));
        end
      end
      //
    end
    #100
    //
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
