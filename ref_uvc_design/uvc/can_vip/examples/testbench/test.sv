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

import CAN_TXRX::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit8 packet[$];

program test ();
  initial begin
    int unsigned rdPtr, address;
    bit8 dataIn[$], wbDataIn[$], dataOut[], expPktTmp[];
    int loopNum, dInLen, numPoints;
    int unsigned rdPtrArr[$];
    int unsigned expData[$];
    string frameFormat[2];
    int identifierTemp, identifier11[5], identifier18[5], ide[5], identEq, txPointSel, rxPointSel;
    int identifierPre[5], identifierTemp1, indx, indxBuff[5], identifierTmp1[$];
    int expPkt[6][9];
    int identifier[5];
    //
    CAN_txrx_env can_txrx[5];
    Packet pkt = new();
    Checker chk = new();
    // Create CAN interface
    can_txrx[0]    = new(testbench_top.can_txrx_if_0, "CAN_DEV0");
    can_txrx[1]    = new(testbench_top.can_txrx_if_1, "CAN_DEV1");
    can_txrx[2]    = new(testbench_top.can_txrx_if_2, "CAN_DEV2");
    can_txrx[3]    = new(testbench_top.can_txrx_if_3, "CAN_DEV3");
    can_txrx[4]    = new(testbench_top.can_txrx_if_4, "CAN_DEV4");
    // Start CAN vips
    can_txrx[0].startEnv();
    can_txrx[1].startEnv();
    can_txrx[2].startEnv();
    can_txrx[3].startEnv();
    can_txrx[4].startEnv();
    #10us

    /************************** Full Random test *****************************/
    $display("Full random test");
    numPoints = 5;
    // Init CAN points.
    for(int i = 0; i < numPoints; i++) begin
      can_txrx[i].setDebugMode(0);
      can_txrx[i].configReceiver(2000us, 0, 0);
      can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
      can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
    end
    repeat(1000) begin
      for(int i = 0; i < numPoints; i++) begin
        // Set random but unique identifier for each CAN point
        do begin
          identifier[i] = pkt.genRndNum(0, {30{1'b1}});
          identifierTemp = identifier[i];
          for(int j = 0; j < i; j++) begin
            identifierTemp1 = identifier[j];
            if((identifier[j] == identifier[i]) || (identifierTemp[29] == 1'b0) && (identifierTemp1[29] == 1'b0) &&
                (identifierTemp[28:18] == identifierTemp[28:18])) begin
              identEq = 1;
              break;
            end
            identEq = 0;
          end
        end while(identEq == 1);
      end
      // Sort identifiers by IDs
      for(int i = 0; i < numPoints; i++) begin
        identifierTemp  = identifier[i];
        identifier11[i] = identifierTemp[28:18];
        identifier18[i] = identifierTemp[17:0];
        ide[i]          = identifierTemp[29];
      end
      for(int j = 0; j < numPoints; j++) begin
        identifierTmp1 = identifier.min();
        identifierTemp = identifierTmp1[0]; 
        identifierTmp1  = identifier.find_index with ( item == identifierTemp );
        identifierTemp = identifierTmp1[0];
        identifier[identifierTemp] = 32'h7fffffff;
        indxBuff[j] = identifierTemp;
      end

      for(int i = 0; i < numPoints; i++) begin
        $display("identifier11[%0d] = 0x%0h", i, identifier11[i]);
        $display("identifier18[%0d] = 0x%0h", i, identifier18[i]);
        $display("ide[%0d] = %0d", i, ide[i]);
      end
      
      repeat(5) begin
        for(int pointSel = 0; pointSel < numPoints; pointSel++) begin
          dInLen = pkt.genRndNum(1, 8);
          pkt.genRndPkt(dInLen, dataIn);
          pkt.PrintPkt("In data: ", dataIn);
          can_txrx[pointSel].txDataFrame(identifier11[pointSel], identifier18[pointSel], ide[pointSel], dataIn);
          for(int i = 0; i < dataIn.size(); i++) begin
            expPkt[pointSel][i] = dataIn[i];
          end
          expPkt[pointSel][8] = dataIn.size();
        end
        for(int pointSel = 0; pointSel < 5; pointSel++) begin
          for(int j = 0; j < 5; j++) begin
            txPointSel = indxBuff[pointSel];
            if(txPointSel != j) begin
              can_txrx[j].getRxDataFrame(identifier11[txPointSel], identifier18[txPointSel], ide[txPointSel], dataOut);
              expPktTmp = new[expPkt[txPointSel][8]];
              for(int i = 0; i < expPktTmp.size(); i++) begin
                expPktTmp[i] = expPkt[txPointSel][i];
              end
              if(expPktTmp.size() != 0) begin
                if(chk.CheckPkt(dataOut, expPktTmp) == -1) $finish;
              end
            end
          end
        end
      end
    end
    /************************ Full Random test done ***************************/
    // Test done report status
    for(int i = 0; i < 5; i++) begin
      can_txrx[i].envDone();
    end
    #1000us
    $display("-----------------------Test Done------------------------");
    $display("------------------Printing Test Status------------------");
    $display("--------------------------------------------------------");
    chk.printFullStatus();
    $display("--------------------------------------------------------");
    //
  end
endprogram
