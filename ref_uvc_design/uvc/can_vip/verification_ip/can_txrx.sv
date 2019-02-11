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

package CAN_TXRX;
typedef bit [7:0]    bit8;
typedef class CAN_txrx_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(CAN_txrx_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class CAN_txrx_busTrans:
///////////////////////////////////////////////////////////////////////////////
class CAN_txrx_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  enum {IDLE, DATA_FRAME, DEBUG_FRAME}TrType;
  int                                 identifier11, identifier18;
  int                                 srr;
  int                                 ide;
  int                                 rtr;
  int                                 r0;
  int                                 r1;
  int                                 dlc;
  bit8                                data[8];
  int                                 crc;
  int                                 crcDelim;
  int                                 ackErr;
  int                                 ackDelErr;
  int                                 txEOF;
  int                                 stuffErrEn;
  int                                 ovldFrameCnt;
  int                                 errCnt;
  time                                idleTime;
  string                              failedTr;
  int unsigned                        rdDataPtr;
  bit [511:0]                         debugData;
  bit [511:0]                         debugDataRx;
  int                                 debugDataCnt;
  bit [511:0]                         frEn;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- genErrorMsg(): Generate error message and keep in the "failedTr" string.*/
  /////////////////////////////////////////////////////////////////////////////
  function void genErrorMsg(string errStringPre, errString, errStringPost);
    string tempStr;
    errString = {errStringPre, "-", errString};
    errString = {errString, " at sim time "};
    $write(errString);
    $write("%0d\n", $time());
    tempStr.itoa($time);
    this.failedTr = errString;
    this.failedTr = {this.failedTr, " ", tempStr, "ns"};
    this.failedTr = {this.failedTr, ". Additional info:", errStringPost};
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- calcCRC(): Calculate CRC.*/
  /////////////////////////////////////////////////////////////////////////////
  function int calcCRC();
    int crcRG, crcLength;
    bit crcNext, nextDataBit;
    bit[127:0] crcDataIn;
    int dataBuffSize;
    // Get data buffer size
    if(this.rtr == 1) begin
      dataBuffSize = 0;
    end else begin
      if(this.dlc > 8) dataBuffSize = 8;
      else dataBuffSize = this.dlc;
    end  
    // Compose CRC input data
    if(this.ide == 1) begin
      // Extended frame.
      crcLength        = 1+11+1+1+18+1+2+4+dataBuffSize*8;
      crcDataIn = {1'b0, this.identifier11[10:0], this.srr[0], 1'b1, this.identifier18[17:0],
                  this.rtr[0], this.r1[0], this.r0[0], this.dlc[3:0], 64'd0};
    end else begin
      // Standard frame.
      crcLength        = 1+11+1+1+1+4+dataBuffSize*8;
      crcDataIn = {1'b0, this.identifier11[10:0], this.rtr[0], 1'b0, this.r0[0], this.dlc[3:0], 64'd0};
    end
    crcDataIn = crcDataIn >> (64 - dataBuffSize*8);
    for(int i = 0; i < dataBuffSize; i++) begin
      crcDataIn[8*i+:8] = this.data[dataBuffSize-i-1];
    end
    // Calculate CRC
    crcRG = 0;
    for(int i = crcLength-1; i >= 0; i--) begin
      nextDataBit = crcDataIn[i];
      crcNext = nextDataBit ^ crcRG[14];
      crcRG = crcRG << 1;
      if(crcNext == 1'b1) begin
        crcRG[14:0] = crcRG[14:0] ^ 15'h4599;
      end
    end
    calcCRC = crcRG & {17'd0, {15{1'b1}}};
  endfunction
  //
endclass // CAN_txrx_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class CAN_txrx_busBFM:
///////////////////////////////////////////////////////////////////////////////
class CAN_txrx_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // Bit timing
  time t_bitTime, t_sample;
  // Interface
  virtual can_txrx_if ifc;
  // Name
  string nameID;
  // Mailboxes
  TransMBox trInBox, statusBox, infoBox, trRxDbgBox;
  TransMBox trRxBox[*];
  TransMBox formErrBox, stuffErrBox, crcErrBox, bitErrBox, ackErrBox;
  // Remote frame mailbox
  TransMBox trRFBox;
  int trRxBoxPtr;
  semaphore rxDoneSem;
  local CAN_txrx_busTrans tr, trRx, trDbg;
  int txBitStuffCnt, rxBitStuffCnt;
  int rxOvldFrameCnt;
  int debugEn;
  int startTXatIFS3bit;
  time idleTime;
  int ackErr, ackDelimiter;
  // TX/RX error counters
  int tec, rec;
  // Error mode. 0 - active, 1 - passive
  int errMode;
  int passiveModeVal;
  int busOffModeVal;
  int recVal;
  int ovrldCnt;
  int activeErrFlag;
  int delErrFlag;
  int ifsVal;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
      fork
        this.main_loop();
      join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- main_loop():*/
  /////////////////////////////////////////////////////////////////////////////
  task main_loop();
    // Init
    int unsigned rndDelay;
    CAN_txrx_busTrans trErr;
    string tempStr;
    int falseRX, rxStatus, arbStatus, sofEn, txEn, errFrameStatus, currErrMode;
    time txDelay;
    int  txDelayEn;
    int txStatus;
    int ifsCnt;
    int OvldFrameCnt;
    int rfDetected;
    int rxSofDet;
    int susTrTxEn;
    int busIdle;
    // 0 - TX, 1 - RX
    int nodeDir;
    int suspendTr;
    bit[255:0] debugDataRx_m;
    
    txDelayEn = 0;
    rfDetected = 0;
    rxSofDet = 0;
    busIdle = 0;
    susTrTxEn = 0;
    this.ifc.tx         <= 1'b1;
    this.ifc.fr         <= 1'b0;
    // Start up delay.
    repeat(3) begin
      #this.t_bitTime;
      if(this.ifc.rx == 1'b0) begin
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $display("ERROR. Source is %s: Start up delay violation. The bus must be IDLE 3 bit time after simulation starts", this.nameID);
        $display("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        $finish;
      end
    end
    // Start main loop
    forever begin
      // Bus is IDLE. Start TX if TX buffer is ready. Start RX if SOF(start of frame)
      // detected on the bus.
      falseRX = 1;
      while(falseRX == 1) begin
        sofEn  = 0;
        txEn   = 0;
        // SOF detected at 3rd clock of INTERMISSION or during suspend transmission
        if(rxSofDet == 1) begin
          rxSofDet = 0;
          if(susTrTxEn == 1) begin
            susTrTxEn = 0;
            // Start Remote Frame response.
            if(rfDetected == 1) begin
              txEn = 1;
            end else if(this.trInBox.num() != 0) begin
              // Start TX if buffer is ready
              this.trInBox.peek(this.tr);
              if((this.tr.TrType == CAN_txrx_busTrans::DATA_FRAME) && (busIdle == 0)) begin
                txEn = 1;
              end
            end  
          end
          break;
        end
        // If remote frame received and remote frame response buffer
        // is not empty transmit data frame from the ARFR buffer.
        if(rfDetected == 1) begin
          sofEn = 1;
          txEn = 1;
          break;
        end
        // Wait for TX/RX
        fork
          wait(this.ifc.rx == 1'b0);
          begin
            wait(busIdle == 0);
            this.trInBox.peek(this.tr);
          end
        join_any
        // Debug frame
        if((this.trInBox.num() != 0) && (this.tr.TrType == CAN_txrx_busTrans::DEBUG_FRAME) && (busIdle == 0)) begin
          this.trInBox.get(this.trDbg);
          falseRX = 1;
          debugDataRx_m = 256'd0;
          this.trDbg.debugDataRx = 512'd0;
          if(this.debugEn == 1) begin
            $display("%s-Start debug frame. simulation time=%0d", this.nameID, $time);
          end    
          for(int dbg = this.trDbg.debugDataCnt-1; dbg >= 0; dbg--) begin
            this.ifc.tx <= this.trDbg.debugData[dbg];
            if(this.trDbg.frEn[dbg] == 1'b1) this.ifc.fr <= this.trDbg.debugData[dbg];
            #(this.t_sample);
            debugDataRx_m[dbg] = this.ifc.rx;
            #(this.t_bitTime - this.t_sample);
            this.ifc.fr <= 1'b0;
          end
          this.trDbg.debugDataRx = {256'd0, debugDataRx_m};
          this.ifc.tx <= 1'b1;
          this.trRxDbgBox.put(this.trDbg);
          if(this.debugEn == 1) begin
            $display("%s-Debug frame done. simulation time=%0d", this.nameID, $time);
          end    
        end else begin
          // If this.trInBox is ready start TX.
          if((this.trInBox.num() != 0) && (this.tr.TrType == CAN_txrx_busTrans::DATA_FRAME) && (busIdle == 0)) begin
            // Generate SOF
            sofEn = 1;
            txEn = 1;
            falseRX = 0;
          end else if((this.trInBox.num() != 0) && (this.tr.TrType == CAN_txrx_busTrans::IDLE) && (busIdle == 0)) begin
            busIdle = 1;
            falseRX = 1;
            this.idleTime = this.tr.idleTime;
            this.trInBox.get(this.tr);
            fork
              begin
                #this.idleTime;
                busIdle = 0;
              end
            join_none
          end
          // Check for RX
          if(this.ifc.rx == 1'b0) begin
            // Doublecheck SOF in this.t_sample time to avoid false transforms.
            #this.t_sample;
            if(this.ifc.rx == 1'b1) begin
              // False RX
              falseRX = 1;
            end else begin
              falseRX = 0;
              #(this.t_bitTime - this.t_sample);
              // If this.trInBox is not empty enable TX but not generate SOF.
              if(this.trInBox.num() != 0) begin
                this.trInBox.peek(this.tr);
                if((this.tr.TrType == CAN_txrx_busTrans::DATA_FRAME) && (busIdle == 0)) begin
                  txEn  = 1;
                end
              end
            end
          end
        end  
      end // end while
      this.trRx = new();
      // Start arbitration phase.
      if(rfDetected == 1) begin
        this.trRFBox.peek(this.tr);
      end
      if(this.debugEn == 1) begin
        $display("%s-Start arbitration. txEn=%0d simulation time=%0d", this.nameID, txEn, $time);
      end
      /**************************Start Arbitration****************************/
      this.arbitration(sofEn, txEn, arbStatus);
      if(this.debugEn == 1) begin
        $display("%s-Arbitration done. arbStatus=%0d, simulation time=%0d", this.nameID, arbStatus, $time);
      end
      // Decrement error counter if error detected.
      if((arbStatus != 1) && (txEn == 1)) begin
        if(this.tr.errCnt != 0) this.tr.errCnt--;
        // Fix all errors
        if(this.tr.errCnt == 0) begin
          // Calculate CRC
          this.tr.crc = this.tr.calcCRC();
          this.tr.crcDelim = 1;
          // TX End Of Frame
          this.tr.txEOF = {25'd0, 7'b1111111};
          // Enable/Disable TX bit stuff error
          this.tr.stuffErrEn = 0;          
        end
      end
      // Check status
      if(arbStatus == 1) begin
        /*******************************TX*************************************/
        // Start TX
        nodeDir = 0;
        this.txFrame(txStatus);
        if(this.debugEn == 1) begin
          $display("%s-TX frame done. txStatus=%0d, simulation time=%0d", this.nameID, txStatus, $time);
        end
        // Decrement error counter if error detected.
        if(txStatus != 1) begin
          if(this.tr.errCnt != 0) this.tr.errCnt--;
          // Fix all errors
          if(this.tr.errCnt == 0) begin
            // Calculate CRC
            this.tr.crc = this.tr.calcCRC();
            this.tr.crcDelim = 1;
            this.tr.ackErr = 0;
            this.tr.ackDelErr = 0;
            // TX End Of Frame
            this.tr.txEOF = {25'd0, 7'b1111111};
            // Enable/Disable TX bit stuff error
            this.tr.stuffErrEn = 0;          
          end
        end
        // Check TX errors
        if(txStatus == -1) begin
          // Bit error.
          trErr = new();
          trErr.genErrorMsg(this.nameID, "Error: Bit error detected", "None");
          this.bitErrBox.put(trErr);
          trErr = null;
          if(this.debugEn == 1) begin
            $display("%s-Bit error detected. Simulation time=%0d", this.nameID, $time);
          end
          // Transmit error frame.
          // Rule 3.
          currErrMode = this.errMode;
          errFrameStatus = this.errCountIncr("Transmitter", 8);
          if(errFrameStatus == 0) begin
            this.txErrorFrame(currErrMode, "Transmitter", errFrameStatus);
          end  
          if(this.debugEn == 1) begin
            $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
          end
          // Frame should be re transmitted after error frame. Do not get the
          // transaction from the trInBox.
        end else if(txStatus == -2) begin
           // Acknowledge error.
          trErr = new();
          trErr.genErrorMsg(this.nameID, "Error: Acknowledge error detected", "None");
          this.ackErrBox.put(trErr);
          trErr = null;
          if(this.debugEn == 1) begin
            $display("%s-Acknowledge error detected. Simulation time=%0d", this.nameID, $time);
          end
          // Transmit error frame.
          // Rule 3.
          currErrMode = this.errMode;
          if(currErrMode == 0) begin
            // Rule 3. Exception 1. Do not increment tec.
            errFrameStatus = this.errCountIncr("Transmitter", 8);
          end
          errFrameStatus = 0;
          if(errFrameStatus == 0) begin
            this.txErrorFrame(currErrMode, "Transmitter", errFrameStatus);
          end
          if(this.debugEn == 1) begin
            $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
          end
          // Frame should be re transmitted after error frame. Do not get the
          // transaction from the trInBox.
        end else begin
          // Frame done. Decrease TEC. Rule 7.
          if(this.tec != 0) this.tec--;
          // Set error mode.
          if((this.tec < this.passiveModeVal) && (this.rec < this.passiveModeVal)) begin
            // Set error active mode.
            this.errMode = 0;
          end
          if(rfDetected == 1) begin
            this.trRFBox.get(this.tr);
            rfDetected = 0;
          end else begin
            this.trInBox.get(this.tr);
          end
          // TX overload frame if necessary.
          OvldFrameCnt = this.tr.ovldFrameCnt;
          if(OvldFrameCnt == -1)OvldFrameCnt = $urandom_range(2, 0);
          repeat(OvldFrameCnt) begin
            // Start TX at the 1st bit of intermission
            this.txOverloadFrame("Transmitter", txStatus);
          end
        end
        /*****************************TX Done***********************************/
      end else if(arbStatus == 2) begin
        /*******************************RX*************************************/
        // Check SRR bit. Report if it is dominant.
        if((this.trRx.srr == 0)&&(this.trRx.ide == 1)) begin
          trErr = new();
          trErr.genErrorMsg(this.nameID, "Info: SRR bit is dominant",
                                         "The sim time is reported after the end of the arbitration.");
          this.infoBox.put(trErr);
          trErr = null;
        end
        // Start RX
        nodeDir = 1;
        if(this.trRx.ide == 1) this.trRxBoxPtr = {2'd0, 1'b1, this.trRx.identifier18[17:0], this.trRx.identifier11[10:0]};
        else this.trRxBoxPtr = {21'd0, this.trRx.identifier11[10:0]};
        if(!this.trRxBox.exists(this.trRxBoxPtr)) begin
          this.trRxBox[this.trRxBoxPtr] = new();
        end
        this.rxFrame(rxStatus);
        // Check reserved R1&R0 bits
        if((this.trRx.r0 == 1)) begin
          trErr = new();
          trErr.genErrorMsg(this.nameID, "Info: R0 bit is recessive",
                                         "The sim time is reported after the end of the frame.");
          this.infoBox.put(trErr);
          trErr = null;
        end
        if((this.trRx.r1 == 1)&&(this.trRx.ide == 1)) begin
          trErr = new();
          trErr.genErrorMsg(this.nameID, "Info: R1 bit is recessive",
                                         "The sim time is reported after the end of the frame.");
          this.infoBox.put(trErr);
          trErr = null;
        end
        if(this.debugEn == 1) begin
          $display("%s-RX frame done. rxStatus=%0d, simulation time=%0d", this.nameID, rxStatus, $time);
        end
        if((rxStatus != 1) && (rxStatus != 2)) begin
          // Check error type
          if(rxStatus == -3) begin
            // CRC error
            trErr = new();
            trErr.genErrorMsg(this.nameID, "Error: CRC error detected", "None");
            this.crcErrBox.put(trErr);
            trErr = null;
            if(this.debugEn == 1) begin
              $display("%s-CRC error detected. Simulation time=%0d", this.nameID, $time);
            end
            // Transmit error frame
            // Rule 1.
            currErrMode = this.errMode;
            errFrameStatus = this.errCountIncr("Receiver", 1);
            if(errFrameStatus == 0) begin
              this.txErrorFrame(currErrMode, "Receiver", errFrameStatus);
            end
            if(this.debugEn == 1) begin
              $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
            end
          end else if (rxStatus == -1) begin
            // Bit stuff error.
            trErr = new();
            trErr.genErrorMsg(this.nameID, "Error: Bit stuff error detected", "None");
            this.stuffErrBox.put(trErr);
            trErr = null;
            if(this.debugEn == 1) begin
              $display("%s-Bit stuff error detected. Simulation time=%0d", this.nameID, $time);
            end
            // Transmit error frame
            // Rule 1.
            currErrMode = this.errMode;
            errFrameStatus = this.errCountIncr("Receiver", 1);
            if(errFrameStatus == 0) begin
              this.txErrorFrame(currErrMode, "Receiver", errFrameStatus);
            end
            if(this.debugEn == 1) begin
              $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
            end
          end else if (rxStatus == -2) begin
            // Form error.
            trErr = new();
            trErr.genErrorMsg(this.nameID, "Error: Form error detected", "None");
            this.formErrBox.put(trErr);
            trErr = null;
            if(this.debugEn == 1) begin
              $display("%s-Form error detected. Simulation time=%0d", this.nameID, $time);
            end
            // Transmit error frame
            // Rule 1.
            currErrMode = this.errMode;
            errFrameStatus = this.errCountIncr("Receiver", 1);
            if(errFrameStatus == 0) begin
              this.txErrorFrame(currErrMode, "Receiver", errFrameStatus);
            end
            if(this.debugEn == 1) begin
              $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
            end
          end else if(rxStatus == -4) begin
            // Bit error during acknowledge.
            trErr = new();
            trErr.genErrorMsg(this.nameID, "Error: Acknowledge bit error detected", "None");
            this.bitErrBox.put(trErr);
            trErr = null;
            if(this.debugEn == 1) begin
              $display("%s-Acknowledge bit error detected. Simulation time=%0d", this.nameID, $time);
            end
            // Transmit error frame
            // Rule 1.
            currErrMode = this.errMode;
            errFrameStatus = this.errCountIncr("Receiver", 1);
            if(errFrameStatus == 0) begin
              this.txErrorFrame(currErrMode, "Receiver", errFrameStatus);
            end
            if(this.debugEn == 1) begin
              $display("%s-Error frame done. Simulation time=%0d", this.nameID, $time);
            end
          end
        end else begin
          // Frame done. Decrease REC. Rule 8.
          if((this.rec > 0) && (this.rec < this.passiveModeVal)) begin
            this.rec--;
          end else if(this.rec >= this.passiveModeVal) begin
            this.rec = this.recVal;
          end   
          // Set error mode.
          if((this.tec < this.passiveModeVal) && (this.rec < this.passiveModeVal)) begin
            // Set error active mode.
            this.errMode = 0;
          end
          
          if(this.trRx.ide == 1) this.trRxBoxPtr = {2'd0, 1'b1, this.trRx.identifier18[17:0], this.trRx.identifier11[10:0]};
          else this.trRxBoxPtr = {21'd0, this.trRx.identifier11[10:0]};
          if(this.trRx.rtr == 0) begin
            //this.trRxBox[this.trRxBoxPtr] = new();
            this.trRxBox[this.trRxBoxPtr].put(this.trRx);
            this.rxDoneSem.put(1);
          end else begin
            // Remote frame detected. Compare identifier11/identifier18 and IDE fields of the received
            // remote frame with the frame in the ARFR buffer and transmit data frame if they are
            // equal. If AFRF buffer is empty ignore received remote frame.
            if(this.trRFBox.num() != 0) begin
              this.trRFBox.peek(this.tr);
              if(((this.trRx.ide == 0) && (this.tr.ide == 0) ||
                  (this.trRx.ide == 1) && (this.tr.ide == 1) &&
                  (this.trRx.identifier18[17:0] == this.tr.identifier18[17:0])) &&
                 (this.trRx.identifier11[10:0] == this.tr.identifier11[10:0])) begin
                rfDetected = 1;
              end
            end
          end
          // TX overload frame if the last bit of EOF is dominant.
          if(rxStatus == 2) begin
            this.txOverloadFrame("Receiver", txStatus);
          end else begin
            // TX overload frame if necessary.
            OvldFrameCnt = this.rxOvldFrameCnt;
            if(OvldFrameCnt == -1)OvldFrameCnt = $urandom_range(2, 0);
            repeat(OvldFrameCnt) begin
              this.txOverloadFrame("Receiver", txStatus);
            end
          end
        end
      /*****************************RX Done***********************************/
      end else if(arbStatus == -1) begin
        // Bit error during arbitration
        trErr = new();
        trErr.genErrorMsg(this.nameID, "Error: Bit error detected during arbitration", "None");
        this.bitErrBox.put(trErr);
        trErr = null;
        if(this.debugEn == 1) begin
          $display("%s-Bit error detected during arbitration. Simulation time=%0d", this.nameID, $time);
          $display("%s-Error mode is %d ", this.nameID, this.errMode);
        end
        // Transmit error frame.
        // Rule 3.
        currErrMode = this.errMode;
        errFrameStatus = this.errCountIncr("Transmitter", 8);
        if(errFrameStatus == 0) begin
          this.txErrorFrame(currErrMode, "Transmitter", errFrameStatus);
        end
        // Frame should be re transmitted after error frame. Do not get the
        // transaction from the trInBox.
      end else if(arbStatus == -2) begin
        // Bit stuff error during arbitration
        trErr = new();
        trErr.genErrorMsg(this.nameID, "Error: Bit stuff error detected during arbitration", "None");
        this.stuffErrBox.put(trErr);
        trErr = null;
        if(this.debugEn == 1) begin
          $display("%s-Bit stuff error detected during arbitration. Simulation time=%0d", this.nameID, $time);
        end
        // Transmit error frame
        // Rule 1.
        currErrMode = this.errMode;
        errFrameStatus = this.errCountIncr("Receiver", 1);
        if(errFrameStatus == 0) begin
          this.txErrorFrame(currErrMode, "Receiver", errFrameStatus);
        end
      end
      // Start INTERFRAME SPACING
      this.trRx = null;
      ifsCnt = 0;
      while(ifsCnt != 2) begin
        this.ifc.tx <= this.ifsVal[1-ifsCnt];
        #this.t_sample;
        if(this.ifc.rx == 1'b0) begin
          ifsCnt = 0;
          this.ifsVal = 3;
          #(this.t_bitTime - this.t_sample);
          // TX overload frame
          this.ovrldCnt++;
          this.txOverloadFrame("Receiver", txStatus);
        end else begin
          #(this.t_bitTime - this.t_sample);
          ifsCnt++;
        end
      end // end while
      // The 3rd clock of INTERFRAME SPACING. Can start TX at this bit time if
      // it is enabled and TX buffer is ready. Otherwise wait 3rd INTERMISSION bit.
      // If that bit is dominant indicate RX SOF and start RX.
      // Suspend transmission if error passive node transmitted the message 
      if((nodeDir == 0) && (this.errMode == 1)) suspendTr = 9;
      else if(this.startTXatIFS3bit == 0) suspendTr = 1;
      else suspendTr = 0; 
      susTrTxEn = 0;
      for(int susTr = 0; susTr < suspendTr; susTr++) begin
        #this.t_sample;
        if(this.ifc.rx == 1'b0) begin
          // Indicate RX start
          rxSofDet = 1;
          if(((nodeDir == 1) || (this.errMode == 0)) && (susTr == 0)) begin
            susTrTxEn  = 1;
          end
          #(this.t_bitTime - this.t_sample);
          break;
        end
        #(this.t_bitTime - this.t_sample);      
      end
    end // end forever
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- arbitration(): TX and RX. Frame arbitration timings.
  // arbStatus =  1: OK. Continue TX.
  //              2: Arbitration lost. Start RX.
  //             -1: TX Bit error
  //             -2: RX Stuff error.*/
  /////////////////////////////////////////////////////////////////////////////
  local task arbitration(input int sofEn, txEn, output int arbStatus);
    CAN_txrx_busTrans trErr;
    string tempStr;
    int status, rxReg, arbSize, arbLost, rxBitCnt, rxBitPtr, stuffStatus;
    bit [63:0] shiftReg;
    // TX SOF(start of frame) bit if it is not done outside.
    if(sofEn == 1) begin
      this.txBits(0, 0, 0, 1, status);
      // Check status.
      if(status == -2) begin
        arbStatus = -1;
      end
    end
    // Bit stuff includes SOF bit.
    this.txBitStuffCnt = -1;
    this.rxBitStuffCnt = -1;
    rxReg = 0;
    rxBitCnt = 0;
    rxBitPtr = 31;
    if(txEn[0]) begin
      // Create frame arbitration field
      if(this.tr.ide == 1) begin
        // Extended frame.
        shiftReg[31:21] = this.tr.identifier11[10:0];
        shiftReg[20]    = this.tr.srr[0];
        shiftReg[19]    = 1'b1;
        shiftReg[18:1]  = this.tr.identifier18[17:0];
        shiftReg[0]     = this.tr.rtr[0];
        arbSize         = 32;
      end else begin
        // Standard frame.
        shiftReg[12:2] = this.tr.identifier11[10:0];
        shiftReg[1]    = this.tr.rtr[0];
        shiftReg[0]    = 1'b0;
        arbSize        = 13;
      end
      // TX bit stuffing.
      this.bitStuff(arbSize, shiftReg, shiftReg, arbSize, this.tr.stuffErrEn, stuffStatus);
      arbLost = 0;
      for(int i = arbSize-1; i >= 0; i--) begin
        this.ifc.tx          <= shiftReg[i];
        // Check RX value and compare with TX.
        #this.t_sample;
        rxReg[rxBitPtr] = this.ifc.rx;
        // RX bit stuffing counter. Necessary when arbitration lost.
        if((this.rxBitStuffCnt != 5) && (this.rxBitStuffCnt != -5)) begin
          rxBitPtr--;
          rxBitCnt++;
        end
        if(((this.rxBitStuffCnt == 5) || (this.rxBitStuffCnt == -5)) && (this.tr.stuffErrEn == 1)) begin
          if((this.ifc.rx == 1'b1) && (this.rxBitStuffCnt == 5)) this.rxBitStuffCnt = 1;
          else if((this.ifc.rx == 1'b0) && (this.rxBitStuffCnt == -5)) this.rxBitStuffCnt = -1;
          else if((this.ifc.rx == 1'b1) && (this.rxBitStuffCnt == -5)) this.rxBitStuffCnt = -1;
          else if((this.ifc.rx == 1'b0) && (this.rxBitStuffCnt == 5)) this.rxBitStuffCnt = 1;
        end else begin
          if((this.ifc.rx == 1'b1) && (this.rxBitStuffCnt > 0)) this.rxBitStuffCnt++;
          else if((this.ifc.rx == 1'b1) && (this.rxBitStuffCnt < 0)) this.rxBitStuffCnt = 1;
          else if((this.ifc.rx == 1'b0) && (this.rxBitStuffCnt < 0)) this.rxBitStuffCnt--;
          else this.rxBitStuffCnt = -1;
        end
        // If the TX bit is not equal to the RX bit check for bit error
        // or for arbitration lost
        if((this.ifc.rx != shiftReg[i])) begin
          if(shiftReg[i] == 1'b1) begin
            // TX recessive RX dominant. Arbitration lost
            arbLost = 1;
            if(this.debugEn == 1) begin
              $display("%s-Arbitration lost. Simulation time=%0d", this.nameID, $time);
            end
          end else begin
            // TX dominant RX recessive. Bit error
            arbStatus = -1;
            #(this.t_bitTime - this.t_sample);
            this.ifc.tx <= 1'b1;
            return;
          end
        end
        #(this.t_bitTime - this.t_sample);
        if(arbLost == 1) begin
          this.ifc.tx          <= 1'b1;
          // RX and check stuff bit
          if((this.rxBitStuffCnt == 5) || (this.rxBitStuffCnt == -5)) begin
            #this.t_sample;
            if((this.rxBitStuffCnt == 5) && (this.ifc.rx == 1'b1) ||
               (this.rxBitStuffCnt == -5) && (this.ifc.rx == 1'b0)) begin
              // Bit stuff error
              arbStatus = -2;
              #(this.t_bitTime-this.t_sample);
              return;
            end
            if(this.rxBitStuffCnt == 5) this.rxBitStuffCnt = -1;
            else this.rxBitStuffCnt = 1;
            #(this.t_bitTime-this.t_sample);
         end
          break;
        end
      end // end for
      if(stuffStatus == 1) this.tr.stuffErrEn = 0;
      // TX done.
      if(arbLost == 0) begin
        arbStatus = 1;
        return;
      end
    end
    // Start/continue RX
    while((rxBitCnt < 13) || (rxReg[19] == 1'b1) && (rxBitCnt < 32)) begin
      #this.t_sample;
      rxReg[rxBitPtr] = this.ifc.rx;
      #(this.t_bitTime - this.t_sample);
      // Check Bit stuff
      this.rxBitStuff(rxReg[rxBitPtr], status);
      if(status != 1) begin
        // Stuff error
        arbStatus = -2;
        return;
      end
      rxBitPtr--;
      rxBitCnt++;
    end
    arbStatus = 2;
    // Init RX fields
    this.trRx.identifier11[10:0] = 0;
    this.trRx.srr = 0;
    this.trRx.identifier18[17:0] = 0;
    this.trRx.ide = 0;
    this.trRx.rtr = 0;
    // Get RX fields
    this.trRx.identifier11[10:0] = rxReg[31:21];
    this.trRx.srr[0] = rxReg[20];
    this.trRx.identifier18[17:0] = rxReg[18:1];
    if(rxBitCnt == 13) begin
      // Standard frame
      this.trRx.ide[0] = 1'b0;
      this.trRx.rtr[0] = rxReg[20];
    end else begin
      // Extended frame
      this.trRx.ide[0] = 1'b1;
      this.trRx.rtr[0] = rxReg[0];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txFrame(): TX frame timings.
  // txStatus = -1: Bit error
  //             1: OK
  //            -2: Acknowledgment error.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txFrame(output int txStatus);
    CAN_txrx_busTrans trErr;
    string tempStr;
    int shiftReg, status;
    bit bitStuffEn;
    txStatus = 1;
    // TX R1/R0 reserved bits.
    shiftReg[0] = this.tr.r0[0];
    shiftReg[1] = this.tr.r1[0];
    this.txBits(1, shiftReg, shiftReg, (1+this.tr.ide), status, this.tr.stuffErrEn);
    if(status != 1) begin
      // Bit error
      txStatus = -1;
      return;
    end
    // TX data length (DLC). The DLC field can be more than 8 but the
    // transmit data buffer size can not be more than 8 bytes.
    shiftReg = this.tr.dlc;
    this.txBits(1, shiftReg, shiftReg, 4, status, this.tr.stuffErrEn);
    // Check status.
    if(status != 1) begin
      // Bit error
      txStatus = -1;
      return;
    end
    // TX data if frame is data frame.
    if(this.tr.rtr == 0) begin
      // If DLC > 8 transmit only 8 bytes of data. No error case defined for
      // the case when DLC > 8. Receivers should interpret data buffer size as
      // 8 byte even when received DLC field is more than 8.
      if(this.tr.dlc > 8) begin
        this.tr.dlc = 8;
      end
      for(int i = 0; i < this.tr.dlc; i++) begin
        shiftReg[7:0] = this.tr.data[i];
        this.txBits(1, shiftReg, shiftReg, 8, status, this.tr.stuffErrEn);
        // Check status.
        if(status != 1) begin
          // Bit error
          txStatus = -1;
          return;
        end
      end
    end
    // TX CRC sequence 15 bits.
    shiftReg = this.tr.crc;
    this.txBits(1, shiftReg, shiftReg, 15, status, this.tr.stuffErrEn);
    // Check status.
    if(status != 1) begin
      // Bit error
      txStatus = -1;
      return;
    end
    // TX CRC delilmiter 1 recessive bit.
    // No bit stuffing on the CRC delimiter
    shiftReg = this.tr.crcDelim;
    this.txBits(0, shiftReg, shiftReg, 1, status);
    // Check status.
    if(status != 1) begin
      // Bit Error.
      txStatus = -1;
      return;
    end
    // Acknowledge slot. TX recessive bit and wait for acknowledge (dominant)
    // No bit stuffing on ack slot bit.
    if(this.tr.ackErr == 1) begin
      this.ifc.fr          <= 1'b1;
      this.txBits(0, 1, 0, 1, status);
      this.ifc.fr          <= 1'b0;
    end else begin
      this.txBits(0, 1, 0, 1, status);
      // Check status.
      if(status != 1) begin
        // Acknowledgment error.
        txStatus = -2;
        return;
      end
    end  
    // Acknowledge delimiter. TX recessive bit.
    // No bit stuffing on ack delimiter bit.
    if(this.tr.ackDelErr == 1) begin
      this.txBits(0, 0, 0, 1, status);
    end else begin  
      this.txBits(0, 1, 1, 1, status);
      // Check status.
      if(status != 1) begin
        // Bit Error.
        txStatus = -1;
        return;
      end
    end  
    // TX end of frame 7 consecutive recessive bits. No bit stuffing.
    shiftReg = this.tr.txEOF;
    this.txBits(0, shiftReg, shiftReg, 7, status);
    // Check status.
    if(status != 1) begin
      // Bit Error.
      txStatus = -1;
      return;
    end
    // Frame done.
    txStatus = 1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rxFrame(): Receive RX frame from RX pin.
  // rxStatus = -1: Bit stuff error
  //             1: OK
  //             2: Last bit of EOF is dominant
  //            -2: Form error.
  //            -3: CRC error.
  //            -4: Bit error.*/
  /////////////////////////////////////////////////////////////////////////////
  local task rxFrame(output int rxStatus);
    int status, rxData, expCRC;
    CAN_txrx_busTrans trErr;
    string tempStr;
    // RX reserved bits
    this.rxBits(1, (1+this.trRx.ide), rxData, status);
    // Check status
    if(status == -1) begin
      // Bit stuff error
      rxStatus = -1;
      return;
    end
    this.trRx.r0 = {31'd0, rxData[0]};
    this.trRx.r1 = {31'd0, rxData[1]};
    // RX Data length DLC.
    this.rxBits(1, 4, rxData, status);
    // Check status
    if(status == -1) begin
      // Bit stuff error
      rxStatus = -1;
      return;
    end
    this.trRx.dlc = rxData;
    // RX data if frame is data frame
    if(this.trRx.rtr == 0) begin
      int dataBuffSize;
      // If DLC > 8 receive only 8 bytes of data.
      if(this.trRx.dlc > 8) begin
        dataBuffSize = 8;
        trErr = new();
        tempStr.itoa(this.trRx.dlc);
        trErr.genErrorMsg(this.nameID, {"Info: Received data legth is ", tempStr}, "Will be forced to 8");
        this.infoBox.put(trErr);
        trErr = null;
      end else dataBuffSize = this.trRx.dlc;
      for(int i = 0; i < dataBuffSize; i++) begin
        this.rxBits(1, 8, rxData, status);
        // Check status
        if(status == -1) begin
          // Bit stuff error
          rxStatus = -1;
          return;
        end
        this.trRx.data[i] = rxData;
      end
    end
    // RX CRC sequence 15 bits
    this.rxBits(1, 15, rxData, status);
    this.trRx.crc = rxData;
    // Check status
    if(status == -1) begin
      // Bit stuff error
      rxStatus = -1;
      return;
    end
    // RX CRC delimiter 1 bit. No bit stuff check.
    this.rxBits(0, 1, rxData, status);
    // Check CRC delimiter value. It must be recessive.
    if(rxData[0] != 1'b1) begin
      // Form error
      rxStatus = -2;
      return;
    end
    // Set RX acknowledge. No bit stuffing.
    // Do not check status.
    // Ack slot
    if(this.ackErr == 0) begin
      this.txBits(0, 0, 0, 1, status);
      // Check status
      if(status != 1) begin
        // Bit error
        rxStatus = -4;
        return;
      end
    end else begin
      // Acknowledge slot error
      this.txBits(0, 1, 1, 1, status);
      // Decrement acknowledge error counter.
      this.ackErr--;
    end
    // Ack delimiter. Check status
    if(this.ackDelimiter == 0) begin
      this.txBits(0, 1, 1, 1, status);
    end else begin
      // Acknowledge delimiter error
      this.txBits(0, 0, 0, 1, status);
      // Decrement acknowledge error counter.
      this.ackDelimiter--;
    end
    // Check status
    if(status != 1) begin
      // Form error
      rxStatus = -2;
      return;
    end
    // Calculate CRC.
    expCRC = this.trRx.calcCRC();
    if((this.trRx.crc & {17'd0, {15{1'b1}}}) != (expCRC & {17'd0, {15{1'b1}}})) begin
      // CRC error
      rxStatus = -3;
      return;
    end
    // Wait for frame done. RX 7 recessive bits.
    // According to the standard the 7th RX bit can be dominant.
    // No bit stuffing.
    this.txBits(0, {{26{1'b0}}, 6'b111111}, {{26{1'b0}}, 6'b111111}, 6, status);
    // Check status
    if(status != 1) begin
      // Form error
      rxStatus = -2;
      return;
    end
    // RX the last (7th) bit of the end of frame. Ignore value.
    // According to the iso11898-1 if dominant bit detected the
    // overload frame sould be transmited!
    this.rxBits(0, 1, rxData, status);
    if(rxData[0] == 1'b0) begin
      rxStatus = 2;
      trErr = new();
      trErr.genErrorMsg(this.nameID, "Info: The last bit of EOF is dominant",
                                     "None");
      this.infoBox.put(trErr);
      trErr = null;
    end else rxStatus = 1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txBits(): TX serial bit timings.
  // status = -1: TX and RX bit mismatch. TX recessive RX dominant.
  //           1: OK.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txBits(input int stuffEn, dataIn, dataChk, bitCnt, output int status,
                    input int stuffErr = 0);
    int ptr, rxBitVal, checkVal;
    // TX bits
    ptr = bitCnt;
    repeat(bitCnt) begin
      ptr--;
      this.ifc.tx          <= dataIn[ptr];
      // Check RX value and compare with TX. Report if there is missmatch.
      #this.t_sample;
      if(this.ifc.rx != dataChk[ptr]) begin
        // TX and RX bit mismatch
        this.ifc.tx        <= 1'b1;
        #(this.t_bitTime - this.t_sample);
        status = -1;
        return;
      end
      #(this.t_bitTime - this.t_sample);
      // Bit Stuff
      if(stuffEn == 1) begin
        this.txBitStuff(dataIn[ptr], status, stuffErr);
        if(status == -1) begin
          // TX and RX bit mismatch during stuff bit
          this.ifc.tx        <= 1'b1;
          status = -1;
          return;
        end
      end
    end
    status = 1;
    this.ifc.tx        <= 1'b1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rxBits(): Receive serial rx bits.
  // status = -1: Stuff error
  //           1: OK.*/
  /////////////////////////////////////////////////////////////////////////////
  local task rxBits(input int stuffEn, bitCnt, output int dataOut, status);
    int ptr;
    bit stuffedBit;
    ptr = bitCnt;
    dataOut = 0;
    repeat(bitCnt) begin
      ptr--;
      #(this.t_sample);
      dataOut[ptr] = this.ifc.rx;
      #(this.t_bitTime-this.t_sample);
      // De stuffing. Ignore the Stuffed 6th bit.
      if(stuffEn == 1) begin
        this.rxBitStuff(dataOut[ptr], status);
        if(status == -1) begin
          // Bit Stuff error detected
          status = -1;
          return;
        end
      end
    end
    status = 1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- bitStuff(): Insert stuff bits.*/
  /////////////////////////////////////////////////////////////////////////////
  local task bitStuff(input int inWidth, bit[63:0] Din, output bit[63:0] Dout, int outWidth,
                      input int stuffErrEn = 0, output int stuffStatus);
    int stuffBitCnt;
    stuffStatus = 0;
    outWidth = inWidth;
    stuffBitCnt = 64;
    for(int i = inWidth-1; i >= 0; i--) begin
      stuffBitCnt--;
      Dout[stuffBitCnt] = Din[i];
      // Bit level counter
      if((Din[i] == 1'b1) && (this.txBitStuffCnt > 0)) this.txBitStuffCnt++;
      else if((Din[i] == 1'b1) && (this.txBitStuffCnt < 0)) this.txBitStuffCnt = 1;
      else if((Din[i] == 1'b0) && (this.txBitStuffCnt < 0)) this.txBitStuffCnt--;
      else this.txBitStuffCnt = -1;
      // Insert stuff bit
      if(this.txBitStuffCnt == 5) begin
        stuffBitCnt--;
        if(stuffErrEn == 1)begin
          stuffStatus = 1;
          Dout[stuffBitCnt] = 1'b1;
          this.txBitStuffCnt = 1;
        end else begin
          Dout[stuffBitCnt] = 1'b0;
          this.txBitStuffCnt = -1;
        end
        outWidth++;
      end else if(this.txBitStuffCnt == -5) begin
        stuffBitCnt--;
        if(stuffErrEn == 1)begin
          stuffStatus = 1;
          Dout[stuffBitCnt] = 1'b0;
          this.txBitStuffCnt = -1;
        end else begin
          Dout[stuffBitCnt] = 1'b1;
          this.txBitStuffCnt = 1;
        end
        outWidth++;
      end
    end
    Dout = Dout >> (64-outWidth);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rxBitStuff(): Remove and check received stuff bits.*/
  /////////////////////////////////////////////////////////////////////////////
  local task rxBitStuff(input bit rxBit, output int status);
    bit stuffBit;
    // RX Bit level counter
    if((rxBit == 1'b1) && (this.rxBitStuffCnt > 0)) this.rxBitStuffCnt++;
    else if((rxBit == 1'b1) && (this.rxBitStuffCnt < 0)) this.rxBitStuffCnt = 1;
    else if((rxBit == 1'b0) && (this.rxBitStuffCnt < 0)) this.rxBitStuffCnt--;
    else this.rxBitStuffCnt = -1;
    // RX and check stuff bit
    if((this.rxBitStuffCnt == 5) || (this.rxBitStuffCnt == -5)) begin
      #this.t_sample;
      stuffBit = this.ifc.rx;
      #(this.t_bitTime-this.t_sample);
      if((this.rxBitStuffCnt == 5) && (stuffBit == 1'b1) ||
         (this.rxBitStuffCnt == -5) && (stuffBit == 1'b0)) begin
        // Bit stuff error
        status = -1;
        return;
      end
      if(this.rxBitStuffCnt == 5) this.rxBitStuffCnt = -1;
      else this.rxBitStuffCnt = 1;
    end
    status = 1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txBitStuff(): TX stuff bits if necessary.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txBitStuff(input bit txBit, output int status, input int stuffErr = 0);
    bit stuffBit;
    // TX Bit level counter
    if((txBit == 1'b1) && (this.txBitStuffCnt > 0)) this.txBitStuffCnt++;
    else if((txBit == 1'b1) && (this.txBitStuffCnt < 0)) this.txBitStuffCnt = 1;
    else if((txBit == 1'b0) && (this.txBitStuffCnt < 0)) this.txBitStuffCnt--;
    else this.txBitStuffCnt = -1;
    // TX stuff bit if necessary
    if((this.txBitStuffCnt == 5) || (this.txBitStuffCnt == -5)) begin
      stuffBit = (this.txBitStuffCnt != 5);
      if(stuffErr == 1) stuffBit = ~stuffBit;
      if(this.txBitStuffCnt == 5) this.txBitStuffCnt = -1;
      else this.txBitStuffCnt = 1;
      this.ifc.tx <= stuffBit;
      #this.t_sample;
      if(this.ifc.rx != stuffBit) begin
        // TX and RX bit missmatch
        status = -1;
        #(this.t_bitTime-this.t_sample);
        return;
      end
      #(this.t_bitTime-this.t_sample);
    end
    status = 1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txOverloadFrame(): TX overload frame.
  // txStatus = 1: OK.
  //           -2: bus Off.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txOverloadFrame(input string source, output int txStatus);
    this.txErrorFrame(2, source, txStatus);      
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txErrorFlag(): TX active error, passive error or overload flag.
  // txStatus = 1: OK.
  //           -1: Bus is off.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txErrorFlag(input int errMode, string source, output int txStatus);
    int eqPolCnt;
    string msg;
    do begin
      // Select msg
      if(errMode == 0) msg = "active error";
      else msg = "overload";
      // Node is passive
      if(errMode == 1) begin
        errMode = this.errMode;
        if(this.debugEn == 1) begin
          $display("%s-Transmit passive error flag. Source is %s, simulation time=%0d", this.nameID, source, $time);
          $display("%s-Wait for 6 consecutive bits of equal polarity.", this.nameID);          
        end
        // Transmit passive error flag
        eqPolCnt = 0;
        this.ifc.tx <= 1'b1;
        // Wait for 6 consecutive bits of equal polarity
        while((eqPolCnt < 6) && (eqPolCnt > -6)) begin
          #(this.t_sample);
          eqPolCnt = this.equalPolCount(eqPolCnt, this.ifc.rx);
          #(this.t_bitTime-this.t_sample);  
        end
        if(this.debugEn == 1) begin
          $display("%s-Transmission of passive error flag is done. Source is %s, simulation time=%0d",
                    this.nameID, source, $time);          
        end 
      end
      txStatus = 1;                                
      // Node is active. Active error or overload flag. 
      if((errMode == 0) || (errMode == 2)) begin
        errMode = this.errMode;
        // Transmit active error flag(6 consecutive dominant bits). 
        if(this.debugEn == 1) begin
          $display("%s-Transmit %s flag(6 consecutive dominant bits). Source is %s, simulation time=%0d", 
                    this.nameID, msg, source, $time);
        end
        
        for(int i = 5; i >= 0; i--) begin
          this.ifc.tx <= this.activeErrFlag[i];
          #(this.t_sample);
          if((this.ifc.rx == 1'b1) && (this.activeErrFlag[i] == 1'b0)) begin
            #(this.t_bitTime-this.t_sample);
            $display("%s-Bit Error during %s flag transmission. Source is %s, simulation time=%0d", 
                    this.nameID, msg, source, $time);
            // Rule 4, 5
            txStatus = this.errCountIncr(source, 8); 
            // Check for bus off
            if(txStatus == -1) begin
              if(this.debugEn == 1) begin
                $display("%s-Bus off condition detected. Source is %s, simulation time=%0d",
                          this.nameID, source, $time);          
              end
            end
            break;
          end
          #(this.t_bitTime-this.t_sample);
          this.activeErrFlag[i] = 1'b0;
        end
        if((this.debugEn == 1) && (txStatus == 1)) begin
          $display("%s-Transmission of %s flag is done. Source is %s, simulation time=%0d",
                    this.nameID, msg, source, $time);          
        end      
      end
    end while(txStatus == 0);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txErrorFrame(): TX error or overload frame.
  // txStatus = 1: OK.
  //           -1: Bus Off.*/
  /////////////////////////////////////////////////////////////////////////////
  local task txErrorFrame(input int errMode, string source="Transmitter", output int txStatus);
    int status;
    bit frameDone;
    int eqPolCnt;
    CAN_txrx_busTrans trErr_m;
    txStatus = 1;
    do begin
      // TX error overload flag
      this.txErrorFlag(errMode, source, status);
      // Check status
      if(status == -1) begin
        // Bus off condition
        txStatus = -1;
        return;
      end
      this.ifc.tx <= 1'b1;  
      // Check 1st bit after sending error flag. Rule 2. Only for receiver
      frameDone = 0;
      if((source=="Receiver") && (errMode != 2)) begin
        #(this.t_sample);
        frameDone = this.ifc.rx;
        #(this.t_bitTime-this.t_sample);
        if(frameDone == 1'b0) begin
          // Rule 2
          txStatus = this.errCountIncr(source, 8); 
          errMode = this.errMode;
          if(txStatus == -1) begin
            return;
          end
        end
      end
      // Wait for RX 1st recessive bit. It is the 1st bit
      // of error/overload delimiter.
      while(frameDone == 1'b0) begin
        #(this.t_sample);
        frameDone = this.ifc.rx;
        #(this.t_bitTime-this.t_sample);
        if(frameDone == 1'b0) eqPolCnt++;
        // Rule 6.
        if(eqPolCnt == 8) begin
          eqPolCnt = 0;
          txStatus = this.errCountIncr(source, 8);
          errMode = this.errMode;
          if(txStatus == -1) begin
            return;
          end
        end          
      end 
      if(this.debugEn == 1) begin
        $display("%s-The 1st bit of the error/overload delimiter is received. Source is %s, simulation time=%0d",
                  this.nameID, source, $time);          
      end
      // RX remaining 7 recessive bits. The last 8th bit of error delimiter can be dominant.
      // RX 6 bits of the error delimiter. If one of them is dominant then error
      // frame must be generated.
      // No bit stuffing.
      txStatus = 1;
      this.txBits(0, this.delErrFlag[31:1], this.delErrFlag[31:1], 6, status);
      
      if((status == -1) || (this.delErrFlag[31:1] != {25'd0, {6{1'b1}}})) begin
        this.delErrFlag[31:1] = {25'd0, {6{1'b1}}};
        // Form error.
        trErr_m = new();
        trErr_m.genErrorMsg(this.nameID, "Error: Form error in error/overload delimiter detected", "None");
        this.formErrBox.put(trErr_m);
        trErr_m = null;
        if(this.debugEn == 1) begin
          $display("%s-Form error in error/overload delimiter detected. Simulation time=%0d", this.nameID, $time);
        end        
        // Form error. Rule 1, 3
        if(source == "Transmitter") txStatus = this.errCountIncr(source, 8);
        else txStatus = this.errCountIncr(source, 1); 
        if(txStatus == -1) begin
          return;
        end
      end else begin
        // No bit stuffing.
        this.txBits(0, this.delErrFlag[0], this.delErrFlag[0], 1, status);
        if((status == -1) || (~this.delErrFlag[0])) begin
          this.delErrFlag[0] = 1'b1;
          this.ovrldCnt++;
          // Not an error case. Generate overload frame.
          txStatus = 2;
          errMode = 2;
        end
      end  
    end while(txStatus != 1);
    // Done.
    txStatus = 1;
    if(this.debugEn == 1) begin
      $display("%s-The error/overload frame done. Source is %s, simulation time=%0d",
                this.nameID, source, $time);          
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- errCountIncr(): Modify error counters(tec/rec).*/
  /////////////////////////////////////////////////////////////////////////////
  function int errCountIncr(input string source, int val);
    errCountIncr = 0;
    if(source=="Transmitter") begin
      this.tec+=val;
    end
    if(source=="Receiver") begin
      this.rec+=val;
    end  
    if((this.rec > this.passiveModeVal) || (this.tec > this.passiveModeVal)) begin
      // Node goes passive
      this.errMode = 1;
    end  
    if((this.rec > this.busOffModeVal) || (this.tec > this.busOffModeVal)) begin
      // Bus Off
      this.errMode = 2;
      errCountIncr = -1;
    end  
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- equalPolCount(): Consecutive equal bit polarity counter.*/
  /////////////////////////////////////////////////////////////////////////////
  function int equalPolCount(int eqPolCnt, bit bitVal);
    if(eqPolCnt == 0) begin
      if(bitVal == 1'b1) equalPolCount = 1;
      else equalPolCount = -1;
    end
    if(eqPolCnt < 0) begin
      if(bitVal == 1'b1) equalPolCount = 1;
      else equalPolCount = eqPolCnt - 1;
    end
    if(eqPolCnt > 0) begin
      if(bitVal == 1'b1) equalPolCount = eqPolCnt + 1;
      else equalPolCount = -1;
    end
  endfunction
  //
endclass // CAN_txrx_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class CAN_txrx_env:
///////////////////////////////////////////////////////////////////////////////
class CAN_txrx_env extends CAN_txrx_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local int envStarted;
  local int st;
  local int unsigned rdDataPtr;
  int txOvldFrameCnt;
  time t_readTimeOut;
  // Data length field value during remote frames.
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to virtual. Set data bus size.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(virtual can_txrx_if ifc, string nameID);
    this.envStarted          = 0;
    super.ifc                = ifc;
    super.trInBox            = new();
    super.trRFBox            = new();
    super.statusBox          = new();
    super.infoBox            = new();
    super.crcErrBox          = new();
    super.stuffErrBox        = new();
    super.formErrBox         = new();
    super.bitErrBox          = new();
    super.ackErrBox          = new();
    super.rxDoneSem          = new();
    super.trRxDbgBox         = new();
    super.t_bitTime          = 1us;
    super.t_sample           = (3*super.t_bitTime/4);
    super.nameID             = nameID;
    this.txOvldFrameCnt      = 0;
    super.rxOvldFrameCnt     = 0;
    this.t_readTimeOut       = 1000us;
    super.debugEn            = 0;
    super.startTXatIFS3bit   = 1;
    super.ackErr             = 0;
    super.ackDelimiter       = 0;
    super.tec                = 0;
    super.rec                = 0;
    super.errMode            = 0;
    super.passiveModeVal     = 127;
    super.busOffModeVal      = 1000000;
    super.recVal             = 119;
    super.ovrldCnt           = 0;
    super.activeErrFlag      = 0;
    super.delErrFlag         = {25'd0, {7{1'b1}}};
    super.ifsVal             = 3;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the CAN bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(this.envStarted == 0) begin
      super.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setDebugMode(): Enable/Disable debug mode.*/
  /////////////////////////////////////////////////////////////////////////////
  task setDebugMode(int debugEn);
    super.debugEn = debugEn;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setIdle(): Hold CAN in idle for the specified time.*/
  /////////////////////////////////////////////////////////////////////////////
  task setIdle(time idleTime);
    CAN_txrx_busTrans tr_m;
    tr_m               = new();
    tr_m.TrType        = CAN_txrx_busTrans::IDLE;
    tr_m.idleTime      = idleTime;
    super.trInBox.put(tr_m);
    tr_m               = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txDebugFrame(): TX debug frame.*/
  /////////////////////////////////////////////////////////////////////////////
  task txDebugFrame(input bit[511:0] debugData, int debugDataSize, bit[511:0] frEn = 512'd0);
    CAN_txrx_busTrans tr_m;
    tr_m = new();
    tr_m.TrType  = CAN_txrx_busTrans::DEBUG_FRAME;
    tr_m.debugData = debugData;
    tr_m.debugDataCnt = debugDataSize;
    tr_m.frEn = frEn;
    super.trInBox.put(tr_m);
    tr_m         = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rxDebugFrame(): RX debug frame.*/
  /////////////////////////////////////////////////////////////////////////////
  task rxDebugFrame(output bit[511:0] debugData);
    CAN_txrx_busTrans tr_m, trErr;
    // Wait for debug frame is ready.
    fork
      // Check for timeout.
      #this.t_readTimeOut;
      super.trRxDbgBox.peek(tr_m);
    join_any
    if(super.trRxDbgBox.num() == 0) begin
      trErr = new();
      trErr.genErrorMsg(super.nameID, "ERROR: Debug frame Read Time Out Detected", "None");
      super.statusBox.put(trErr);
      trErr = null;
      return;
    end
    super.trRxDbgBox.get(tr_m);
    debugData = tr_m.debugDataRx;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txDataFrame(): TX data frame.*/
  /////////////////////////////////////////////////////////////////////////////
  task txDataFrame(input int identifier11, identifier18, ide, bit8 dataTx[],
                                          //ackdelErr ackErr  StuffErr EOF    CRC d CRC err R1/R0  SRR   DLC
                   bit[18:0] paramTx =    {1'b0,      1'b0,   1'b0, 7'h7f, 1'b1, 1'b0, 2'b00, 1'b1, 4'd0},
                   int errCnt = 1, bit ARFR = 1'b0, int rtr = 0);
    CAN_txrx_busTrans tr_m, trInfo;
    int dlen;
    dlen = dataTx.size;
    // If dataTx.size is more than 8 bytes truncate it up to 8 bytes.
    if((dlen > 8) && (rtr == 0)) begin
      dlen = 8;
      // Generate message
      if(super.debugEn == 1) begin
        $display("%s-Info: TX Data buffer size is more than 8 bytes and will be truncated up to 8.", super.nameID);
      end
    end
    // Put data information to the mailbox
    tr_m = new();
    tr_m.TrType  = CAN_txrx_busTrans::DATA_FRAME;
    tr_m.identifier11 = identifier11;
    tr_m.identifier18 = identifier18;
    tr_m.srr          = {31'd0, paramTx[4]};
    tr_m.rtr          = rtr;
    if(rtr == 0) begin
      if(paramTx[3:0] == 4'd0) tr_m.dlc          = dlen;
      else if(paramTx[3:0] > 4'd8) tr_m.dlc      = {28'd0, paramTx[3:0]};
      else tr_m.dlc                              = $urandom_range(15, 9);
    end else begin
      tr_m.dlc      = {28'd0, paramTx[3:0]};
      dlen = 0;
    end  
    tr_m.r0           = {31'd0, paramTx[5]};
    tr_m.r1           = {31'd0, paramTx[6]};
    for(int i = 0; i < dlen; i++) tr_m.data[i] = dataTx[i];
    tr_m.ide = ide;
    // Calculate CRC
    tr_m.crc = tr_m.calcCRC();
    // Corrupt CRC
    if(paramTx[7] == 1'b1) tr_m.crc = ~tr_m.crc;
    tr_m.crcDelim = {31'd0, paramTx[8]};
    tr_m.ackErr = paramTx[17]; 
    tr_m.ackDelErr = paramTx[18];
    // TX End Of Frame
    tr_m.txEOF = {25'd0, paramTx[15:9]};
    // Enable/Disable TX bit stuff error
    tr_m.stuffErrEn = {31'd0, paramTx[16]};
    // Request overload frame. Set this.txOvldFrameCnt = 0 if no overload frame
    // after remote frame is required.
    tr_m.ovldFrameCnt = this.txOvldFrameCnt;
    tr_m.errCnt = errCnt;
    // Put transaction to the mailbox
    if(ARFR == 1'b1) begin
      super.trRFBox.put(tr_m);
    end else begin
      super.trInBox.put(tr_m);
    end
    tr_m         = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- txRemoteFrame(): TX remote frame.*/
  /////////////////////////////////////////////////////////////////////////////
  task txRemoteFrame(input int identifier11, identifier18, ide,
                     bit[18:0] paramTx =    {1'b0, 1'b0, 1'b0, 7'h7f, 1'b1, 1'b0, 2'b11, 1'b1, 4'd0});
    bit8 dataTx[];                 
    this.txDataFrame(identifier11, identifier18, ide, dataTx, paramTx,
                     1, 1'b0, 1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- putARFR_Buff(): Put data frame to the ARFR(Automatically Remote Frame
  // Response) buffer. The data frame from ARFR buffer will be transmitted
  // automatically when corresponding remote frame received. This buffer acts
  // as a FIFO. The first frame written here will be transmitted first.*/
  /////////////////////////////////////////////////////////////////////////////
  task putARFR_Buff(input int identifier11, identifier18, ide, bit8 dataTx[],
                                           //ackdelErr ackErr StuffErr EOF    CRC d CRC err R1/R0  SRR   DLC
                    bit[18:0] paramTx =    {1'b0,       1'b0,   1'b0, 7'h7f, 1'b1, 1'b0, 2'b00, 1'b1, 4'd0});
    this.txDataFrame(identifier11, identifier18, ide, dataTx, paramTx, 1, 1'b1, 0);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getARFR_BuffSize(): Returns the number of frames inside the ARFR buffer.*/
  /////////////////////////////////////////////////////////////////////////////
  function int getARFR_BuffSize();
    getARFR_BuffSize = super.trRFBox.num();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- configGlobal(): Global config.*/
  /////////////////////////////////////////////////////////////////////////////
  task configGlobal(input time t_bitTime, t_sample, int rstInfoBox = 0, 
                    int rstErrBox = 0, tec=-1, rec=-1, errMode=-1, 
                    passiveModeVal = 127);
    CAN_txrx_busTrans tr_m;                
    super.t_bitTime          = t_bitTime;
    super.t_sample           = t_sample;
    // Reset info buffer.
    if(rstInfoBox == 1) begin
      while(super.infoBox.num() != 0) super.infoBox.get(tr_m);    
    end
    // Reset error buffers and counters.
    if(rstErrBox == 1) begin
      while(super.crcErrBox.num() != 0) super.crcErrBox.get(tr_m);
      while(super.bitErrBox.num() != 0) super.bitErrBox.get(tr_m);
      while(super.formErrBox.num() != 0) super.formErrBox.get(tr_m);
      while(super.stuffErrBox.num() != 0) super.stuffErrBox.get(tr_m);
      while(super.ackErrBox.num() != 0) super.ackErrBox.get(tr_m);
      super.tec = 0;
      super.rec = 0;
      super.errMode = 0;    
      super.ovrldCnt = 0;
    end    
    super.passiveModeVal     = passiveModeVal;
    // Error counters
    if(tec != -1) super.tec = tec;
    if(rec != -1) super.rec = rec;
    if(errMode != -1) super.errMode = errMode;
    
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- configOverloadFrames(): Set the amount of the overload frames which will
  // be transmitted after each data/remote frames.*/
  /////////////////////////////////////////////////////////////////////////////
  task configOverloadFrames(input int txOvld, rxOvld);
    this.txOvldFrameCnt  = txOvld;
    super.rxOvldFrameCnt = rxOvld;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- configTransmitter(): Configure transmitter.
  // startTXatIFS3bit: enable start transmission at the 3rd bit of intermission.*/
  /////////////////////////////////////////////////////////////////////////////
  task configTransmitter(int startTXatIFS3bit, activeErrFlag=0, delErrFlag={25'd0, {7{1'b1}}},
                        ifsVal = 3);
    super.startTXatIFS3bit = startTXatIFS3bit;
    super.activeErrFlag = activeErrFlag;
    super.delErrFlag = delErrFlag;
    super.ifsVal = ifsVal;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- configReceiver(): Configure receiver.
  // ackErr      : enable acknowledge slot error. After each error the ackErr is 
  //               decremented. If it is not zero ack error is generated.
  // ackDelimiter: enable acknowledge delimiter error. After each error the 
  //               ackDelimiter is decremented. If it is not zero ack delimiter 
  //               error is generated.*/
  /////////////////////////////////////////////////////////////////////////////
  task configReceiver(time t_readTimeOut, int ackErr, ackDelimiter);
    this.t_readTimeOut = t_readTimeOut;
    super.ackErr = ackErr;
    super.ackDelimiter = ackDelimiter;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getRxDataFrame(): Get RX data frame.*/
  /////////////////////////////////////////////////////////////////////////////
  task getRxDataFrame(input int identifier11, identifier18, ide, output bit8 data[]);
    CAN_txrx_busTrans tr_m, trErr;
    int trRxBoxPtr_m;
    string tempStr1, tempStr2, tempStr;
    tempStr1.itoa(identifier11);
    tempStr2.itoa(identifier18);
    data.delete();
    if(ide == 1) begin
      trRxBoxPtr_m = {2'd0, 1'b1, identifier18[17:0], identifier11[10:0]};
      $display("%s: Wait for extended frame with ID11=%0d and ID18=%0d", super.nameID, identifier11, identifier18);
      tempStr = {"Wait for extended frame with ID11=", tempStr1, " and ID18=", tempStr2};
    end else begin
      trRxBoxPtr_m = {21'd0, identifier11[10:0]};
      $display("%s: Wait for standard frame with ID11=%0d", super.nameID, identifier11);
      tempStr = {"Wait for standard frame with ID11=", tempStr1};
    end
    // Wait for frame is ready.
    fork
      // Check for timeout.
      #this.t_readTimeOut;
      begin
        if(!super.trRxBox.exists(trRxBoxPtr_m)) begin
          this.trRxBox[trRxBoxPtr_m] = new();
        end  
        super.trRxBox[trRxBoxPtr_m].peek(tr_m);
      end  
    join_any
    if(super.trRxBox[trRxBoxPtr_m].num() == 0) begin
      trErr = new();
      trErr.genErrorMsg(super.nameID, "ERROR: Read Time Out Detected", tempStr);
      super.statusBox.put(trErr);
      trErr = null;
      return;
    end else begin
      super.trRxBox[trRxBoxPtr_m].get(tr_m);
      if(tr_m.dlc > 8) tr_m.dlc = 8;
      data = new[tr_m.dlc];
      for(int i = 0; i < tr_m.dlc; i++) begin
        data[i] = tr_m.data[i];
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- checkErrors(): Check error buffers and counters.*/
  /////////////////////////////////////////////////////////////////////////////
  function int checkErrors(string errType = "ALL");
    checkErrors = 0;
    if((errType == "ALL") || (errType == "CRC")) begin
      checkErrors += super.crcErrBox.num();
    end 
    if((errType == "ALL") || (errType == "BIT")) begin
      checkErrors += super.bitErrBox.num();
    end 
    if((errType == "ALL") || (errType == "STUFF")) begin
      checkErrors += super.stuffErrBox.num();
    end 
    if((errType == "ALL") || (errType == "FORM")) begin
      checkErrors += super.formErrBox.num();
    end 
    if((errType == "ALL") || (errType == "ACK")) begin
      checkErrors += super.ackErrBox.num();
    end 
    if(errType == "TEC") begin
      checkErrors = super.tec;
    end 
    if(errType == "REC") begin
      checkErrors = super.rec;
    end 
    if((errType != "ALL") && (errType != "CRC") && (errType != "BIT") &&
       (errType != "STUFF") && (errType != "FORM") && (errType != "ACK") &&
       (errType != "TEC") && (errType != "REC")) begin
      $display("%s- Error: Wrong argument for function checkErrors", super.nameID);
      checkErrors = -1;
    end
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- checkInfoBox(): Return info box size.*/
  /////////////////////////////////////////////////////////////////////////////
  function int checkInfoBox(string infoType = "infoBox");
    if(infoType == "infoBox") begin
      checkInfoBox = super.infoBox.num();
    end else if(infoType == "ovld") begin
      checkInfoBox = super.ovrldCnt;
    end    
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- envDone(): Report status and exit.*/
  /////////////////////////////////////////////////////////////////////////////
  task envDone();
    $display("--------------------------------------------------------");
    if (this.printStatus() != 0) begin
      $display("%s-Report status: Unexpected errors detected", super.nameID);
    end else begin
      $display("%s-Report status: No Unexpected errors detected", super.nameID);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print all errors. Return 0 if no errors.*/
  /////////////////////////////////////////////////////////////////////////////
  function int printStatus();
    CAN_txrx_busTrans tr;
    tr = new();
    printStatus = 0;
    while(super.statusBox.num() != 0)begin
      void'(super.statusBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    
    while(super.crcErrBox.num() != 0)begin
      void'(super.crcErrBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    
    while(super.bitErrBox.num() != 0)begin
      void'(super.bitErrBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    
    while(super.stuffErrBox.num() != 0)begin
      void'(super.stuffErrBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    
    while(super.formErrBox.num() != 0)begin
      void'(super.formErrBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    
    while(super.ackErrBox.num() != 0)begin
      void'(super.ackErrBox.try_get(tr));
      $display(tr.failedTr);
      printStatus = -1;
    end
    tr = null;
  endfunction
  //
endclass // CAN_txrx_env
//
endpackage
