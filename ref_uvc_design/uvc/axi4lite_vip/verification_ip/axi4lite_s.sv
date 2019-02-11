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

package AXI4LITE_S;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [63:0]   bit64;
typedef bit [127:0]  bit128;
typedef bit8         bit8_16[16];
typedef class AXI4Lite_s_busTrans;
typedef class AXI4Lite_s_busBFM;
typedef class AXI4Lite_s_env;
typedef mailbox #(AXI4Lite_s_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class AXI4Lite_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  bit32                               address;
  bit8_16                             dataBlock;
  bit   [15:0]                        wrStrob;
  bit8                                resp;
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
  //
endclass // AXI4Lite_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AX4LiteI_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  string id_name;
  int blockSize;
  virtual axi4lite_s_if ifc;
  // Mailboxes
  TransMBox trWrAddrBox, trWrDataBox, trRdAddrBox, trRdDataBox,
            trWrRespBox, statusBox;
  // Read/Write response arrays
  bit8 WrRespArray[*];
  bit8 RdRespArray[*];
  // Internal memory
  bit8 intMemArray[bit32];
  int memClean = 0;
  // Delay controls
  int minAckDelay = 0;
  int maxAckDelay = 0;
  int awAckDelay = 0;
  int wAckDelay = 0;
  int respAckDelay = 0;
  int arAckDelay = 0;
  int rAckDelay = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
    this.trWrAddrBox   = new();
    this.trWrDataBox   = new();
    this.trRdAddrBox   = new();
    this.trRdDataBox   = new();
    this.trWrRespBox   = new();
    this.statusBox     = new();
    fork
      this.write_addr_loop();
      this.write_data_loop();
      this.write_resp_loop();
      this.read_addr_loop();
      this.read_data_loop();
      this.write_loop();
      this.read_loop();
    join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_loop(): Get write address and data transactions from the lower level.
  //  Put data to the internal memory. Generate write response transaction.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_loop();
    //
    AXI4Lite_s_busTrans tr;
    bit32 addr;
    // Start main loop for write address channel
    forever begin
      // Get address
      this.trWrAddrBox.get(tr);
      addr = tr.address;
      // Get data and put to the memory
      this.trWrDataBox.get(tr);
      for(int i = 0; i < this.blockSize; i++) begin
        if(tr.wrStrob[i] == 1'b1) begin
          this.intMemArray[addr + i] = tr.dataBlock[i];
        end
      end
      // Generate write response
      tr = new();
      // Address alignment
      while((addr%this.blockSize) != 0) begin
        addr--;
      end
      if(this.WrRespArray.exists(addr)) begin
        tr.resp = this.WrRespArray[addr];
      end else begin
        tr.resp = 'd0;
      end
      this.trWrRespBox.put(tr);
      tr = null;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_loop(): Get read address transaction from the lower level.
  //  Get data from the internal memory and generate read data transaction.*/
  /////////////////////////////////////////////////////////////////////////////
  local task read_loop();
    //
    AXI4Lite_s_busTrans tr;
    bit32 addr;
    // Start main loop for write address channel
    forever begin
      // Get address
      this.trRdAddrBox.get(tr);
      addr = tr.address/this.blockSize;
      addr *= this.blockSize;
      // Get data from memory and put to the data bus
      for(int i = 0; i < this.blockSize; i++) begin
        if(this.intMemArray.exists(addr + i)) begin
          tr.dataBlock[i] = this.intMemArray[addr + i];
          if((this.memClean == 1) || (this.memClean == 3)) begin
            // Delete memory cell. It will accelerate simulation time.
            this.intMemArray.delete(addr + i);
          end
        end
      end
      if(this.RdRespArray.exists(addr)) begin
        tr.resp = this.RdRespArray[addr];
      end else begin
        tr.resp = 'd0;
      end
      this.trRdDataBox.put(tr);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_addr_loop(): Get write address transaction and pass one level up.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_addr_loop();
    //
    AXI4Lite_s_busTrans tr;
    // Start main loop for write address channel
    forever begin
      tr = new();
      do begin
        if(this.awAckDelay == 0) this.ifc.cb.awready <= 1'b1;
        else this.ifc.cb.awready <= 1'b0;
        @this.ifc.cb;
      end while(this.ifc.cb.awvalid !== 1'b1);
      // Delay awready signal
      repeat (this.awAckDelay) @this.ifc.cb;
      this.ifc.cb.awready <= 1'b1;
      if(this.awAckDelay != 0) begin
        @this.ifc.cb;
      end
      // Generate random delay
      this.awAckDelay = $urandom_range(this.maxAckDelay, this.minAckDelay);
      tr.address  = this.ifc.cb.awaddr;
      this.trWrAddrBox.put(tr);
      tr = null;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_data_loop(): Get write data transaction and pass one level up.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_data_loop();
    //
    AXI4Lite_s_busTrans tr;
    // Start main loop for write address channel
    forever begin
      tr = new();
      do begin
        if(this.wAckDelay == 0) this.ifc.cb.wready <= 1'b1;
        else this.ifc.cb.wready <= 1'b0;
        @this.ifc.cb;
      end while(this.ifc.cb.wvalid !== 1'b1);
      // Delay wready signal
      repeat (this.wAckDelay) @this.ifc.cb;
      this.ifc.cb.wready <= 1'b1;
      if(this.wAckDelay != 0) begin
        @this.ifc.cb;
      end
      // Generate random delay
      this.wAckDelay = $urandom_range(this.maxAckDelay, this.minAckDelay);
      tr.dataBlock = tr.pack2unpack(this.ifc.cb.wdata);
      tr.wrStrob   = this.ifc.cb.wstrb;
      this.trWrDataBox.put(tr);
      tr = null;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_resp_loop(): Get write response transaction from upper level and
  //   put to the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_resp_loop();
    //
    AXI4Lite_s_busTrans tr;
    // Init
    this.ifc.cb.bvalid     <= 1'b0;
    // Start main loop for write address channel
    forever begin
      this.trWrRespBox.get(tr);
      // Delay bvalid signal
      repeat (this.respAckDelay) @this.ifc.cb;
      // Generate random delay
      this.respAckDelay = $urandom_range(this.maxAckDelay, this.minAckDelay);
      this.ifc.cb.bvalid   <= 1'b1;
      this.ifc.cb.bresp    <= tr.resp;
      do begin
        @this.ifc.cb;
      end while(this.ifc.cb.bready !== 1'b1);
      this.ifc.cb.bvalid   <= 1'b0;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_addr_loop(): Get read address transaction and pass one level up.*/
  /////////////////////////////////////////////////////////////////////////////
  local task read_addr_loop();
    //
    AXI4Lite_s_busTrans tr;
    // Start main loop for write address channel
    forever begin
      tr = new();
      do begin
        if(this.arAckDelay == 0) this.ifc.cb.arready <= 1'b1;
        else this.ifc.cb.arready <= 1'b0;
        @this.ifc.cb;
      end while(this.ifc.cb.arvalid !== 1'b1);
      // Delay arready signal
      repeat (this.arAckDelay) @this.ifc.cb;
      this.ifc.cb.arready <= 1'b1;
      if(this.arAckDelay != 0) begin
        @this.ifc.cb;
      end
      // Generate random delay
      this.arAckDelay = $urandom_range(this.maxAckDelay, this.minAckDelay);
      tr.address  = this.ifc.cb.araddr;
      this.trRdAddrBox.put(tr);
      tr = null;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_data_loop(): Get read data transaction from upper level and put to
  //  the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  local task read_data_loop();
    //
    AXI4Lite_s_busTrans tr;
    // Init
    this.ifc.cb.rvalid       <= 1'b0;
    // Start main loop for write address channel
    forever begin
      this.trRdDataBox.get(tr);
      // Delay rvalid signal
      repeat (this.rAckDelay) @this.ifc.cb;
      // Generate random delay
      this.rAckDelay = $urandom_range(this.maxAckDelay, this.minAckDelay);
      this.ifc.cb.rvalid     <= 1'b1;
      this.ifc.cb.rdata <= tr.unpack2pack(tr.dataBlock);
      this.ifc.cb.rresp <= tr.resp[1:0];
      do begin
        @this.ifc.cb;
      end while(this.ifc.cb.rready !== 1'b1);
      this.ifc.cb.rvalid     <= 1'b0;
    end
  endtask
  //
endclass // AXI4Lite_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class AXI4Lite_s_env:
///////////////////////////////////////////////////////////////////////////////
class AXI4Lite_s_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local AXI4Lite_s_busBFM busBFM; 
  local int envStarted      = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to virtual and set data bus size.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual axi4lite_s_if ifc, int blockSize = 4);
    this.busBFM            = new();
    this.busBFM.ifc        = ifc;
    this.busBFM.blockSize  = blockSize;
    this.busBFM.id_name    = id_name;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the AXI bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      this.busBFM.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Set response random delays. To disable random delays set
  //  all arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRndDelay(int minAckDelay=0, maxAckDelay=0);
    this.busBFM.minAckDelay  = minAckDelay;
    this.busBFM.maxAckDelay  = maxAckDelay;
    this.busBFM.awAckDelay   = maxAckDelay;
    this.busBFM.wAckDelay    = maxAckDelay;
    this.busBFM.respAckDelay = maxAckDelay;
    this.busBFM.arAckDelay   = maxAckDelay;
    this.busBFM.rAckDelay    = maxAckDelay;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setMemCleanMode(): Set internal memory clean mode.
  // 0 - no memory clean
  // 1 - only AXI master read transactions will clean memory
  // 2 - only "getData" function will clean memory
  // 3 - Both AXI master read transactions and "getData" function will
  //     clean memory
  // Cleaning memory will accelerate simulation time.*/
  /////////////////////////////////////////////////////////////////////////////
  task setMemCleanMode(int memClean = 0);
    this.busBFM.memClean     = memClean;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- putData(): Put data buffer to the internal memory.*/
  /////////////////////////////////////////////////////////////////////////////
  task putData(input bit32 startAddr, bit8 dataInBuff[]);
    for(int i = 0; i < dataInBuff.size(); i++) begin
      this.busBFM.intMemArray[startAddr+i] = dataInBuff[i];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get data buffer from the internal memory.*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(input bit32 startAddr, output bit8 dataOutBuff[], input int lenght);
    dataOutBuff = new[lenght];
    for(int i = 0; i < lenght; i++) begin
      if(this.busBFM.intMemArray.exists(startAddr+i)) begin
        dataOutBuff[i] = this.busBFM.intMemArray[startAddr+i];
        if((this.busBFM.memClean == 2) || (this.busBFM.memClean == 3)) begin
          this.busBFM.intMemArray.delete(startAddr+i);
        end
      end else begin
        dataOutBuff[i] = 8'd0;
      end
    end
    // Clean internal memory
    if((this.busBFM.memClean == 2) || (this.busBFM.memClean == 3)) begin
      for(int i = 0; i < lenght; i++) begin
        if(this.busBFM.intMemArray.exists(startAddr+i)) begin
          this.busBFM.intMemArray.delete(startAddr+i);
        end
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollData(): Poll specified address until read data is equal to pollData.
  // If poll counter is reached to "pollTimeOut" value stop, polling and
  // generate error message.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollData(input bit32 address, bit8 pollData[], bit32 pollTimeOut = 1000);
    bit8 dataBuff[];
    int status;
    string tempStr;
    AXI4Lite_s_busTrans trErr;
    int memClean;
    // Save memClean
    memClean = this.busBFM.memClean;
    // Dont't clean internal memory until poll done.
    this.busBFM.memClean = 0;
    $display("Polling address 0x%h: @sim time %0d", address, $time);
    fork: poll
    begin
      do begin
        this.getData(address, dataBuff, pollData.size());
        status = 0;
        for(int i = 0; i < pollData.size(); i++) begin
          if(dataBuff[i] != pollData[i]) begin
            status = 1;
            break;
          end
        end
        if(status == 1) @this.busBFM.ifc.cb;
      end while(status == 1);
      $display("Poll Done!");
    end
    begin
      repeat(pollTimeOut) @this.busBFM.ifc.cb;
      trErr = new();
      $display("Poll Time Out Detected at sim time %0d", $time());
      tempStr.itoa($time);
      trErr.failedTr     = "Poll TimeOut detected. At simulation time ";
      trErr.failedTr     = {trErr.failedTr, tempStr, "ns"};
      this.busBFM.statusBox.put(trErr);
      trErr = null;
    end
    join_any
    disable poll;
    // Restore memClean.
    this.busBFM.memClean = memClean;
    // Clean internal memory
    if((this.busBFM.memClean == 2) || (this.busBFM.memClean == 3)) begin
      for(int i = 0; i < pollData.size(); i++) begin
        if(this.busBFM.intMemArray.exists(address+i)) begin
          this.busBFM.intMemArray.delete(address+i);
        end
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setWrResp(): Set write response mode for current address. Address must
  //  be aligned.*/
  /////////////////////////////////////////////////////////////////////////////
  task setWrResp(int address, int wrResp);
    // Address alignment
    while((address%this.busBFM.blockSize) != 0) begin
      address--;
    end
    if(wrResp == 0) begin
      if(this.busBFM.WrRespArray.exists(address)) begin
        this.busBFM.WrRespArray.delete(address);
      end
    end else begin
      this.busBFM.WrRespArray[address] = wrResp;
    end
    //
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRdResp(): Set read response mode for current address. Address must
  //  be aligned.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRdResp(int address, int rdResp);
    // Address alignment
    while((address%this.busBFM.blockSize) != 0) begin
      address--;
    end
    if(rdResp == 0) begin
      if(this.busBFM.RdRespArray.exists(address)) begin
        this.busBFM.RdRespArray.delete(address);
      end
    end else begin
      this.busBFM.RdRespArray[address] = rdResp;
    end
    //
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print poll timeout errors and return errors count.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    AXI4Lite_s_busTrans tr;
    tr = new();
    statusBoxSize = this.busBFM.statusBox.num();
    while(this.busBFM.statusBox.num() != 0)begin
      void'(this.busBFM.statusBox.try_get(tr));
      $display(tr.failedTr);
    end
    tr = null;
    $display("The %s slave VIP has %d errors", this.busBFM.id_name, statusBoxSize);
  endfunction
  //
endclass // AXI4Lite_s_env
//
endpackage
