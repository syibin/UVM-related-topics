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

package AXI4LITE_M;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [63:0]   bit64;
typedef bit [127:0]  bit128;
typedef bit8         bit8_16[16];
typedef class AXI4Lite_m_busTrans;
typedef class AXI4Lite_m_busBFM;
typedef class AXI4Lite_m_env;
typedef mailbox #(AXI4Lite_m_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class AXI4Lite_m_busTrans:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_m_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  enum {WRITE_READ, IDLE, WAIT}       TrType;
  bit32                               address;
  bit8_16                             dataBlock;
  bit128                              dataWord;
  bit   [15:0]                        wrStrob;
  bit8                                resp;
  int unsigned                        rdDataPtr;
  int unsigned                        wrRespPtr;
  int                                 lastTr;
  int                                 idleCycles;
  string                              failedTr;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- unpack2pack(): Convert unpack array to packed.*/
  /////////////////////////////////////////////////////////////////////////////
  function bit128 unpack2pack(bit8_16 dataBlock);
    for (int i = 0; i < 16; i++) unpack2pack[8*i+:8] = dataBlock[i];
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- pack2unpack(): Convert packed array to unpacked.*/
  /////////////////////////////////////////////////////////////////////////////
  function bit8_16 pack2unpack(bit128 dataBlock);
    for (int i = 0; i < 16; i++) pack2unpack[i] = dataBlock[8*i+:8];
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- genErrorMsg(): Generate error message and keep in the "failedTr" string.*/
  /////////////////////////////////////////////////////////////////////////////
  function void genErrorMsg(string errString);
    string tempStr;
    errString = {errString, " at sim time "};
    $write(errString);
    $write("%0d\n", $time());
    tempStr.itoa($time);
    this.failedTr = errString;
    this.failedTr = {this.failedTr, " ", tempStr, "ns"};
  endfunction
  //
endclass // AXI4Lite_m_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AXI4Lite_m_busBFM:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_m_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  string id_name;
  int blockSize;
  virtual axi4lite_m_if ifc;
  // Mailboxes
  TransMBox trWrAddrBox, trWrDataBox, trRdAddrBox, trRdDataBox,
            trWrRespBox, trRReadyBox, trWrAddrQueueBox, statusBox;
  semaphore wrAddrSem, wrDataSem, wrRespSem, rdAddrSem, rdDataSem;
  local AXI4Lite_m_busTrans trWrAddr, trWrData, trRdAddr, trRdData, trWrResp;
  // Read data and write response buffers
  TransMBox RdDataArrayBox[*];
  TransMBox WrRespArrayBox[*];
  int readyTimeOut;
  int respReportEn;
  // Delay control variables
  int       maxBurstLenWrAddr = 0;
  int       burstCntWrAddr    = 0;
  int       maxBurstLenWrData = 0;
  int       burstCntWrData    = 0;
  int       maxBurstLenRdAddr = 0;
  int       burstCntRdAddr    = 0;
  int       maxBurstLenRdData = 0;
  int       burstCntRdData    = 0;
  int       maxBurstLenWrResp = 0;
  int       burstCntWrResp    = 0;
  int       maxBurst          = 0;
  int       minBurst          = 0;
  int       maxWait           = 0;
  int       minWait           = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
      fork
        this.write_addr_loop();
        this.write_data_loop();
        this.read_addr_loop();
        this.read_data_loop();
        this.write_resp_loop();
      join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_addr_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task write_addr_loop();
    // Init
    this.ifc.cb.awaddr         <= 'd0;
    this.ifc.cb.awvalid        <= 1'b0;
    // Start main loop for write address channel
    forever begin
      this.trWrAddrBox.get(this.trWrAddr);
      if(this.trWrAddr.TrType == AXI4Lite_m_busTrans::IDLE) begin
        repeat (this.trWrAddr.idleCycles) @this.ifc.cb;
      end if(this.trWrAddr.TrType == AXI4Lite_m_busTrans::WAIT) begin
        this.wrAddrSem.put(1);
      end else begin
        this.writeAddr();
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_data_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task write_data_loop();
    // Init
    this.ifc.cb.wdata         <= 'd0;
    this.ifc.cb.wstrb         <= 'd0;
    this.ifc.cb.wvalid        <= 1'b0;
    // Start main loop for write data channel
    forever begin
      this.trWrDataBox.get(this.trWrData);
      if(this.trWrData.TrType == AXI4Lite_m_busTrans::IDLE) begin
        repeat (this.trWrData.idleCycles) @this.ifc.cb;
      end if (this.trWrData.TrType == AXI4Lite_m_busTrans::WAIT) begin
        this.wrDataSem.put(1);
      end else begin
        this.writeData();
        // Generate transaction for write response channel
        this.trWrRespBox.put(this.trWrData);
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_resp_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task write_resp_loop();
    // Init
    this.ifc.cb.bready         <= 1'b0;
    // Start main loop for write responce channel
    forever begin
      this.trWrRespBox.get(this.trWrResp);
      if (this.trWrResp.TrType == AXI4Lite_m_busTrans::WAIT) begin
        this.rdDataSem.put(1);
      end else begin
        this.writeResp();
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_addr_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task read_addr_loop();
    // Init
    this.ifc.cb.araddr         <= 'd0;
    this.ifc.cb.arvalid        <= 1'b0;
    // Start main loop for write address channel
    forever begin
      this.trRdAddrBox.get(this.trRdAddr);
      if(this.trRdAddr.TrType == AXI4Lite_m_busTrans::IDLE) begin
        repeat (this.trRdAddr.idleCycles) @this.ifc.cb;
      end else if (this.trRdAddr.TrType == AXI4Lite_m_busTrans::WAIT) begin
        this.rdAddrSem.put(1);
      end else begin
        this.readAddr();
        // Generate transaction for read data channel
        this.trRdDataBox.put(this.trRdAddr);
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_data_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task read_data_loop();
    // Init
    this.ifc.cb.rready         <= 1'b0;
    // Start main loop for read data channel
    forever begin
      this.trRdDataBox.get(this.trRdData);
      if (this.trRdData.TrType == AXI4Lite_m_busTrans::WAIT) begin
        this.rdDataSem.put(1);
      end else begin
        this.readData();
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- writeAddr(): Generate write address channel timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task writeAddr();
    AXI4Lite_m_busTrans trErr;
    string tempStr;
    // Clock alignment
    this.ifc.clockAlign();
    // Generate timing
    this.ifc.cb.awaddr         <= this.trWrAddr.address;
    this.ifc.cb.awvalid        <= 1'b1;
    @this.ifc.cb;
    // Poll awready
    fork: aw_ready_poll
      while(this.ifc.cb.awready !== 1'b1) @this.ifc.cb;
      begin
        repeat(this.readyTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Write address channel TimeOut Detected");
        this.statusBox.put(trErr);
        trErr = null;
      end
    join_any
    disable aw_ready_poll;
    this.ifc.cb.awvalid        <= 1'b0;
    // Random timing control.
    if(this.maxBurstLenWrAddr != 0)begin
      this.burstCntWrAddr++;
    end
    if(this.burstCntWrAddr == this.maxBurstLenWrAddr) begin
      if(this.maxBurstLenWrAddr != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntWrAddr = 0;
      this.maxBurstLenWrAddr = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- writeData(): Generate write data channel timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task writeData();
    AXI4Lite_m_busTrans trErr;
    string tempStr;
    // Clock alignment
    this.ifc.clockAlign();
    // Generate timing
    this.ifc.cb.wvalid         <= 1'b1;
    this.ifc.cb.wdata          <= this.trWrData.dataWord;
    this.ifc.cb.wstrb          <= this.trWrData.wrStrob;
    @this.ifc.cb;
    // Poll wready
    fork: w_ready_poll
      while(this.ifc.cb.wready !== 1'b1) @this.ifc.cb;
      begin
        repeat(this.readyTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Write data channel TimeOut Detected");
        this.statusBox.put(trErr);
        trErr = null;
      end
    join_any
    disable w_ready_poll;
    this.ifc.cb.wvalid          <= 1'b0;
    // Random timing control.
    if(this.maxBurstLenWrData != 0)begin
      this.burstCntWrData++;
    end
    if(this.burstCntWrData == this.maxBurstLenWrData) begin
      if(this.maxBurstLenWrData != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntWrData = 0;
      this.maxBurstLenWrData = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readAddr(): Generate read address channel timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task readAddr();
    AXI4Lite_m_busTrans trErr;
    string tempStr;
    // Clock alignment
    this.ifc.clockAlign();
    // Generate timing
    this.ifc.cb.araddr         <= this.trRdAddr.address;
    this.ifc.cb.arvalid        <= 1'b1;
    @this.ifc.cb;
    // Poll arready
    fork: ar_ready_poll
      while(this.ifc.cb.arready !== 1'b1) @this.ifc.cb;
      begin
        repeat(this.readyTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Read address channel TimeOut Detected");
        this.statusBox.put(trErr);
        trErr = null;
      end
    join_any
    disable ar_ready_poll;
    this.ifc.cb.arvalid        <= 1'b0;
    // Random timing control.
    if(this.maxBurstLenRdAddr != 0)begin
      this.burstCntRdAddr++;
    end
    if(this.burstCntRdAddr == this.maxBurstLenRdAddr) begin
      if(this.maxBurstLenRdAddr != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntRdAddr = 0;
      this.maxBurstLenRdAddr = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readData(): Generate read data channel timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task readData();
    AXI4Lite_m_busTrans trErr;
    string tempStr;
    this.ifc.cb.rready        <= 1'b1;
    @this.ifc.cb;
    this.trRdData.resp = 8'd0;
    // Poll rvalid
    fork: r_valid_poll
      while(this.ifc.cb.rvalid !== 1'b1) @this.ifc.cb;
      begin
        repeat(this.readyTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Read Data channel TimeOut Detected");
        this.statusBox.put(trErr);
        trErr = null;
        this.trRdData.resp = 8'hff;
      end
    join_any
    disable r_valid_poll;
    //
    this.ifc.cb.rready        <= 1'b0;
    this.trRdData.resp[1:0]   = this.ifc.cb.rresp;
    this.trRdData.dataBlock   = this.trRdData.pack2unpack(this.ifc.cb.rdata);
    if((this.respReportEn == 1) && (this.trRdData.resp != 'd0)) begin
      trErr = new();
      trErr.genErrorMsg("ERROR: Not OK read response Detected");
      this.statusBox.put(trErr);
      trErr = null;
    end
    this.RdDataArrayBox[this.trRdData.rdDataPtr].put(this.trRdData);
    // Random timing control.
    if(this.maxBurstLenRdData != 0)begin
      this.burstCntRdData++;
    end
    if(this.burstCntRdData == this.maxBurstLenRdData) begin
      if(this.maxBurstLenRdData != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntRdData = 0;
      this.maxBurstLenRdData = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- writeResp(): Generate write response channel timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task writeResp();
    AXI4Lite_m_busTrans trErr;
    string tempStr;
    // Generate timing
    this.ifc.cb.bready         <= 1'b1;
    @this.ifc.cb;
    this.trWrResp.resp = 8'd0;
    // Poll bvalid
    fork: w_resp_valid_poll
      while(this.ifc.cb.bvalid !== 1'b1) @this.ifc.cb;
      begin
        repeat(this.readyTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Write response channel TimeOut Detected");
        this.statusBox.put(trErr);
        trErr = null;
        this.trWrResp.resp = 8'hff;
      end
    join_any
    disable w_resp_valid_poll;
    this.ifc.cb.bready         <= 1'b0;
    this.trWrResp.resp[1:0]     = this.ifc.cb.bresp;
    if((this.respReportEn == 1) && (this.trWrResp.resp != 'd0)) begin
      trErr = new();
      trErr.genErrorMsg("ERROR: Not OK write response Detected");
      this.statusBox.put(trErr);
      trErr = null;
    end
    this.WrRespArrayBox[this.trWrResp.wrRespPtr].put(this.trWrResp);
    // Random timing control.
    if(this.maxBurstLenWrResp != 0)begin
      this.burstCntWrResp++;
    end
    if(this.burstCntWrResp == this.maxBurstLenWrResp) begin
      if(this.maxBurstLenWrResp != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntWrResp = 0;
      this.maxBurstLenWrResp = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  //
endclass // AXI4Lite_m_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class AXI_m_env:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_m_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local AXI4Lite_m_busTrans trWrAddr, trWrData, trRdAddr, trRdData, trWrResp;
  local int envStarted;
  local int unsigned rdDataPtr;
  local int unsigned wrRespPtr;
  local int pollTimeOut;
  local AXI4Lite_m_busBFM busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to virtual. Set data bus size.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual axi4lite_m_if ifc, int blockSize = 4);
    this.busBFM              = new();
    this.envStarted          = 0;
    this.rdDataPtr           = 0;
    this.wrRespPtr           = 0;
    this.busBFM.ifc          = ifc;
    this.busBFM.trWrAddrBox  = new();
    this.busBFM.trRdAddrBox  = new();
    this.busBFM.trWrRespBox  = new();
    this.busBFM.trWrDataBox  = new();
    this.busBFM.trRdDataBox  = new();
    this.busBFM.wrAddrSem    = new();
    this.busBFM.rdAddrSem    = new();
    this.busBFM.rdDataSem    = new();
    this.busBFM.wrDataSem    = new();
    this.busBFM.wrRespSem    = new();
    this.busBFM.statusBox    = new();
    this.busBFM.blockSize    = blockSize;
    this.pollTimeOut         = 10000;
    this.busBFM.readyTimeOut = 10000;
    this.busBFM.respReportEn = 1;
    this.busBFM.id_name      = id_name;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the AXI bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(this.envStarted == 0) begin
      this.busBFM.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Enable/Disable bus random delays. To disable delays set
  //  all arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRndDelay(int minBurst=0, maxBurst=0, minWait=0, maxWait=0);
    this.busBFM.minBurst          = minBurst;
    this.busBFM.maxBurst          = maxBurst;
    this.busBFM.minWait           = minWait;
    this.busBFM.maxWait           = maxWait;
    this.busBFM.burstCntWrAddr    = 0;
    this.busBFM.burstCntWrData    = 0;
    this.busBFM.burstCntRdAddr    = 0;
    this.busBFM.burstCntRdData    = 0;
    this.busBFM.burstCntWrResp    = 0;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTimeOut(): Set ready and poll timeouts.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTimeOut(int readyTimeOut=0, pollTimeOut=0);
    this.busBFM.readyTimeOut = readyTimeOut;
    this.pollTimeOut   = pollTimeOut;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- wrAddrChannelIdle(): Hold write address channel in idle for the
  //  specified clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task wrAddrChannelIdle(int idleCycles);
    this.trWrAddr               = new();
    this.trWrAddr.TrType        = AXI4Lite_m_busTrans::IDLE;
    this.trWrAddr.idleCycles    = idleCycles;
    this.busBFM.trWrAddrBox.put(this.trWrAddr);
    this.trWrAddr               = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- wrDataChannelIdle(): Hold write data channel in idle for the
  //  specified clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task wrDataChannelIdle(int idleCycles);
    this.trWrData               = new();
    this.trWrData.TrType        = AXI4Lite_m_busTrans::IDLE;
    this.trWrData.idleCycles    = idleCycles;
    this.busBFM.trWrDataBox.put(this.trWrData);
    this.trWrData               = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- wrAddrChannelDone(): Wait until all transactions in the write address
  // channel mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task wrAddrChannelDone();
    this.trWrAddr               = new();
    this.trWrAddr.TrType        = AXI4Lite_m_busTrans::WAIT;
    this.busBFM.trWrAddrBox.put(this.trWrAddr);
    this.trWrAddr               = null;
    this.busBFM.wrAddrSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- wrDataChannelDone(): Wait until all transactions in the write data
  // channel mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task wrDataChannelDone();
    this.trWrData               = new();
    this.trWrData.TrType        = AXI4Lite_m_busTrans::WAIT;
    this.busBFM.trWrDataBox.put(this.trWrData);
    this.trWrData               = null;
    this.busBFM.wrDataSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rdAddrChannelIdle(): Hold read address channel in idle for the
  //  specified clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task rdAddrChannelIdle(int idleCycles);
    this.trRdAddr               = new();
    this.trRdAddr.TrType        = AXI4Lite_m_busTrans::IDLE;
    this.trRdAddr.idleCycles    = idleCycles;
    this.busBFM.trRdAddrBox.put(this.trRdAddr);
    this.trRdAddr               = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rdAddrChannelDone(): Wait until all transactions in the read address
  // channel mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task rdAddrChannelDone();
    this.trRdAddr               = new();
    this.trRdAddr.TrType        = AXI4Lite_m_busTrans::WAIT;
    this.busBFM.trRdAddrBox.put(this.trRdAddr);
    this.trRdAddr               = null;
    this.busBFM.rdAddrSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- rdDataChannelDone(): Wait until all transactions in the read data
  // channel mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task rdDataChannelDone();
    this.trRdData               = new();
    this.trRdData.TrType        = AXI4Lite_m_busTrans::WAIT;
    this.busBFM.trRdDataBox.put(this.trRdData);
    this.trRdData               = null;
    this.busBFM.rdDataSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- wrRespChannelDone(): Wait until all instructions in the write response
  // channel mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task wrRespChannelDone();
    this.trWrResp               = new();
    this.trWrResp.TrType        = AXI4Lite_m_busTrans::WAIT;
    this.busBFM.trWrRespBox.put(this.trWrResp);
    this.trWrResp               = null;
    this.busBFM.wrRespSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- respReportMode(): Set Read/Write response report mode. If set all not OK
  //  responses will be reported by "printStatus" function.*/
  /////////////////////////////////////////////////////////////////////////////
  task respReportMode(int respReportEn);
    this.busBFM.respReportEn = respReportEn;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- writeData(): Send data buffer. Start address will be incremented after
  // each transaction. Returns memory pointer where write response buffer will
  // be stored.*/
  /////////////////////////////////////////////////////////////////////////////
  task writeData(output int unsigned wrRespPtr, input bit32 addr, bit8 inBuff[]);
    bit [15:0] wrStrob;
    int inBuffSize;
    int inBuffPtr;
    bit32 addrHold;
    addrHold = addr;
    wrRespPtr = this.wrRespPtr;
    inBuffSize = inBuff.size();
    // Create new transaction mailbox for write response buffer with current pointer
    this.busBFM.WrRespArrayBox[wrRespPtr] = new();
    // AXI address always will be aligned. Missaligned data will be controled
    // via "wrStrob" bus.
    while((addr%this.busBFM.blockSize) != 0) begin
      addr--;
    end
    inBuffPtr = 0;
    while(inBuffSize != 0) begin
      // Put address information
      this.trWrAddr = new();
      this.trWrAddr.address = addr;
      this.trWrAddr.wrRespPtr = wrRespPtr;
      this.busBFM.trWrAddrBox.put(this.trWrAddr);
      this.trWrAddr = null;
      // Put data information
      this.trWrData = new();
      wrStrob = 'd0;
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        this.trWrData.dataBlock[j] = 8'd0;
      end
      for(int j = (addrHold%this.busBFM.blockSize); j < this.busBFM.blockSize; j++) begin
        if(inBuffSize == 0) break;
        this.trWrData.dataBlock[j] = inBuff[inBuffPtr];
        inBuffSize--;
        inBuffPtr++;
        wrStrob[j] = 1'b1;
        addrHold++;
      end
      if(inBuffSize == 0) this.trWrData.lastTr = 1;
      else this.trWrData.lastTr = 0;
      this.trWrData.dataWord = this.trWrData.unpack2pack(this.trWrData.dataBlock);
      this.trWrData.wrStrob = wrStrob;
      this.trWrData.wrRespPtr = wrRespPtr;
      this.busBFM.trWrDataBox.put(this.trWrData);
      this.trWrData = null;
      addr+=this.busBFM.blockSize;
    end
    // Increment write response memory pointer
    this.wrRespPtr++;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readData(): Generate read transactions. Returns memory pointer where
  //  read data buffer will be stored.*/
  /////////////////////////////////////////////////////////////////////////////
  task readData(bit32 addr, int unsigned dataLength, output int unsigned dataOutPtr);
    bit [15:0] wrStrob;
    // Return current data pointer
    dataOutPtr = this.rdDataPtr;
    while(dataLength > 0) begin
      // Create new transaction mailbox for read data buffer with current pointer
      this.busBFM.RdDataArrayBox[this.rdDataPtr] = new();
      // Put address information
      this.trRdAddr = new();
      this.trRdAddr.address = addr;
      this.trRdAddr.rdDataPtr = this.rdDataPtr;
      wrStrob = 'd0;
      // Put data information
      for(int j = (addr%this.busBFM.blockSize); j < this.busBFM.blockSize; j++) begin
        if(dataLength == 0) break;
        addr++;
        dataLength--;
        wrStrob[j] = 1'b1;
      end
      if(dataLength == 0) this.trRdAddr.lastTr = 1;
      else this.trRdAddr.lastTr = 0;
      this.trRdAddr.wrStrob = wrStrob;
      this.busBFM.trRdAddrBox.put(this.trRdAddr);
      this.trRdAddr = null;
    end
    // Increment read data memory pointer
    this.rdDataPtr++;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get read data buffer with specified pointer.*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(int unsigned rdDataPtr, output bit8 outBuff[], output bit8 outRespBuff[]);
    int outBuffPtr;
    int outRespBuffPtr;
    outBuff = new[0];
    outRespBuff = new[0];
    outBuffPtr = 0;
    outRespBuffPtr = 0;
    do begin
      this.busBFM.RdDataArrayBox[rdDataPtr].get(this.trRdData);
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        if(this.trRdData.wrStrob[j] == 1'b1) begin
          outBuff             = new[(outBuffPtr+1)](outBuff);
          outBuff[outBuffPtr] = this.trRdData.dataBlock[j];
          outBuffPtr++;
        end
      end
      outRespBuff = new[(outRespBuffPtr+1)](outRespBuff);
      outRespBuff[outRespBuffPtr] = this.trRdData.resp;
      outRespBuffPtr++;
    end while(this.trRdData.lastTr == 0);
    // Delete current memory cell to accelerate simulation.
    this.busBFM.RdDataArrayBox.delete(rdDataPtr);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollData(): Poll specified addresses until read data buffer is equal to
  // pollData buffer. If poll counter is reached to "pollTimeOut" value
  // stop polling and generate error message.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollData(input bit32 address, bit8 pollData[]);
    bit8 dataBuff[$], rdRespOut[$];
    int status;
    int unsigned dataOutPtr;
    string tempStr;
    AXI4Lite_m_busTrans trErr;
    $display("Polling address 0x%h: @sim time %0d", address, $time);
    fork: poll
      begin
        repeat(this.pollTimeOut) @this.busBFM.ifc.cb;
        trErr = new();
        trErr.genErrorMsg("ERROR: Poll Time Out Detected");
        this.busBFM.statusBox.put(trErr);
        trErr = null;
      end
      begin
        do begin
          this.readData(address, pollData.size(), dataOutPtr);
          this.getData(dataOutPtr, dataBuff, rdRespOut);
          status = 0;
          for(int i = 0; i < pollData.size(); i++) begin
            if(dataBuff[i] != pollData[i]) begin
              status = 1;
              break;
            end
          end
        end while(status == 1);
        $display("Poll Done!");
      end
    join_any
    disable poll;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getWrResp(): Get write response buffer with specified pointer.*/
  /////////////////////////////////////////////////////////////////////////////
  task getWrResp(int unsigned wrRespPtr, output bit8 outRespBuff[]);
    int outRespBuffPtr;
    outRespBuff = new[0];
    outRespBuffPtr = 0;
    do begin
      this.busBFM.WrRespArrayBox[wrRespPtr].get(this.trWrResp);
      outRespBuff = new[(outRespBuffPtr+1)](outRespBuff);
      outRespBuff[outRespBuffPtr] = this.trWrResp.resp;
      outRespBuffPtr++;
    end while(this.trWrResp.lastTr == 0);
    // Delete current memory cell to accelerate simulation.
    this.busBFM.WrRespArrayBox.delete(wrRespPtr);
    //
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print all time out errors and return errors count.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    AXI4Lite_m_busTrans tr;
    tr = new();
    statusBoxSize = this.busBFM.statusBox.num();
    while(this.busBFM.statusBox.num() != 0)begin
      void'(this.busBFM.statusBox.try_get(tr));
      $display(tr.failedTr);
    end
    tr = null;
    $display("The %s master VIP has %d errors", this.busBFM.id_name, statusBoxSize);
  endfunction
  //
endclass //AXI4Lite_m_env
//
endpackage
