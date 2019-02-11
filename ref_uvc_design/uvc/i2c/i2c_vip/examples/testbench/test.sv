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

import I2C_M::*;
import I2C_S::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit8 packet[$];

program test (i2c_m_if i2c_ifc_m, i2c_s_if i2c_ifc_s_0, i2c_ifc_s_1, i2c_ifc_s_2);
  initial begin
    //
    packet dataIn, expData, dataOut;
    bit8 address;
    int stop, dataSize[3];
    int trErrors = 0;
    int expError = 0;
    Packet pkt = new();
    Checker chk = new();
    // Create i2c master and 3 slaves
    I2C_m_env i2c_m = new(i2c_ifc_m, "Standart");
    I2C_s_env i2c_s_0   = new(i2c_ifc_s_0, "Standart", 55);
    I2C_s_env i2c_s_1   = new(i2c_ifc_s_1, "Standart", 56);
    I2C_s_env i2c_s_2   = new(i2c_ifc_s_2, "Standart", 57);
    // Start master and slave vip
    i2c_m.startEnv();
    i2c_s_0.startEnv();
    i2c_s_1.startEnv();
    i2c_s_2.startEnv();
    //
    i2c_m.setRndDelay(10, 1);
    repeat (1000) begin
      expData = {};
      for (int i = 0; i < 3; i++) begin
        pkt.genRndPkt(pkt.genRndNum(1, 255), dataIn);
        address = 55 + i;
        expData = {expData, dataIn};
        dataSize[i] = dataIn.size();
        $display ("Slave address is 0x%h", address);
        $display ("Data Length is %d bytes", dataIn.size());
        // Select stop or repeat start.
        stop = pkt.genRndNum(0, 1);
        // Write data to slave
        i2c_m.writeData(address, dataIn, stop);
      end
      for (int i = 0; i < 3; i++) begin
        address = 55 + i;
        stop = pkt.genRndNum(0, 1);
        // Read data from slave
        i2c_m.readData(address, dataOut, dataSize[i], stop);
        void'(chk.CheckPkt(dataOut, expData[0:(dataSize[i]-1)]));
        expData = expData[dataSize[i]:$];
      end
    end
    // Writing memory and reading by master
    repeat (500) begin
      pkt.genRndPkt(pkt.genRndNum(1, 255), dataIn);
      i2c_s_0.putData(0, dataIn);
      $display ("Data Length is %d bytes", dataIn.size());
      address = 55;
      stop = pkt.genRndNum(0, 1);
      // Read data from slave
      i2c_m.readData(address, dataOut, dataIn.size(), stop);
      void'(chk.CheckPkt(dataOut, dataIn));
    end
    // Reading memory written by master
    i2c_s_0.setPollTimeOut(1s);
    repeat (200) begin
      pkt.genRndPkt(pkt.genRndNum(1, 255), dataIn);
      address = 55;
      stop = pkt.genRndNum(0, 1);
      $display ("Slave address is 0x%h", address);
      $display ("Data Length is %d bytes", dataIn.size());
      i2c_m.writeData(address, dataIn, stop);
      i2c_s_0.putWord((dataIn.size()-1), (~dataIn[$]));
      i2c_s_0.pollWord((dataIn.size()-1), dataIn[$]);
      i2c_s_0.getData(0, dataOut, dataIn.size());
      void'(chk.CheckPkt(dataOut, dataIn));
    end
    //Testing memory overflow
    i2c_s_1.setAckMode(1);
    pkt.genRndPkt(257, dataIn);
    address = 56;
    stop = pkt.genRndNum(0, 1);
    $display ("Slave address is 0x%h", address);
    $display ("Data Length is %d bytes", dataIn.size());
    i2c_m.writeData(address, dataIn, stop);
    i2c_m.waitCommandDone();
    i2c_s_1.getData(0, dataOut, (dataIn.size()-1));
    pkt.PrintPkt("Data In", dataIn);
    pkt.PrintPkt("Data Out",dataOut);
    void'(chk.CheckPkt(dataOut, dataIn[0:$-1]));
    //
    repeat (100) begin
      expData = {};
      for (int i = 0; i < 3; i++) begin
        pkt.genRndPkt(pkt.genRndNum(1, 255), dataIn);
        address = 55 + i;
        expData = {expData, dataIn};
        dataSize[i] = dataIn.size();
        $display ("Slave address is 0x%h", address);
        $display ("Data Length is %d bytes", dataIn.size());
        // Select stop or repeat start.
        stop = pkt.genRndNum(0, 1);
        // Write data to slave
        i2c_m.writeData(address, dataIn, stop);
      end
      for (int i = 0; i < 3; i++) begin
        address = 55 + i;
        stop = pkt.genRndNum(0, 1);
        // Read data from slave
        i2c_m.readData(address, dataOut, dataSize[i], stop);
        void'(chk.CheckPkt(dataOut, expData[0:(dataSize[i]-1)]));
        expData = expData[dataSize[i]:$];
      end
    end
    //
    #100
    //
    trErrors = i2c_m.printStatus();
    expError = 1;
    void'(i2c_s_0.printStatus());
    void'(i2c_s_1.printStatus());
    void'(i2c_s_2.printStatus());
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    if (trErrors == expError) begin
      $display("--Transactions have 0 unexpected Not acknoledge Errors--");
    end else begin
      $display("---Transactions have unexpected Not acknoledge Errors---");
      $display("Expected  error amount is %d", expError);
      $display("Generated error amount is %d", trErrors);
    end
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
