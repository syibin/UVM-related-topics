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

import AXI4LITE_M::*;
import AXI4LITE_S::*;
import PACKET::*;
typedef bit [7:0]    bit8;

program test ();
  initial begin
    bit8 dataIn[], dataOut[], wrRespOut[], wrRespExp[], rdRespOut[], rdRespExp[];
    int unsigned rdPtr, address, wrRespPtr;
    int loopNum;
    //
    AXI4Lite_m_env axi_m;
    AXI4Lite_s_env axi_s;
    Packet pkt = new();
    Checker chk = new();
    // Create AXI master
    axi_m    = new("AXI master", testbench_top.axi_m_if_0, 4);
    // Create AXI slave
    axi_s    = new("AXI slave", testbench_top.axi_s_if_0, 4);
    // Start master and slave vips
    axi_m.startEnv();
    axi_s.startEnv();
    axi_m.setRndDelay(0, 100, 0, 10);
    axi_m.setTimeOut(10000, 100000);
    axi_s.setRndDelay(0, 30);
    axi_s.setMemCleanMode(3);
    axi_m.respReportMode(1);
    // Wait several clocks
    repeat (10) @(posedge testbench_top.clk);
    loopNum = 10000;
    // Master read/write. Wait for write response.
    repeat(loopNum) begin
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      pkt.PrintPkt("Data In", dataIn);
      address = pkt.genRndNum(0, 32'hffffffff);
      $display("Data Length is %d bytes", dataIn.size());
      $display("Address is %h", address);
      axi_m.writeData(wrRespPtr, address, dataIn);
      axi_m.getWrResp(wrRespPtr, wrRespOut);
      axi_m.readData(address, dataIn.size(), rdPtr);
      axi_m.getData(rdPtr, dataOut, rdRespOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check response buffers
      pkt.genConstPkt(wrRespOut.size(), 0, wrRespExp);
      if(chk.CheckPkt(wrRespOut, wrRespExp) == -1) $finish;
    end
    // Master read/write. Polling.
    repeat(loopNum) begin
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      address = pkt.genRndNum(0, 32'hffffffff);
      $display("Data Length is %d bytes", dataIn.size());
      $display("Address is %h", address);
      axi_m.writeData(wrRespPtr, address, dataIn);
      // Always disable memory clean if poll is used
      axi_s.setMemCleanMode(0);
      axi_m.pollData(address, dataIn);
      axi_s.setMemCleanMode(3);
      if(chk.CheckPkt(dataIn, dataIn) == -1) $finish;
    end
    // Master write slave read. Wait for write response.
    repeat(loopNum) begin
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      address = pkt.genRndNum(0, 32'hffffffff);
      $display("Data Length is %d bytes", dataIn.size());
      $display("Address is %h", address);
      axi_m.writeData(wrRespPtr, address, dataIn);
      axi_m.getWrResp(wrRespPtr, wrRespOut);
      axi_s.getData(address, dataOut, dataIn.size());
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
    end
    // Master write slave read. Polling.
    repeat(loopNum) begin
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      address = pkt.genRndNum(0, 32'hffffffff);
      $display("Data Length is %d bytes", dataIn.size());
      $display("Address is %h", address);
      axi_m.writeData(wrRespPtr, address, dataIn);
      axi_s.pollData(address, dataIn, 10000);
      if(chk.CheckPkt(dataIn, dataIn) == -1) $finish;
    end
    // Slave write master read.
    repeat(loopNum) begin
      pkt.genRndPkt(pkt.genRndNum(1, 50), dataIn);
      address = pkt.genRndNum(0, 32'hffffffff);
      $display("Data Length is %d bytes", dataIn.size());
      $display("Address is %h", address);
      axi_s.putData(address, dataIn);
      axi_m.readData(address, dataIn.size(), rdPtr);
      axi_m.getData(rdPtr, dataOut, rdRespOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
    end
    // Set wrong write/read response
    axi_s.setWrResp(32'h00ffed00, 3);
    axi_s.setRdResp(32'hffff0000, 1);
    // Testing wrong read response
    pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
    address = 32'hffff0000;
    rdRespExp = new[1];
    rdRespExp[0] = 8'd1;
    $display("Data Length is %d bytes", dataIn.size());
    $display("Address is %h", address);
    axi_s.putData(address, dataIn);
    axi_m.readData(address, dataIn.size(), rdPtr);
    axi_m.getData(rdPtr, dataOut, rdRespOut);
    if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
    // Check read response buffer
    if(chk.CheckPkt(rdRespOut, rdRespExp) == -1) $finish;
    // Testing wrong write response
    pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
    address = 32'h00ffed00;
    wrRespExp = new[1];
    wrRespExp[0] = 8'd3;
    $display("Data Length is %d bytes", dataIn.size());
    $display("Address is %h", address);
    axi_m.writeData(wrRespPtr, address, dataIn);
    axi_m.getWrResp(wrRespPtr, wrRespOut);
    axi_s.getData(address, dataOut, dataIn.size());
    if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
    // Check read response buffer
    if(chk.CheckPkt(wrRespOut, wrRespExp) == -1) $finish;
    // Wait several clocks
    repeat (10) @testbench_top.axi_m_if_0.cb;
    //
    $display("--------------------------------------------------------");
    axi_m.printStatus();
    axi_s.printStatus();
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
