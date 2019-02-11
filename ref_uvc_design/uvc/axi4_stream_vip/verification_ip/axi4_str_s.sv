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

package AXI4STR_S;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [255:0]  bit256;
typedef class AXI4STR_s_busTrans;
typedef class AXI4STR_s_busBFM;
typedef class AXI4STR_s_env;
typedef mailbox #(AXI4STR_s_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  bit256                              tdata;
  bit                                 tlast;
  bit32                               tstrb;
  bit32                               tkeep;
  bit256                              tuser;
  bit8                                tid;
  bit8                                tdest;
  string                              failedTr;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  //
endclass // AXI4STR_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // Configuration variables
  string    id_name;
  int blockSize;
  int readyDelayHigh;
  int readyDelayLow;
  int minReadyDelayHigh;
  int maxReadyDelayHigh;
  int minReadyDelayLow;
  int maxReadyDelayLow;
  int treadyCnt;
  int treadyDelayEn;
  /////////////////////////////////////////////////////////////////////////////
  virtual axi4_str_s_if ifc;
  TransMBox trOutBox, statusBox;
  local AXI4STR_s_busTrans tr;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    this.trOutBox          = new();
    this.statusBox         = new();
    this.readyDelayHigh    = 0;
    this.readyDelayLow     = 0;
    this.minReadyDelayHigh = 0;
    this.maxReadyDelayHigh = 0;
    this.minReadyDelayLow  = 0;
    this.maxReadyDelayLow  = 0;
    this.treadyCnt         = 0;
    this.treadyDelayEn     = 0;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start main loop.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
    fork
      this.run_loop();
    join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genRandomTiming(): Generates random values for bus timing.*/
  /////////////////////////////////////////////////////////////////////////////
  function void genRandomTiming();
    this.readyDelayHigh =  $urandom_range(this.maxReadyDelayHigh, this.minReadyDelayHigh);
    this.readyDelayLow  =  $urandom_range(this.maxReadyDelayLow, this.minReadyDelayLow);
    if(this.readyDelayHigh == 0) this.readyDelayHigh = 1;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop(): Main loop.*/
  /////////////////////////////////////////////////////////////////////////////
  local task run_loop();
    // Init
    this.ifc.tready        <= 1'b1;
    // Clock alignment
    this.ifc.clockAlign();
    // Start main loop
    forever begin
      this.ifc.cb.tready   <= 1'b1;
      do begin
        @this.ifc.cb;
      end while((this.ifc.cb.tvalid !== 1'b1));
      // Data processing.
      this.tr               = new();
      // Get transaction from master.
      this.tr.tdata         = this.ifc.cb.tdata;
      this.tr.tlast         = this.ifc.cb.tlast;
      this.tr.tstrb         = this.ifc.cb.tstrb;
      this.tr.tkeep         = this.ifc.cb.tkeep;
      this.tr.tuser         = this.ifc.cb.tuser;
      this.tr.tid           = this.ifc.cb.tid;
      this.tr.tdest         = this.ifc.cb.tdest;
      this.trOutBox.put(this.tr);
      this.tr               = null;
      this.ifc.cb.tready   <= 1'b0;
      this.treadyCnt++;
      if((this.treadyCnt == this.readyDelayHigh) && (this.treadyDelayEn != 0)) begin
        repeat(this.readyDelayLow) @this.ifc.cb;
        this.treadyCnt = 0;
        this.genRandomTiming();
      end
    end
  endtask
  //
endclass // AXI4STR_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_s_env:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_s_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local AXI4STR_s_busTrans tr;
  local AXI4STR_s_busBFM   axiBfm;
  local int envStarted;
  local int timeOut;
  int          userBitPerByte;
  local bit8   userBuf[];
  local bit8   tid;
  local bit8   tdest;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Takes physical interface as an input value and connects it to
  // virtual interface. Create transaction mailboxes.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual axi4_str_s_if ifc, int blockSize = 4, userBitPerByte = 1);
    this.axiBfm                  = new();
    this.axiBfm.ifc              = ifc;
    this.axiBfm.blockSize        = blockSize;
    this.envStarted              = 0;
    this.timeOut                 = 10000;
    this.axiBfm.id_name          = id_name;
    this.userBitPerByte          = userBitPerByte;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(this.envStarted == 0) begin
      this.axiBfm.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Set 'ready' random delays. To disable random delays set all
  //  arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRandDelay(int minReadyDelayHigh=0, maxReadyDelayHigh=0, minReadyDelayLow=0, maxReadyDelayLow=0);
    this.axiBfm.minReadyDelayHigh = minReadyDelayHigh;
    this.axiBfm.maxReadyDelayHigh = maxReadyDelayHigh;
    this.axiBfm.minReadyDelayLow  = minReadyDelayLow;
    this.axiBfm.maxReadyDelayLow  = maxReadyDelayLow;
    this.axiBfm.treadyCnt         = 0;
    if((minReadyDelayHigh==0)&&(maxReadyDelayHigh==0)&&(minReadyDelayLow==0)&&(maxReadyDelayLow==0)) begin
      this.axiBfm.treadyDelayEn   = 0;
    end else begin
      this.axiBfm.treadyDelayEn   = 1;
    end
    this.axiBfm.genRandomTiming();
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTimeOut(): Set data read timeout.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTimeOut(int timeOut);
    this.timeOut = timeOut;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getSingleTransfer(): Get single transfer from the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task getSingleTransfer(output bit256 tdata, output bit32 tkeep, tstrb, output int tlast, 
                         output bit256 tuser, output bit8 tid, tdest);
    AXI4STR_s_busTrans trErr;
    string tempStr;
    fork:readTimeOut
      begin
        repeat(this.timeOut) @this.axiBfm.ifc.cb;
        trErr = new();
        $display("%s-: Error: Read TimeOut detected (no tvalid signal) at sim time %0d", this.axiBfm.id_name, $time());
        tempStr.itoa($time);
        trErr.failedTr = "Error: Read TimeOut detected (no tvalid signal) at sim time ";
        trErr.failedTr     = {this.axiBfm.id_name, "-: ", trErr.failedTr, tempStr, "ns"};
        this.axiBfm.statusBox.put(trErr);
        trErr = null;
        // If timeout inform the higher level function
        tlast   = -1;
      end
      begin
        this.axiBfm.trOutBox.get(this.tr);
        tlast     = 0;
        tlast[0]  = this.tr.tlast;
        tdata     = this.tr.tdata;
        tkeep     = this.tr.tkeep;
        tstrb     = this.tr.tstrb;
        tuser     = this.tr.tuser;
        tid       = this.tr.tid;
        tdest     = this.tr.tdest;
      end
    join_any
    disable readTimeOut;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readPacket(): Read data packet.*/
  /////////////////////////////////////////////////////////////////////////////
  task readData(output bit8 outBuff[]);
    bit256 tdata;
    bit32  tkeep;
    bit32  tstrb;
    int    tlast;
    int    arrayPtr;
    int    userBufPtr;
    bit8   inByte;
    bit256 tuser;
    int    bnum;
    outBuff = new[0];
    arrayPtr = 0;
    userBufPtr = 0;
    this.userBuf = new[0];
    do begin
      this.getSingleTransfer(tdata, tkeep, tstrb, tlast, tuser, this.tid, this.tdest);
      bnum = 0;
      if(tlast != -1) begin
        for (int i = 0; i < 32; i++) begin
          if((i < this.axiBfm.blockSize) && (tkeep[i] == 1'b1)) begin
            outBuff = new[arrayPtr+1](outBuff);
            outBuff[arrayPtr] = tdata[8*i+:8];
            arrayPtr++;
          end
          // User data
          if(i < this.axiBfm.blockSize) begin
            if(tkeep[i] == 1'b1) begin
              userBufPtr++;
              this.userBuf = new[userBufPtr](this.userBuf);
            end
            for(int k = 0; k < 8; k++)begin
              if(k < this.userBitPerByte) begin
                inByte[k] = tuser[bnum];
                bnum++;
              end else begin
                inByte[k] = 1'b0;
              end
            end
            if(tkeep[i] == 1'b1) begin
              this.userBuf[userBufPtr-1] = inByte;
            end  
          end
        end
      end
    end while(tlast == 0);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readUserBuf(): Read user buffer.*/
  /////////////////////////////////////////////////////////////////////////////
  task readUserBuf(output bit8 outBuff[]);
    outBuff = new[this.userBuf.size()];
    for(int i = 0; i < this.userBuf.size(); i++) begin
      outBuff[i] = this.userBuf[i];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getTID_TDEST(): Read TID and TDEST.*/
  /////////////////////////////////////////////////////////////////////////////
  task getTID_TDEST(output int tid, tdest);
    tid = 0;
    tdest = 0;
    tid[7:0] = this.tid;
    tdest[7:0] = this.tdest;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print poll timeout errors.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    this.tr = new();
    statusBoxSize = this.axiBfm.statusBox.num();
    while(this.axiBfm.statusBox.num() != 0)begin
      void'(this.axiBfm.statusBox.try_get(this.tr));
      $display(this.tr.failedTr);
    end
    this.tr = null;
    $display("The %s slave VIP has %d errors", this.axiBfm.id_name, statusBoxSize);
  endfunction
  //
endclass // AXI4STR_s_env
//
endpackage
