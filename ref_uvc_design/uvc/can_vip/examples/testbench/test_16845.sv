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
`define test_7_1_1
`define test_7_1_5
`define test_7_1_8
`define test_7_1_10
`define test_7_1_12
`define test_7_2_1
`define test_7_2_2
`define test_7_2_4
`define test_7_2_6
`define test_7_3_2
`define test_7_3_4
`define test_7_4_1
`define test_7_4_3
`define test_7_5_2
`define test_7_5_3
`define test_7_5_4
`define test_7_5_6
`define test_7_6_1
`define test_7_6_2
`define test_7_6_3
`define test_7_6_4
`define test_7_6_5
`define test_7_6_6
`define test_7_6_7
`define test_7_6_10
`define test_7_6_12
`define test_7_6_15
`define test_7_6_16
`define test_8_1_3
`define test_8_1_4
`define test_8_2_1
`define test_8_5_1
`define test_8_5_3
`define test_8_6_1
`define test_8_6_3
`define test_8_6_4
`define test_8_6_8
`define test_8_6_9
`define test_8_6_14

`timescale 1ns/10ps

import CAN_TXRX::*;
import PACKET::*;
typedef bit [7:0]    bit8;
typedef bit8 packet[$];

program test_16845;
  initial begin
    bit8 dataIn[$], expData[$], dataOut[], dataInEmpty[$];
    int dInLen, numPoints;
    bit[18:0] paramTx;
    int identifier11[], identifier18[], identifier29[], ide[], ctrlFied[];
    int expPkt[];
    int temp, temp1, identifier_0, identifier_1;
    bit [511:0] debugData;
    //
    CAN_txrx_env can_txrx[5];
    Packet pkt = new();
    Checker chk = new();
    // Create CAN interface
    can_txrx[0]    = new(testbench_top.can_txrx_if_0, "CAN_DEV0");
    can_txrx[1]    = new(testbench_top.can_txrx_if_1, "CAN_DEV1");
    // Start CAN and Wishbone vips
    can_txrx[0].startEnv();
    can_txrx[1].startEnv();
    numPoints = 2;
    #10us
    //////////////////////////////////////////////////////////////////
    //// 7. Received Frame Type
    //////////////////////////////////////////////////////////////////
    /******* 7.1.1 & 7.1.2 Identifier and number of data. ***********/
    /********************* Extended and standard formats. ***********/                      
    `ifdef test_7_1_1
      $display("~~~~~~~~~~~~~~~TEST 7_1_1~~~~~~~~~~~~~~~");
      // Init CAN points.      
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configTransmitter(0);
      end      
      identifier11 = new[6];
      identifier11 = '{'h0, 'h7ef, 'h7f0, 'h7ff, 'h2aa, 'h555};
      identifier29 = new[6];
      identifier29 = '{'h0, 'h1fffffff, 'h2aaaaaaa, 'h15555555, 'h1fff0fff, 'h0000f000};
      for(int ide = 0; ide < 2; ide++) begin
        for(int iden = 0; iden < 6; iden++) begin
          for(int dInLen = 0; dInLen < 9; dInLen++) begin
            pkt.PrintPkt("In data: ", dataIn);
            pkt.genRndPkt(dInLen, dataIn);
            if(ide == 1) begin
              can_txrx[0].txDataFrame(identifier29[iden], (identifier29[iden]>>11), ide, dataIn);
              can_txrx[1].getRxDataFrame(identifier29[iden], (identifier29[iden]>>11), ide, dataOut);
            end else begin
              can_txrx[0].txDataFrame(identifier11[iden], 0, ide, dataIn); 
              can_txrx[1].getRxDataFrame(identifier11[iden], 0, 0, dataOut);
            end  
            pkt.PrintPkt("Out data: ", dataOut);
            if(dataOut.size() != 0) begin
              if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
            end
            // Check error buffers 
            if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0) == -1) $finish;
            if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0) == -1) $finish;      
          end
        end
      end  
    `endif //test_7.1.1
    /******* 7.1.5 & 7.1.6 Acceptance of non nominal IDE&R0 in standard format.***********/
    /********************* Acceptance of non nominal SRR&R0&R1 in extended format. ***********/                      
    `ifdef test_7_1_5
      $display("~~~~~~~~~~~~~~~TEST 7_1_5~~~~~~~~~~~~~~~");
      // Init CAN points.      
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configTransmitter(0);
      end    
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};
      identifier18 = new[1];
      identifier18 = '{($random()&{18{1'b1}})};
      for(int ide = 0; ide < 2; ide++) begin
        for(int r0 = 0; r0 < 2; r0++) begin
          for(int r1 = 0; r1 < 2; r1++) begin
            for(int srr = 0; srr < 2; srr++) begin
              dInLen = pkt.genRndNum(1, 8);
              pkt.genRndPkt(dInLen, dataIn);
              pkt.PrintPkt("In data: ", dataIn);
                            //StuffErr EOF  CRCdel CRCerr      R1/R0        SRR   DLC
              paramTx =    {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,    {r1[0], r0[0]}, srr[0], 4'd0};
              can_txrx[0].txDataFrame(identifier11[0], identifier18[0], ide, dataIn, paramTx);
              can_txrx[1].getRxDataFrame(identifier11[0], identifier18[0], ide, dataOut);
              pkt.PrintPkt("Out data: ", dataOut);
              if(dataOut.size() != 0) begin
                if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
              end
              // Check error buffers 
              if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0) == -1) $finish;
              if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0) == -1) $finish;
            end
          end  
        end    
      end   
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0) == -1) $finish;
      // In the test the SRR is dominant 4 times, R1 is recessive 4 times
      // R0 is recessive 8 times
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 16) == -1) $finish;                 
    `endif //test_7.1.5
    /******* 7.1.8 & 7.1.9 DLC greater than 8.***********/
    /********************* Absent bus idle. ***********/                      
    `ifdef test_7_1_8
      $display("~~~~~~~~~~~~~~~TEST 7_1_8~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      for(int itrmss = 0; itrmss < 2; itrmss++) begin
        // itrmss = 0, start after 3rd clock of intermission
        // itrmss = 1, start at 3rd clock of intermission
        can_txrx[0].configTransmitter(itrmss);
        expData.delete(); 
        identifier11 = '{($random()&{11{1'b1}})};  
        for(int dlc = 9; dlc < 16; dlc++) begin
          pkt.genRndPkt(8, dataIn);
          pkt.PrintPkt("In data: ", dataIn);
                       //StuffErr EOF  CRCdel CRCerr     R1/R0  SRR   DLC
          paramTx =    {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,    2'b00, 1'b1, dlc[3:0]};
          can_txrx[0].txDataFrame(identifier11[0], identifier18[0], 0, dataIn, paramTx);
          for(int i = 0; i < 8; i++) begin
            expData.push_back(dataIn[i]);
          end
        end
        for(int dlc = 9; dlc < 16; dlc++) begin
          can_txrx[1].getRxDataFrame(identifier11[0], identifier18[0], 0, dataOut);
          pkt.PrintPkt("Out data: ", dataOut);
          if(chk.CheckPkt(dataOut, expData[0:7]) == -1) $finish;
          expData = expData[8:$];
        end      
      end          
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Received dlc > 8. 2*7 times.
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 14, "Check info buffer") == -1) $finish;
    `endif //test_7.1.8
    /******* 7.1.10 & 7.1.11 Stuff acceptance test. Standard frame.***********/
    /*********************** Extended frame. ***********/                      
    `ifdef test_7_1_10
      $display("~~~~~~~~~~~~~~~TEST 7_1_10~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(500us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end
      identifier11 = new[10];
      ctrlFied     = new[10];
      identifier18 = new[10];
      identifier18 = '{'h30f0f, 'h0f0f0, 'h31717, 'h00ff0, 'h0, 'h540f, 'h15557, 0, 0, 0};
      identifier11 = '{'h78, 'h41F, 'h707, 'h360, 'h730, 'h47F, 'h758, 'h777, 'h7ef, 'h3ea};    
      ctrlFied     = '{8, 1, 'h1f, 'h10, 'h10, 1, 0, 1, 2, 'h1f};
      dataIn = '{1, 'he1, 'he1, 'he1, 'he1, 'he1, 'he1, 'he1, 0, 
                 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'h1f, 'h1f};
      dataInEmpty.delete();           
      for(int ide = 0; ide < 2; ide++) begin
        for(int iden = 0; iden < identifier11.size(); iden++) begin
          temp = (ctrlFied[iden]>>4);
          temp1 = ctrlFied[iden]&15;
                     //StuffErr EOF  CRCdel CRCerr     R1/R0       SRR   DLC
          paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  temp[1:0],1'b1, 4'd0};
          if(temp1 > 8) begin
            paramTx =    {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  temp[1:0], 1'b1, temp1[3:0]};
            if((iden == 9) || (iden == 6)&&(ide == 1)) begin 
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end  
            else begin
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataIn[0:7], paramTx);
              pkt.PrintPkt("In data: ", dataIn[0:7]);
              expData = dataIn[0:7];
              dataIn = dataIn[8:$];
            end  
          end else if(temp1 == 0) begin
            if((iden == 5)&&(ide == 1)) begin 
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end  
            else begin 
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataInEmpty, paramTx);
              pkt.PrintPkt("In data: ", dataInEmpty);
              expData.delete();
            end  
          end else begin
            if((iden == 8) || (iden == 5)&&(ide == 1)) begin
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end else begin
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataIn[0:(temp1-1)], paramTx);
              expData = dataIn[0:(temp1-1)];
              pkt.PrintPkt("In data: ", dataIn[0:(temp1-1)]);
              dataIn = dataIn[temp1:$];
            end  
          end
          if((iden < 8)&&(ide == 0) || (iden < 5)) begin
            can_txrx[1].getRxDataFrame(identifier11[iden], identifier18[iden], ide, dataOut);
            if(expData.size() != 0) begin
              if(chk.CheckPkt(dataOut, expData) == -1) $finish;
            end
          end else begin
            can_txrx[0].getRxDataFrame(identifier11[iden], identifier18[iden], ide, dataOut);
            if(expData.size() != 0) begin
              if(chk.CheckPkt(dataOut, expData) == -1) $finish;
            end
          end         
        end
        identifier11 = new[7];
        identifier11 = '{'h1f0, 'h1f0, 'h78, 'h78, 'h7ee, 'h2f, 'h557};
        ctrlFied     = '{8, 1, 'h1f, 'h3c, 'h1, 'h20, 'h3f};
        dataIn = '{'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 0,  
                 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'h1f, 'hf, 'he0, 'hf0, 'h7f,
                 'he0, 'hff, 'h20, 'ha0};
      end
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 13, "Check info buffer") == -1) $finish;    
    `endif //test_7.1.10
    /******* 7.1.12 Message validation.***********/
    `ifdef test_7_1_12  
      $display("~~~~~~~~~~~~~~~TEST 7_1_12~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx =  {2'b00, 1'b0, 7'h7e,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish; 
      #1000us   
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 1, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 1, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif //test_7.1.12
    /******* 7.1.13 DLC not belonging to NDATA.***********/
    `ifdef test_7_1_13  
    // T.B.D
    `endif //test_7.1.13
    /******* 7.2.1 Bit error in data frame.***********/
    `ifdef test_7_2_1 
      $display("~~~~~~~~~~~~~~~TEST 7_2_1~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(1000us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx =  {2'b01, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish; 
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("BIT"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif //test_7.2.1
    /******* 7.2.2&7.2.3 Stuff error test1, test2.***********/
    `ifdef test_7_2_2  
      $display("~~~~~~~~~~~~~~~TEST 7_2_2~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(1000us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end
      identifier11 = new[10];
      ctrlFied     = new[10];
      identifier18 = new[10];
      identifier18 = '{'h30f0f, 'h0f0f0, 'h31717, 'h00ff0, 'h0, 'h540f, 'h15557, 0, 0, 0};
      identifier11 = '{'h78, 'h41F, 'h707, 'h360, 'h730, 'h47F, 'h758, 'h777, 'h7ef, 'h3ea};    
      ctrlFied     = '{8, 1, 'h1f, 'h10, 'h10, 1, 0, 1, 2, 'h1f};
      dataIn = '{1, 'he1, 'he1, 'he1, 'he1, 'he1, 'he1, 'he1, 0, 
                 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'h1f, 'h1f};
      dataInEmpty.delete();           
      for(int ide = 0; ide < 2; ide++) begin
        for(int iden = 0; iden < identifier11.size(); iden++) begin
          temp = (ctrlFied[iden]>>4);
          temp1 = ctrlFied[iden]&15;
                     //StuffErr EOF  CRCdel CRCerr     R1/R0       SRR   DLC
          paramTx =  {2'b00, 1'b1, 7'h7f,    1'b1,   1'b0,  temp[1:0],1'b1, 4'd0};
          if(temp1 > 8) begin
            paramTx =    {2'b00, 1'b1, 7'h7f,    1'b1,   1'b0,  temp[1:0], 1'b1, temp1[3:0]};
            if((iden == 9) || (iden == 6)&&(ide == 1)) begin 
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end  
            else begin
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataIn[0:7], paramTx);
              pkt.PrintPkt("In data: ", dataIn[0:7]);
              expData = dataIn[0:7];
              dataIn = dataIn[8:$];
            end  
          end else if(temp1 == 0) begin
            if((iden == 5)&&(ide == 1)) begin 
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end  
            else begin 
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataInEmpty, paramTx);
              pkt.PrintPkt("In data: ", dataInEmpty);
              expData.delete();
            end  
          end else begin
            if((iden == 8) || (iden == 5)&&(ide == 1)) begin
              can_txrx[0].txRemoteFrame(identifier11[iden], identifier18[iden], ide, paramTx);
              pkt.genRndPkt(5, expData);
              can_txrx[1].putARFR_Buff(identifier11[iden], identifier18[iden], ide, expData);
            end else begin
              can_txrx[0].txDataFrame(identifier11[iden], identifier18[iden], ide, dataIn[0:(temp1-1)], paramTx);
              expData = dataIn[0:(temp1-1)];
              pkt.PrintPkt("In data: ", dataIn[0:(temp1-1)]);
              dataIn = dataIn[temp1:$];
            end  
          end
          if((iden < 8)&&(ide == 0) || (iden < 5)) begin
            can_txrx[1].getRxDataFrame(identifier11[iden], identifier18[iden], ide, dataOut);
            if(expData.size() != 0) begin
              if(chk.CheckPkt(dataOut, expData) == -1) $finish;
            end
          end else begin
            can_txrx[0].getRxDataFrame(identifier11[iden], identifier18[iden], ide, dataOut);
            if(expData.size() != 0) begin
              if(chk.CheckPkt(dataOut, expData) == -1) $finish;
            end
          end         
        end
        identifier11 = new[7];
        identifier11 = '{'h1f0, 'h1f0, 'h78, 'h78, 'h7ee, 'h2f, 'h557};
        ctrlFied     = '{8, 1, 'h1f, 'h3c, 'h1, 'h20, 'h3f};
        dataIn = '{'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 'h3c, 0,  
                 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'hf, 'h1f, 'hf, 'he0, 'hf0, 'h7f,
                 'he0, 'hff, 'h20, 'ha0};
      end
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 17, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 17, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("STUFF"), 17, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 13, "Check info buffer") == -1) $finish;
    `endif //test_7.2.2
    /******* 7.2.4&7.2.5 CRC error test. Combination of CRC error and form error.***********/
    `ifdef test_7_2_4  
      $display("~~~~~~~~~~~~~~~TEST 7_2_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      for(int del = 1; del >= 0; del--) begin
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        paramTx =  {2'b00, 1'b0, 7'h7f,    del[0],   1'b1,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      end   
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 2, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("CRC"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif //test_7_2_4
    /******* 7.2.6&7.2.7&7.2.8&7.2.9 For error in data frame.***********/
    `ifdef test_7_2_6 
      $display("~~~~~~~~~~~~~~~TEST 7_2_6~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      for(int del = 3; del >= 0; del--) begin
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        if(del == 3) paramTx =  {2'b00, 1'b0, 7'h7f,    1'b0,   1'b0,  2'b00, 1'b1, 4'd0};
        else if(del == 2) paramTx =  {2'b00, 1'b0, 7'h7d,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        else if (del == 1) paramTx =  {2'b10, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        else paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      end   
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif //test_7_2_6
    /******* 7.3.1 Error flag longer than 6 bits.***********/
    `ifdef test_7_3_1
    // T.B.D
    `endif // test_7_3_1
    /******* 7.3.2 Data frame starting on the third bit of Intermission Field.***********/
    `ifdef test_7_3_2
      $display("~~~~~~~~~~~~~~~TEST 7_3_2~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      for(int itr = 0; itr < 2; itr++)begin
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        if(itr == 0) paramTx =  {2'b00, 1'b0, 7'h6f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        else paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
        // Start at the 3rd bit of intermission
        can_txrx[0].configTransmitter(1);
      end  
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_3_2
    /******* 7.3.3 Bit error in Error flag.***********/
    `ifdef test_7_3_3
    // T.B.D
    `endif // test_7_3_3
    /******* 7.3.4 Form error in error dellimiter.***********/
    `ifdef test_7_3_4
      $display("~~~~~~~~~~~~~~~TEST 7_3_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
      end    
      identifier11 = new[1];
      for(int itr = 0; itr < 3; itr++)begin
        if(itr == 0) can_txrx[0].configTransmitter(0, 0, 'h5f);
        else if(itr == 1) can_txrx[0].configTransmitter(0, 0, 'h77);
        else can_txrx[0].configTransmitter(0, 0, 'h7d);
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b1,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      end  
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 6, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 6, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("CRC"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_3_4
    /******* 7.4.1&7.4.2 Overload generation during intermission field.***********/
    /******************* Last bit of EOF ***************************/
    `ifdef test_7_4_1
      $display("~~~~~~~~~~~~~~~TEST 7_4_1~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 0);
      end    
      identifier11 = new[1];
      for(int itr = 0; itr < 3; itr++)begin
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        if(itr == 2) paramTx =  {2'b00, 1'b0, 7'h7e,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        else paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        // WAIT FOR OVERLOAD FRAME IS DONE
        #50us;
        if(itr == 0) can_txrx[0].configTransmitter(0, 0, 'h7f, 2);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      end  
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 1, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 3, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 2, "Check overload counters") == -1) $finish;
    `endif // test_7_4_1
    /******* 7.4.4 Bit error in Overload flag.***********/
    `ifdef test_7_4_4
    // T.B.D.
    `endif // test_7_4_4
    /******* 7.4.3&7.4.5 8th bit of Overload/Error delimiter.***********/
    /******************* Form error of Overload delimiter **************/
    `ifdef test_7_4_3
      $display("~~~~~~~~~~~~~~~TEST 7_4_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7e, 3);
      end    
      identifier11 = new[1];
      for(int itr = 0; itr < 5; itr++)begin
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        if(itr == 0) paramTx =  {2'b00, 1'b0, 7'h7F,    1'b1,   1'b1,  2'b00, 1'b1, 4'd0};
        else paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        // WAIT FOR OVERLOAD FRAME IS DONE
        #50us;
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
        if(itr == 0) begin 
          can_txrx[0].configTransmitter(0, 0, 'h7e, 0);
        end else if(itr == 1) begin
          can_txrx[0].configTransmitter(0, 0, 'h3f, 0);
        end else if(itr == 2) begin
          can_txrx[0].configTransmitter(0, 0, 'h6f, 0);
        end else if(itr == 3) begin
          can_txrx[0].configTransmitter(0, 0, 'h7d, 0);
        end
      end  
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 4, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 4, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 6, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 6, "Check overload counters") == -1) $finish;
    `endif // test_7_4_3
    /******* 7.5.1 Passive error flag completion test.***********/
    `ifdef test_7_5_1
    // T.B.D.
    `endif // test_7_5_1
    /******* 7.5.2 Data Frame acceptance after passive error frame transmission.***********/
    `ifdef test_7_5_2
      $display("~~~~~~~~~~~~~~~TEST 7_5_2~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 0, 200, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      can_txrx[0].txDebugFrame(512'h00ffff, 22);
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx =  {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      can_txrx[0].rxDebugFrame(debugData);
      if(chk.CheckWord(debugData[22:0], 'b000000_111111_11111111_11, "Check debug buffer") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_5_2
    /******* 7.5.3 Acceptance of 7 consecutive dominant bits after after passive error flag.***********/
    `ifdef test_7_5_3
      $display("~~~~~~~~~~~~~~~TEST 7_5_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 0, 200, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      for(int domBit = 1; domBit <= 3; domBit++) begin
        if(domBit == 1) can_txrx[0].txDebugFrame(512'b000000_111111_0_11111111_11, 23);
        else if(domBit == 2) can_txrx[0].txDebugFrame(512'b000000_111111_0000_11111111_11, 26);
        else can_txrx[0].txDebugFrame(512'b000000_111111_0000000_11111111_11, 29);
        identifier11 = '{($random()&{11{1'b1}})};  
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
        can_txrx[0].rxDebugFrame(debugData);
        if(domBit == 1) if(chk.CheckWord(debugData[22:0], 'b000000_111111_0_11111111_11, "Check debug buffer") == -1) $finish;
        else if(domBit == 2) if(chk.CheckWord(debugData[26:0], 'b000000_111111_0000_11111111_11, "Check debug buffer") == -1) $finish;
        else if(chk.CheckWord(debugData[29:0], 'b000000_111111_0000000_11111111_11, "Check debug buffer") == -1) $finish;
      end
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_5_3
    /******* 7.5.4 Passive state unchanged on further errors.***********/
    `ifdef test_7_5_4
      $display("~~~~~~~~~~~~~~~TEST 7_5_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 0, 200, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      for(int domBit = 0; domBit < 9; domBit++) begin
        can_txrx[0].txDebugFrame(512'b000000_111111_11111111_11, 22);
        can_txrx[0].rxDebugFrame(debugData);
        if(chk.CheckWord(debugData[22:0], 'b000000_111111_11111111_11, "Check debug buffer") == -1) $finish;
      end
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 9, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_5_4
    /******* 7.5.5 Passive error flag completion.***********/
    `ifdef test_7_5_5
    // T.B.D.
    `endif // test_7_5_5
    /******* 7.5.6 For error in Passive error delimiter.***********/
    `ifdef test_7_5_6
      $display("~~~~~~~~~~~~~~~TEST 7_5_6~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 0, 200, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      for(int domBit = 0; domBit < 3; domBit++) begin
        if(domBit == 0) can_txrx[0].txDebugFrame(512'b000000111111_10_111111_11111110_11111111111111_11, 44);
        else if(domBit == 1) can_txrx[0].txDebugFrame(512'b000000111111_1110_111111_11111110_11111111111111_11, 46);
        else can_txrx[0].txDebugFrame(512'b000000111111_1111110_111111_11111110_11111111111111_11, 49);
      end
      repeat(3) can_txrx[0].rxDebugFrame(debugData);
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 6, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("STUFF"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 3, "Check overload counters") == -1) $finish;
    `endif // test_7_5_6
    /******* 7.6.1 REC increment on bit error in active error flag.***********/
    `ifdef test_7_6_1
      $display("~~~~~~~~~~~~~~~TEST 7_6_1~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      for(int domBit = 0; domBit < 3; domBit++) begin
        if(domBit == 0) begin 
          can_txrx[0].txDebugFrame(512'b000000_1111111_11111111_11, 23, 512'b000000_1000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckWord(debugData[37:0], 'b000000_1000000_11111111_11, "Check debug buffer") == -1) $finish;
        end else if(domBit == 1) begin
          can_txrx[0].txDebugFrame(512'b000000_1111111111_11111111_11, 26, 512'b000000_0001000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckWord(debugData[37:0], 'b000000_0001000000_11111111_11, "Check debug buffer") == -1) $finish;
        end else begin
          can_txrx[0].txDebugFrame(512'b000000_1111111_11111111_11, 23, 512'b000000_1000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckWord(debugData[37:0], 'b000000_0000001000000_11111111_11, "Check debug buffer") == -1) $finish;
        end  
      end
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 27, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
      //if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("STUFF"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_1
    /******* 7.6.2 REC increment on bit error in overload flag.***********/
    `ifdef test_7_6_2
      $display("~~~~~~~~~~~~~~~TEST 7_6_2~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      for(int domBit = 0; domBit < 3; domBit++) begin
        if(domBit == 0) begin
          can_txrx[0].txDebugFrame(512'b000000_111111_11111110_1111111_11111111_11, 37, 512'b000000_000000_00000000_1000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckBitVec(debugData[36:0], 37'b000000_000000_11111110_1000000_11111111_11, "Check debug buffer") == -1) $finish;
        end else if(domBit == 1) begin
          can_txrx[0].txDebugFrame(512'b000000_111111_11111110_1111111111_11111111_11, 40, 512'b000000_000000_00000000_0001000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckBitVec(debugData[39:0], 40'b000000_000000_11111110_0001000000_11111111_11, "Check debug buffer") == -1) $finish;
        end else begin
          can_txrx[0].txDebugFrame(512'b000000_111111_11111110_111111111111_11111111_11, 42, 512'b000000_000000_00000000_000001000000_00000000_00);
          // Check debug buffer. Active error flag expected.
          can_txrx[0].rxDebugFrame(debugData);
          if(chk.CheckBitVec(debugData[41:0], 42'b000000_000000_11111110_000001000000_11111111_11, "Check debug buffer") == -1) $finish;
        end
      end
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 27, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("STUFF"), 3, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 3, "Check overload counters") == -1) $finish;
    `endif // test_7_6_2
    /******* 7.6.3 REC increment active error flag is longer than 13 bits.***********/
    `ifdef test_7_6_3
      $display("~~~~~~~~~~~~~~~TEST 7_6_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      can_txrx[0].txDebugFrame(512'b000000_111111_0000000000000000_11111111_11, 38);
      can_txrx[0].rxDebugFrame(debugData);
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 17, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_3
    /******* 7.6.4 REC increment when overload flag is longer than 13 bits.***********/
    `ifdef test_7_6_4
      $display("~~~~~~~~~~~~~~~TEST 7_6_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      can_txrx[0].txDebugFrame(512'b000000_111111_11111110_1111110000000000000000_11111111_11, 52);
      can_txrx[0].rxDebugFrame(debugData);
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 17, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 1, "Check overload counters") == -1) $finish;
    `endif // test_7_6_4
    /******* 7.6.5 REC increment on bit error in the ACK field.***********/
    `ifdef test_7_6_5
      $display("~~~~~~~~~~~~~~~TEST 7_6_5~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b01, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      // 1st bit after error flag is dominant. REC INCR by 8
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 8, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("BIT"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_5
    /******* 7.6.6 REC increment on form error at CRC delimiter.***********/
    `ifdef test_7_6_6
      $display("~~~~~~~~~~~~~~~TEST 7_6_6~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b0,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      // 1st bit after error flag is dominant. REC INCR by 8
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 8, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_6
    /******* 7.6.7 REC increment on form error at CRC delimiter.***********/
    `ifdef test_7_6_7
      $display("~~~~~~~~~~~~~~~TEST 7_6_7~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b10, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      // 1st bit after error flag is dominant. REC INCR by 8
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 8, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("FORM"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_7
    /******* 7.6.10 REC increment on CRC error.***********/
    `ifdef test_7_6_10
      $display("~~~~~~~~~~~~~~~TEST 7_6_10~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b1,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      // 1st bit after error flag is dominant. REC INCR by 8
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 8, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("CRC"), 1, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_10
    /******* 7.6.12 REC increment on form error in error delimiter.***********/
    `ifdef test_7_6_12
      $display("~~~~~~~~~~~~~~~TEST 7_6_12~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      can_txrx[0].txDebugFrame(512'b000000_111111_10_111111_11111111_11, 30);
      can_txrx[0].rxDebugFrame(debugData);
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 2, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 2, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_12
    /******* 7.6.15 REC decrement on valid frame reception during passive state.***********/
    `ifdef test_7_6_15
      $display("~~~~~~~~~~~~~~~TEST 7_6_15~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 0, 200, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 119, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      // Check overload counters
      if(chk.CheckWord(can_txrx[0].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox("ovld"), 0, "Check overload counters") == -1) $finish;
    `endif // test_7_6_15
    /******* 7.6.16 REC non increment on last bit EOF field.***********/
    `ifdef test_7_6_16
      $display("~~~~~~~~~~~~~~~TEST 7_6_16~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end    
      identifier11 = new[1];
      identifier11 = '{($random()&{11{1'b1}})};  
      pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7e,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[0].txDataFrame(identifier11[0], 0, 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier11[0], 0, 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check REC
      if(chk.CheckWord(can_txrx[1].checkErrors("REC"), 0, "Check REC") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      // Check info buffer
      if(chk.CheckWord(can_txrx[0].checkInfoBox(), 0, "Check info buffer") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkInfoBox(), 1, "Check info buffer") == -1) $finish;
    `endif // test_7_6_16   
    //////////////////////////////////////////////////////////////////
    //// 8. Transmitted Frame Type
    //////////////////////////////////////////////////////////////////    
    /******* 8.1.3 Arbitration in standard format frame.***********/
    `ifdef test_8_1_3
      $display("~~~~~~~~~~~~~~~TEST 8_1_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(200us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier11 = new[11];
      identifier11 = '{($random()&'h3ff), ($random()&'h5ff), ($random()&'h6ff), ($random()&'h77f),
                       ($random()&'h7bf), ($random()&'h7df), ($random()&'h7e7), ($random()&'h7eb),
                       ($random()&'h7ed), ($random()&'h7ee), 'h7ef};
      for(int iden = 0; iden < 10; iden++) begin                 
        pkt.genRndPkt(pkt.genRndNum(0, 0), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        can_txrx[1].txDataFrame(identifier11[10], 0, 0, dataIn, paramTx);
        pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        can_txrx[0].txDataFrame(identifier11[iden], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[iden], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
        can_txrx[0].getRxDataFrame(identifier11[10], 0, 0, dataOut);
        if(chk.CheckWord(dataOut.size(), 0, "Check 0 size buffer") == -1) $finish;
      end
      identifier11 = '{($random()&'h00f), 'h010, 'h010};
      for(int iden = 0; iden < 2; iden++) begin                 
        #100us
        pkt.genRndPkt(pkt.genRndNum(0, 0), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
        if(iden == 0) can_txrx[1].txDataFrame(identifier11[2], 0, 0, dataIn, paramTx);
        else can_txrx[1].txRemoteFrame(identifier11[2], 0, 0, paramTx);
        pkt.genRndPkt(pkt.genRndNum(1, 8), dataIn);
        pkt.PrintPkt("In data: ", dataIn);
        can_txrx[0].txDataFrame(identifier11[iden], 0, 0, dataIn, paramTx);
        can_txrx[1].getRxDataFrame(identifier11[iden], 0, 0, dataOut);
        pkt.PrintPkt("Out data: ", dataOut);
        if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
        if(iden == 0) begin
          can_txrx[0].getRxDataFrame(identifier11[2], 0, 0, dataOut);
          if(chk.CheckWord(dataOut.size(), 0, "Check 0 size buffer") == -1) $finish;
        end  
      end
      #1000us
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;                                      
    `endif // test_8_1_3
    /******* 8.1.4 Arbitration in standard format frame.***********/
    `ifdef test_8_1_4
      $display("~~~~~~~~~~~~~~~TEST 8_1_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(100us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'h1fbfffff;     
      for(int iden = 28; iden >= 0; iden--) begin
        identifier_0 = identifier_1;
        identifier_0[iden] = 1'b0;
        if(iden != 22) begin                 
          pkt.genRndPkt(pkt.genRndNum(0, 0), dataIn);
          pkt.PrintPkt("In data: ", dataIn);
          paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
          can_txrx[1].txDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataIn, paramTx);
          pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
          pkt.PrintPkt("In data: ", dataIn);
          can_txrx[0].txDataFrame(identifier_0[28:18], identifier_0[17:0], 1, dataIn, paramTx);
          can_txrx[1].getRxDataFrame(identifier_0[28:18], identifier_0[17:0], 1, dataOut);
          pkt.PrintPkt("Out data: ", dataOut);
          if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
          can_txrx[0].getRxDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataOut);
          if(chk.CheckWord(dataOut.size(), 0, "Check 0 size buffer") == -1) $finish;
        end  
      end
      identifier_1 = 'h00400000;     
      pkt.genRndPkt(pkt.genRndNum(0, 0), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataIn, paramTx);
      pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b0, 4'd0};
      can_txrx[0].txDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataOut);
      if(chk.CheckWord(dataOut.size(), 0, "Check 0 size buffer") == -1) $finish;
      pkt.genRndPkt(pkt.genRndNum(0, 0), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataIn, paramTx);
      pkt.genRndPkt(pkt.genRndNum(1, 1), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      can_txrx[0].txDataFrame(identifier_1[28:18], identifier_1[17:0], 0, dataIn, paramTx);
      can_txrx[1].getRxDataFrame(identifier_1[28:18], identifier_1[17:0], 0, dataOut);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1[28:18], identifier_1[17:0], 1, dataOut);
      if(chk.CheckWord(dataOut.size(), 0, "Check 0 size buffer") == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
    `endif // test_8_1_4  
    /******* 8.2.1 Bit error in standard frame.***********/
    `ifdef test_8_2_1
      $display("~~~~~~~~~~~~~~~TEST 8_2_1~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[i].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b10101010101;
      pkt.genRndPkt(pkt.genRndNum(7, 7), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      for(int i = 0; i < 3; i++) begin
        if(i == 0)begin
          debugData = 34'b1_11111111111_111_10_11111111111111_111;
          can_txrx[0].txDebugFrame(debugData, 34);
        end
        if(i == 1)begin
          debugData = 20'b1_11_11111111111111_111;
          can_txrx[0].txDebugFrame(debugData, 20, 'b0_01_00000000000000000);
        end
        if(i == 2)begin
          debugData = 33'b1_11111111111_111_1_11111111111111_111;
          can_txrx[0].txDebugFrame(debugData, 33, 33'b0_00000000000_000_1_00000000000000_000);
        end
      end
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      for(int i = 0; i < 3; i++) can_txrx[0].rxDebugFrame(debugData);
      pkt.PrintPkt("Out data: ", dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("BIT"), 3, "Check error buffers") == -1) $finish;
    `endif // test_8_2_1      
    /******* 8.5.1 Bit error in standard frame.***********/
    `ifdef test_8_5_1
      $display("~~~~~~~~~~~~~~~TEST 8_5_1~~~~~~~~~~~~~~~");
      //Wait until suspend transmission of point 1 is done
      can_txrx[0].setIdle(8us); 
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configOverloadFrames(0, 0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 200, -1, 1);
        can_txrx[i].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      for(int i = 0; i < 3; i++) begin
        if(i == 0) begin
          debugData = 'b1_1_000000_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 27, 'b010000000000000000000000000);
        end else if(i == 1) begin
          debugData = 'b1_1_1000000_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 28, 'b0100000000000000000000000000);
        end else begin
          debugData = 'b1_1_11111000000_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 32, 'b01000000000000000000000000000000);
        end     
      end  
      for(int i = 0; i < 3; i++) begin
        can_txrx[0].rxDebugFrame(debugData);      
        // Check debug buffers 
        if(i  == 0) if(chk.CheckWord(debugData, 'b0_1_000000_11111111_11111111111, "Check debud buffers") == -1) $finish;
        if(i  == 1) if(chk.CheckWord(debugData, 'b0_1_1000000_11111111_11111111111, "Check debud buffers") == -1) $finish;
        if(i  == 2) if(chk.CheckWord(debugData, 'b0_1_11111000000_11111111_11111111111, "Check debud buffers") == -1) $finish;
      end
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
    `endif // test_8_5_1
    /******* 8.5.3 Acceptance of 7 concecutive dominant bits after passive error flag.***********/
    `ifdef test_8_5_3
      //Wait until suspend transmission of point 1 is done
      can_txrx[0].setIdle(8us);  
      $display("~~~~~~~~~~~~~~~TEST 8_5_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 200, -1, 1);
        can_txrx[i].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 11'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      for(int i = 0; i < 3; i++) begin
        if(i == 0) begin
          debugData = 'b1_1_111111_0_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 28, 'b0100000000000000000000000000);
        end else if(i == 1) begin
          debugData = 32'b1_1_1000000_0000_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 32, 'b01000000000000000000000000000000);
        end else begin
          debugData = 40'b1_1_11111000000_00000000_11111111_11111111111;
          can_txrx[0].txDebugFrame(debugData, 40, 40'b0100000000000000000000000000000000000000);
        end     
      end  
      for(int i = 0; i < 3; i++) begin
        can_txrx[0].rxDebugFrame(debugData);      
        // Check debug buffers 
        if(i == 0) if(chk.CheckWord(debugData, 'b0_1_111111_0_11111111_11111111111, "Check debud buffers") == -1) $finish;
        if(i == 1) if(chk.CheckWord(debugData, 'b0_1_1000000_0000_11111111_11111111111, "Check debud buffers") == -1) $finish;
        if(i == 2) if(chk.CheckBitVec(debugData, 40'b0_1_11111000000_00000000_11111111_11111111111, "sssCheck debud buffers") == -1) $finish;
      end
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 3, "Check error buffers") == -1) $finish;
    `endif // test_8_5_3
    /******* 8.6.1 TEC increment on bit error during active error flag.***********/
    `ifdef test_8_6_1
      $display("~~~~~~~~~~~~~~~TEST 8_6_1~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      debugData = 'b1_1_0001000000_11111111_111;
      can_txrx[0].txDebugFrame(debugData, 23, 'b01000100000000000000000);
      can_txrx[0].rxDebugFrame(debugData);      
      // Check debug buffers 
      if(chk.CheckWord(debugData, 'b0_1_0001000000_11111111_111, "Check debud buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 16, "Check TEC") == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 15, "Check TEC") == -1) $finish;
    `endif // test_8_6_1
    /******* 8.6.3 TEC increment when active error flag is followed by dominant bit.***********/
    `ifdef test_8_6_3
      $display("~~~~~~~~~~~~~~~TEST 8_6_3~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      debugData = 512'b1_1_1111110000000000000000_11111111_111;
      can_txrx[0].txDebugFrame(debugData, 35, 35'b01000000000000000000000000000000000);
      can_txrx[0].rxDebugFrame(debugData);
      // Check debug buffers 
      if(chk.CheckWord(debugData, 35'b0_1_0000000000000000000000_11111111_111, "Check debud buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 24, "Check TEC") == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      // Wait for idle
      #3us
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 23, "Check TEC") == -1) $finish;
    `endif // test_8_6_3
    /******* 8.6.4 TEC increment when active error flag is followed by dominant bit.***********/
    `ifdef test_8_6_4
      $display("~~~~~~~~~~~~~~~TEST 8_6_4~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, 200, -1, 1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      debugData = 512'b1_1_1111110000000000000000_11111111_111;
      can_txrx[0].txDebugFrame(debugData, 35, 35'b01000000000000000000000000000000000);
      can_txrx[0].rxDebugFrame(debugData);      
      // Check debug buffers 
      if(chk.CheckWord(debugData, 35'b0_1_1111110000000000000000_11111111_111, "Check debud buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 224, "Check TEC") == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Wait for idle
      #11us
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 223, "Check TEC") == -1) $finish;
    `endif // test_8_6_4
    /******* 8.6.8 TEC increment on acknowledgment error.***********/
    `ifdef test_8_6_8
      $display("~~~~~~~~~~~~~~~TEST 8_6_8~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 1, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 7, "Check TEC") == -1) $finish;
    `endif // test_8_6_8
    /******* 8.6.9 TEC increment on form error in error delimiter.***********/
    `ifdef test_8_6_9
      $display("~~~~~~~~~~~~~~~TEST 8_6_9~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 1, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
        can_txrx[1].configTransmitter(0, 0, 'h77, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 2, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 2, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 15, "Check TEC") == -1) $finish;
    `endif // test_8_6_9
    /******* 8.6.14 TEC non increment on 13 bit long error flag.***********/
    `ifdef test_8_6_14
      $display("~~~~~~~~~~~~~~~TEST 8_6_14~~~~~~~~~~~~~~~");
      for(int i = 0; i < numPoints; i++) begin
        can_txrx[i].setDebugMode(0);
        can_txrx[i].configReceiver(400us, 0, 0);
        can_txrx[i].configGlobal(1us, 0.75us, 1, 1, -1, -1, -1);
        can_txrx[0].configTransmitter(0, 0, 'h7f, 3);
      end
      identifier_1 = 'b01111111111;
      pkt.genRndPkt(pkt.genRndNum(8, 8), dataIn);
      pkt.PrintPkt("In data: ", dataIn);
      paramTx = {2'b00, 1'b0, 7'h7f,    1'b1,   1'b0,  2'b00, 1'b1, 4'd0};
      can_txrx[1].txDataFrame(identifier_1, 0, 0, dataIn, paramTx);
      debugData = 512'b1_1_1111110000000_11111111_111;
      can_txrx[0].txDebugFrame(debugData, 26, 26'b01000000000000000000000000);
      can_txrx[0].rxDebugFrame(debugData);      
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 8, "Check TEC") == -1) $finish;
      can_txrx[0].getRxDataFrame(identifier_1, 0, 0, dataOut);
      if(chk.CheckPkt(dataOut, dataIn) == -1) $finish;
      // Wait for idle
      #11us
      // Check error buffers 
      if(chk.CheckWord(can_txrx[0].checkErrors("ALL"), 0, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("ALL"), 1, "Check error buffers") == -1) $finish;
      if(chk.CheckWord(can_txrx[1].checkErrors("TEC"), 7, "Check TEC") == -1) $finish;
    `endif // test_8_6_14    
    // Test done report status
    can_txrx[0].configGlobal(1us, 0.75us, 1, 1);
    can_txrx[1].configGlobal(1us, 0.75us, 1, 1);
    for(int i = 0; i < 2; i++) begin
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
