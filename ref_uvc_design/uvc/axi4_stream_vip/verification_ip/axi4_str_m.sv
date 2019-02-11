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

package AXI4STR_M;
typedef bit [7:0]    bit8;
typedef bit [255:0]  bit256;
typedef bit [31:0]   bit32;
typedef class AXI4STR_m_busTrans;
typedef class AXI4STR_m_busBFM;
typedef class AXI4STR_m_env;
typedef mailbox #(AXI4STR_m_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_m_busTrans:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_m_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  int                                 TrNum;
  enum {WRITE, IDLE, WAIT}            TrType;
  bit256                              tdata;
  bit                                 tlast;
  bit32                               tstrb;
  bit32                               tkeep;
  bit256                              tuser;
  bit8                                tid;
  bit8                                tdest;
  string                              failedTr;
  int                                 idleCycles;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  //
endclass // AXI4STR_m_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_m_busBFM:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_m_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // Configuration variables
  string    id_name;
  int       blockSize;
  int       readyTimeOut;
  int       burstDelayEn;
  int       maxBurstLen;
  int       waitCycles;
  int       maxBurst, minBurst;
  int       maxWait, minWait;
  int       burstCnt;
  /////////////////////////////////////////////////////////////////////////////
  virtual axi4_str_m_if ifc;
  TransMBox trInBox, trOutBox, statusBox;
  local AXI4STR_m_busTrans tr;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    this.trInBox         = new();
    this.trOutBox        = new();
    this.statusBox       = new();
    this.readyTimeOut    = 0;
    this.burstDelayEn    = 0;
    this.maxBurstLen     = 0;
    this.waitCycles      = 0;
    this.burstCnt        = 0;
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
    this.maxBurstLen =  $urandom_range(this.maxBurst, this.minBurst);
    this.waitCycles  =  $urandom_range(this.maxWait, this.minWait);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop(): Main loop.*/
  /////////////////////////////////////////////////////////////////////////////
  local task run_loop();
    // Init
    this.ifc.tdata          <= 256'd0;
    this.ifc.tvalid         <= 1'b0;
    this.ifc.tlast          <= 1'b0;
    this.ifc.tkeep          <= 32'd0;
    this.ifc.tstrb          <= 32'd0;
    this.ifc.tuser          <= 256'd0;
    this.ifc.tid            <= 8'd0;
    this.ifc.tdest          <= 8'd0;
    // Start main loop
    forever begin
      this.trInBox.get(this.tr);
      // Clock alignment
      this.ifc.clockAlign();
      // Transaction decoder
      if(this.tr.TrType == AXI4STR_m_busTrans::IDLE) begin
        repeat(this.tr.idleCycles) @this.ifc.cb;
      end else if(this.tr.TrType == AXI4STR_m_busTrans::WAIT)begin
        this.trOutBox.put(this.tr);
      end else begin
        // Write transaction.
        this.singleTransfer();
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- singleTransfer(): Generate Single Transfer.*/
  /////////////////////////////////////////////////////////////////////////////
  local task singleTransfer();
    AXI4STR_m_busTrans trErr;
    string tempStr;
    int readyWaitCnt;
    
    this.ifc.tdata          <= this.tr.tdata;
    this.ifc.tkeep          <= this.tr.tkeep;
    this.ifc.tstrb          <= this.tr.tstrb;
    this.ifc.tvalid         <= 1'b1;
    this.ifc.tlast          <= this.tr.tlast;
    this.ifc.tuser          <= this.tr.tuser;
    this.ifc.tid            <= this.tr.tid;
    this.ifc.tdest          <= this.tr.tdest;
    
    readyWaitCnt = 0;
    // Wait for slave ready.
    do begin
      @this.ifc.cb;
      readyWaitCnt++;
    end while((this.ifc.cb.tready !== 1'b1)&&(readyWaitCnt != this.readyTimeOut));
    // Check ready timeout
    if(this.ifc.cb.tready !== 1'b1) begin
      trErr = new();
      $display("%s-: Transaction TimeOut. No tready detected at sim time %0d", this.id_name, $time());
      tempStr.itoa($time);
      trErr.failedTr = "Transaction TimeOut. No tready detected at sim time ";
      trErr.failedTr     = {this.id_name, "-: ", trErr.failedTr, tempStr, "ns"};
      this.statusBox.put(trErr);
      trErr = null;
    end
    this.ifc.tvalid        <= 1'b0;
    this.ifc.tlast         <= 1'b0;
    // Random timing control.
    if((this.burstDelayEn != 0) && (this.maxBurstLen != 0))begin
      this.burstCnt            = this.burstCnt + 1;
    end
    if((this.burstCnt == this.maxBurstLen) && (this.burstDelayEn != 0)) begin
      if(this.maxBurstLen != 0) repeat(waitCycles) @this.ifc.cb;
      this.genRandomTiming();
      this.burstCnt           = 0;
    end
    //
  endtask
  //
endclass // AXI4STR_m_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_m_env:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_m_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local AXI4STR_m_busTrans tr;
  local AXI4STR_m_busBFM   axiBfm;
  // "TrNum": Is storing transactions count during all simulation time.
  local int    TrNum;
  local int    envStarted;
  int          userBitPerByte;
  local bit256 userBuf[];
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Takes physical interface as an input value and connects it to
  // virtual interface. Creates transaction mailboxes.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual axi4_str_m_if ifc, int blockSize = 4, userBitPerByte = 1);
    this.axiBfm                 = new();
    this.axiBfm.ifc             = ifc;
    this.axiBfm.blockSize       = blockSize;
    this.TrNum                  = 0;
    this.envStarted             = 0;
    this.axiBfm.id_name         = id_name;
    this.userBitPerByte         = userBitPerByte;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(this.envStarted == 0) begin
      this.axiBfm.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRandDelay(): Set/Disable bus random delays. To disable delays set all
  //  arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRandDelay(int minBurst=0, maxBurst=0, minWait=0, maxWait=0);
    this.axiBfm.maxBurst     = maxBurst;
    this.axiBfm.minBurst     = minBurst;
    this.axiBfm.minWait      = minWait;
    this.axiBfm.maxWait      = maxWait;
    this.axiBfm.burstCnt     = 0;
    if((minBurst==0)&&(maxBurst==0)&&(minWait==0)&&(maxWait==0)) begin
      this.axiBfm.burstDelayEn = 0;
    end else begin
      this.axiBfm.burstDelayEn = 1;
    end
    this.axiBfm.genRandomTiming();
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTimeOut(): Set ready wait timeout.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTimeOut(int readyTimeOut=0);
    this.axiBfm.readyTimeOut = readyTimeOut;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for the specified clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle(int idleCycles);
    this.tr             = new();
    this.tr.TrType      = AXI4STR_m_busTrans::IDLE;
    this.tr.idleCycles  = idleCycles;
    this.axiBfm.trInBox.put(this.tr);
    this.tr             = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genSingleTransfer(): Initiates single transfer on the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task genSingleTransfer(bit256 tdata, bit32 tkeep, tstrb, int tlast, 
                         bit256 tuser = 256'd0, bit8 tid = 8'd0, tdest = 8'd0);
    this.tr = new();
    this.TrNum++;
    this.tr.TrNum     = this.TrNum;
    this.tr.tdata     = tdata;
    this.tr.tlast     = tlast[0];
    this.tr.tkeep     = tkeep;
    this.tr.tstrb     = tstrb;
    this.tr.tuser     = tuser;
    this.tr.tid       = tid;
    this.tr.tdest     = tdest;
    this.tr.TrType    = AXI4STR_m_busTrans::WRITE;
    this.axiBfm.trInBox.put(this.tr);
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- sendData(): Send data packet.*/
  /////////////////////////////////////////////////////////////////////////////
  task sendData(bit8 inBuff[], int setLast = 1, tid = 0, tdest = 0);
    bit256 tdata;
    bit32 tkeep, tstrb;
    int tlast;
    bit256 tuser;
    int lengthCntr;
    lengthCntr = inBuff.size();
    for(int i = 0; i < inBuff.size(); i+=this.axiBfm.blockSize) begin
      tkeep = 32'd0;
      for(int j = 0; j < 32; j++)begin
        if((j < this.axiBfm.blockSize) && (lengthCntr != 0)) begin
          tdata[8*j+:8] = inBuff[i+j];
          tkeep[j] = 1'b1;
          lengthCntr--;
        end
      end
      tstrb = tkeep;
      tlast = setLast ? (lengthCntr == 0) : 0;
      // Send tuser info from the userBuf buffer with data. 
      // If the userBuf is less than inBuff continue sending 0s via tuser bus.
      if((i/this.axiBfm.blockSize) < this.userBuf.size()) begin
        tuser = this.userBuf[(i/this.axiBfm.blockSize)];
      end else begin
        tuser = 256'd0;
      end
      this.genSingleTransfer(tdata, tkeep, tstrb, tlast, tuser, tid[7:0], tdest[7:0]);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- createUserBuf(): Create user buffer. The user data will be transfered with
  //                   data in parallel via TUSER bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task createUserBuf(bit8 inBuff[]);
    bit256 tuser;
    bit8   inByte;
    int length, wrdLen;
    int bnum;
    int bytePtr;
    length = inBuff.size();
    wrdLen = length/this.axiBfm.blockSize;
    if(length > (wrdLen*this.axiBfm.blockSize)) wrdLen++;
    this.userBuf = new[wrdLen];
    bytePtr = 0;
    for(int i = 0; i < wrdLen; i++) begin
      bnum = 0;
      for(int j = 0; j < 32; j++)begin
        if(j < this.axiBfm.blockSize) begin
          inByte = inBuff[bytePtr];
          bytePtr++;
          for(int k = 0; k < 8; k++)begin
            if(k < this.userBitPerByte) begin
              tuser[bnum] = inByte[k];
              bnum++;
            end
          end
        end
      end
      this.userBuf[i] = tuser;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- waitCommandDone(): Wait until all instructions in the input mailbox are
  //  finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task waitCommandDone();
    this.tr         = new();
    this.tr.TrType  = AXI4STR_m_busTrans::WAIT;
    this.axiBfm.trInBox.put(this.tr);
    this.axiBfm.trOutBox.get(this.tr);
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- waitClk(): */
  /////////////////////////////////////////////////////////////////////////////
  task waitClk(int clkCnt);
    repeat (clkCnt) @this.axiBfm.ifc.cb;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print all errors if there are any and
  // return errors count. Otherwise return 0.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    this.tr = new();
    statusBoxSize = this.axiBfm.statusBox.num();
    while(this.axiBfm.statusBox.num() != 0) begin
      void'(this.axiBfm.statusBox.try_get(this.tr));
      $display(this.tr.failedTr);
    end
    this.tr = null;
    $display("The %s master VIP has %d errors", this.axiBfm.id_name, statusBoxSize);
  endfunction
  //
endclass // AXI4STR_m_env
//
endpackage
