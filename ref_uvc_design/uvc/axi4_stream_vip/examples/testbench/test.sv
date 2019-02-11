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

import AXI4STR_M::*;
import AXI4STR_S::*;
import AXI4STR_MONITOR::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [255:0]  bit256;

program test ();
  initial begin
    //
    bit8 dataIn[], expData[], dataOut[], userDataIn[], userDataOut[], userDataExp[];
    int tid, tdest, exp_tid, exp_tdest;
    int trErrors, trExpErrors;
    int itrNum, checkStatus;
    bit256 tdata;
    bit32 tkeep, tstrb;
    int tlast;
    //
    AXI4STR_m_env axi4str_m;
    AXI4STR_s_env axi4str_s;
    AXI4STR_MONITOR_env axi4str_monitor;
    Packet pkt = new();
    Checker chk = new();
    itrNum = 10000;
    // Create AXI4STR master
    axi4str_m    = new("Master", testbench_top.axi4_str_m_if_0, 4, 8);
    // Create AXI4STR slave
    axi4str_s   = new("Slave", testbench_top.axi4_str_s_if_0, 4, 8);
    // Create AXI4STR monitor
    axi4str_monitor = new("AXI4 monitor0", testbench_top.axi4_str_monitor_if_0);
    // Start master and slave vips
    axi4str_m.startEnv();
    axi4str_s.startEnv();
    axi4str_monitor.startEnv();
    repeat (10) @(posedge testbench_top.clk);
    //
    //axi4str_m.setTimeOut(5);
    //axi4str_s.setTimeOut(6);
    axi4str_m.setRandDelay(7, 0, 6, 0);
    axi4str_s.setRandDelay(5, 0, 7, 0);
        
    for(int i = 1; i < itrNum; i++) begin
      tid       = pkt.genRndNum(0, 255);
      tdest     = pkt.genRndNum(0, 255);
      exp_tid   = tid;  
      exp_tdest = tdest;
      pkt.genRndPkt(pkt.genRndNum(i, i), dataIn);
      $display("Length  == %d", dataIn.size());
      //pkt.PrintPkt("Data In", dataIn);
      // Create user data buffer
      pkt.genRndPkt(dataIn.size(), userDataIn);
      axi4str_m.createUserBuf(userDataIn);
      userDataExp = new[userDataIn.size()];
      for(int j = 0; j < userDataIn.size(); j++) begin
        userDataExp[j] = userDataIn[j] & 8'hff;
      end
      axi4str_m.sendData(dataIn, 1, tid, tdest);
      axi4str_m.busIdle($urandom_range(5, 0));
      if($urandom_range(1, 0)) begin
        axi4str_m.waitCommandDone();
      end
      axi4str_s.readData(dataOut);
      axi4str_s.readUserBuf(userDataOut);
      //pkt.PrintPkt("Data Out", dataOut);
      checkStatus = chk.CheckPkt(dataOut, dataIn);
      if(checkStatus == -1) $finish;
      checkStatus = chk.CheckPkt(userDataOut, userDataExp);
      if(checkStatus == -1) $finish;
      axi4str_s.getTID_TDEST(tid, tdest);
      if((tid != exp_tid) || (tdest != exp_tdest)) begin
        chk.CheckRecord(-1);
        $display("exp_tid == %h, tid == %h", exp_tid, tid);
        $display("exp_tdest == %h, tdest == %h", exp_tdest, tdest);
        $finish;
      end else begin
        chk.CheckRecord(1);
      end
    end
    //
    repeat (5) @(posedge testbench_top.clk);
    //
    axi4str_m.printStatus();
    axi4str_s.printStatus();
    axi4str_monitor.printStatus();
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
