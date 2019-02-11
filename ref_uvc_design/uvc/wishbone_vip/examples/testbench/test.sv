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

import WSHB_M::*;
import WSHB_S::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit8 packet[$];

program test ();
  initial begin
    //
    packet dataIn, expData, dataOut;
    int addr;
    int trErrors, trExpErrors;
    int itrNum;
    //
    WSHB_m_env wshb_m;
    WSHB_s_env wshb_s;
    Packet pkt = new();
    Checker chk = new();
    itrNum = 1000;
    // Create WSHB master
    wshb_m    = new(testbench_top.wshb_m_if_0, 8);
    // Create WSHB slave
    wshb_s    = new(testbench_top.wshb_s_if_0, 8);
    // Start master and slave vips
    wshb_m.startEnv();
    wshb_s.startEnv();
    //
    wshb_m.setRndDelay(0, 10, 0, 10);
    wshb_m.setTimeOut(0, 3);
    wshb_s.setRndDelay(0, 10);
    wshb_s.setRespMode(0, 16, 0, 3);
    wshb_s.setMemCleanMode(3);
    trExpErrors = 0;
    // Wait several clocks to be sure that DUT is ready
    repeat (10) @(posedge testbench_top.clk);
    // Master read/write
    repeat (itrNum) begin
      addr = pkt.genRndNum(0, 100);
      pkt.genRndPkt(pkt.genRndNum(1, 500), dataIn);
      $display("address == %h", addr);
      $display("Length  == %d", dataIn.size());
      wshb_m.writeData(addr,dataIn );
      wshb_m.busIdle(pkt.genRndNum(0, 2));
      wshb_m.readData(addr, dataOut, dataIn.size());
      wshb_m.busIdle(pkt.genRndNum(0, 2));
      //pkt.PrintPkt("Data Out", dataOut);
      chk.CheckPkt(dataOut, dataIn);
    end
    // Master write test read
    repeat (itrNum) begin
      addr = pkt.genRndNum(0, 100);
      pkt.genRndPkt(pkt.genRndNum(1, 500), dataIn);
      $display("address == %h", addr);
      $display("Length  == %d", dataIn.size());
      wshb_m.writeData(addr,dataIn );
      wshb_m.waitCommandDone();
      wshb_s.getData(addr, dataOut, dataIn.size());
      chk.CheckPkt(dataOut, dataIn);
    end
    // Master read test write
    repeat (itrNum) begin
      addr = pkt.genRndNum(0, 100);
      pkt.genRndPkt(pkt.genRndNum(1, 500), dataIn);
      $display("address == %h", addr);
      $display("Length  == %d", dataIn.size());
      wshb_s.putData(addr,dataIn );
      wshb_m.readData(addr, dataOut, dataIn.size());
      chk.CheckPkt(dataOut, dataIn);
    end
    //Negative tests. Testing Slave error generation
    repeat (5) @testbench_top.wshb_m_if_0.cb;
    wshb_s.setRespMode(0, 0, 1, 0);
    repeat (100) begin
      addr = pkt.genRndNum(0, 20);
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      $display("address == %h", addr);
      $display("Length  == %d", dataIn.size());
      wshb_m.writeData(addr,dataIn );
      wshb_m.readData(addr, dataOut, dataIn.size());
      if(addr[31:3] != 0) begin
        chk.CheckPkt(dataOut, dataIn);
      end else begin
        trExpErrors+=2;
      end 
    end
    //
    repeat (5) @testbench_top.wshb_m_if_0.cb;
    //
    trErrors = wshb_m.printStatus();
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    if (trErrors == trExpErrors) begin
      $display("-Transactions have 0 unexpected TimeOut or Slave Errors-");
    end else begin
      $display("--Transactions have unexpected TimeOut or Slave Errors--");
      $display("Expected  error amount is %d", trExpErrors);
      $display("Generated error amount is %d", trErrors);
    end
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
