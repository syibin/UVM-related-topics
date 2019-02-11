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

package WSHB_S;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [63:0]   bit64;
typedef bit8         bit8_8[8];
typedef class WSHB_s_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(WSHB_s_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class WSHB_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class WSHB_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  int                                     TrNum;
  enum {WRITE, READ, CFG_DELAY,
        CFG_RESP, CFG_MEM}                TrType;
  bit32                                   address;
  bit8_8                                  dataBlock;
  bit8                                    sel;
  int                                     idleCycles;
  string                                  failedTr;
  // Configuration variables
  int minAckDelay, maxAckDelay;
  bit32 errAddr, rtyAddr;
  int errEn, rtyNum;
  int memClean;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function bit64 unpack2pack(bit8_8 dataBlock);
    unpack2pack = {dataBlock[7], dataBlock[6], dataBlock[5], dataBlock[4],
                   dataBlock[3], dataBlock[2], dataBlock[1], dataBlock[0]};
  endfunction
  //
  function bit8_8 pack2unpack(bit64 dataBlock);
    {pack2unpack[7], pack2unpack[6], pack2unpack[5], pack2unpack[4],
     pack2unpack[3], pack2unpack[2], pack2unpack[1], pack2unpack[0]
    } = dataBlock;
  endfunction
  //
endclass // WSHB_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class WSHB_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class WSHB_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // Configuration variables
  int blockSize;
  bit32 errAddr, rtyAddr;
  int errEn  = 0;
  int rtyNum = 0;
  rand int ackDelay = 0;
  int ackDelayEn    = 0;
  int minAckDelay, maxAckDelay;
  int memClean = 0;
  // Constraints for random timing
   constraint c_timing {
    this.ackDelay          inside {[minAckDelay:maxAckDelay]};
  }
  /////////////////////////////////////////////////////////////////////////////
  virtual wshb_s_if ifc;
  TransMBox trInBox, trOutBox, statusBox;
  local WSHB_s_busTrans tr;
  bit8  ram[bit32];
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
      //
      fork
        this.run_loop();
      join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  local task run_loop();
    int rtyCnt = 0;
    // Init
    this.ifc.dat_o        <= 'd0;
    this.ifc.ack_o        <= 1'b0;
    this.ifc.err_o        <= 1'b0;
    this.ifc.rty_o        <= 1'b0;
    // Clock alignment
    this.ifc.clockAlign();
    // Start main loop
    forever begin
      do begin
        @this.ifc.cb_n;
        // If new configuration available apply it to the current configuration.
        while(this.trInBox.try_get(this.tr) == 1) begin
          if(this.tr.TrType == WSHB_s_busTrans::CFG_DELAY) begin
            this.minAckDelay = this.tr.minAckDelay;
            this.maxAckDelay = this.tr.maxAckDelay;
            this.ackDelayEn  = this.maxAckDelay;
          end else if(this.tr.TrType == WSHB_s_busTrans::CFG_RESP) begin
            this.errAddr     = this.tr.errAddr;
            this.rtyAddr     = this.tr.rtyAddr;
            this.errEn       = this.tr.errEn;
            this.rtyNum      = this.tr.rtyNum;
            rtyCnt           = 0;
          end else if(this.tr.TrType == WSHB_s_busTrans::CFG_MEM) begin
            this.memClean    = this.tr.memClean;
          end
        end
        // Generate random acknowledge delay if enabled.
        if(this.ackDelayEn != 0) begin
          assert (this.randomize())
          else $fatal(0, "Wishbone Slave: Randomize failed");
        end
        this.ifc.cb_n.err_o          <= 1'b0;
        this.ifc.cb_n.rty_o          <= 1'b0;
        // Hold acknowledge active if delay is zero.
        if(this.ackDelay != 0) begin
          this.ifc.cb_n.ack_o        <= 1'b0;
        end
      end while((this.ifc.cb_n.stb_i != 1'b1) || (this.ifc.cb_n.cyc_i != 1'b1));
      // Data processing.
      this.tr                  = new();
      // Get transaction from master.
      this.tr.address   = this.ifc.cb_n.adr_i;
      this.tr.dataBlock = this.tr.pack2unpack(this.ifc.cb_n.dat_i);
      this.tr.sel       = this.ifc.cb_n.sel_i;
      if(this.ifc.cb_n.we_i == 1'b1) begin
        this.tr.TrType  = WSHB_s_busTrans::WRITE;
      end else begin
        this.tr.TrType  = WSHB_s_busTrans::READ;
      end
      // Delay acknowledge signal.
      if(this.ackDelay != 0) repeat(this.ackDelay-1) @this.ifc.cb_n;
      // Generate response. Error, retry or normal.
      if((this.errEn == 1) && (this.tr.address == this.errAddr)) begin
        this.ifc.cb_n.err_o        <= 1'b1;
      end else if((this.rtyNum != rtyCnt) && (this.tr.address == this.rtyAddr)) begin
        this.ifc.cb_n.rty_o        <= 1'b1;
        rtyCnt++;
      end else begin
        this.ifc.cb_n.ack_o         <= 1'b1;
        rtyCnt = 0;
        // Internal mem Read/Write.
        if(this.tr.TrType  == WSHB_s_busTrans::WRITE) begin
          for(int i = 0; i < this.blockSize; i++) begin
            if(this.tr.sel[i] == 1'b1) begin
              this.ram[this.tr.address + i] = this.tr.dataBlock[i];
            end
          end
        end else begin
          for(int i = 0; i < this.blockSize; i++) begin
            if((this.tr.sel[i] == 1'b1) && (this.ram.exists(this.tr.address + i))) begin
              this.tr.dataBlock[i] = this.ram[this.tr.address + i];
              if((this.memClean == 1) || (this.memClean == 3)) begin
                // Delete memory cell. It will accelerate simulation time.
                this.ram.delete(this.tr.address + i);
              end
            end
          end
          this.ifc.cb_n.dat_o         <= this.tr.unpack2pack(this.tr.dataBlock);
        end
      end
      this.tr                       = null;
    end
  endtask
  //
endclass // WSHB_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class WSHB_s_env:
///////////////////////////////////////////////////////////////////////////////
class WSHB_s_env extends WSHB_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local WSHB_s_busTrans tr;
  // "TrNum": Is storing transactions count during all simulation time.
  local int TrNum           = 0;
  local int envStarted      = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Takes physical interface as an input value and connects it to
  // virtual interface. Create transaction mailboxes.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(virtual wshb_s_if ifc, int blockSize = 4);
    super.ifc              = ifc;
    super.trInBox          = new();
    super.trOutBox         = new();
    super.statusBox        = new();
    super.blockSize        = blockSize;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      super.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Set 'ack' random delays. To disable random delays set all
  //  arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRndDelay(int minAckDelay=0, maxAckDelay=0);
    this.tr              = new();
    this.tr.TrType       = WSHB_s_busTrans::CFG_DELAY;
    this.tr.minAckDelay  = minAckDelay;
    this.tr.maxAckDelay  = maxAckDelay;
    super.trInBox.put(this.tr);
    this.tr              = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRespMode(): Set retry and error addresses. Any read/write to this
  //  addresses will generate retry or error response.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRespMode(bit32 errAddr, rtyAddr, int errEn = 0, rtyNum = 0);
    this.tr              = new();
    this.tr.TrType       = WSHB_s_busTrans::CFG_RESP;
    this.tr.errAddr      = errAddr;
    this.tr.rtyAddr      = rtyAddr;
    this.tr.errEn        = errEn;
    this.tr.rtyNum       = rtyNum;
    super.trInBox.put(this.tr);
    this.tr              = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setMemCleanMode(): Set internal memory clean mode.*/
  /////////////////////////////////////////////////////////////////////////////
  task setMemCleanMode(int memClean = 0);
    this.tr              = new();
    this.tr.TrType       = WSHB_s_busTrans::CFG_MEM;
    this.tr.memClean     = memClean;
    super.trInBox.put(this.tr);
    this.tr              = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get data buffer from the memory starting from "startAddr"
  // address. Output data buffer is a bytes sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(input bit32 startAddr, output bit8 dataOutBuff[$], input int lenght);
    dataOutBuff.delete();
    for(int i = 0; i < lenght; i++) begin
      if(super.ram.exists(startAddr+i)) begin
        dataOutBuff = {dataOutBuff, super.ram[startAddr+i]};
        if((super.memClean == 2) || (super.memClean == 3)) begin
          super.ram.delete(startAddr+i);
        end
      end else begin
        dataOutBuff = {dataOutBuff, 8'd0};
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- putData(): Put data buffer to the internal memory starting from
  // "startAddr" address.*/
  /////////////////////////////////////////////////////////////////////////////
  task putData(input bit32 startAddr, bit8 dataInBuff[$]);
    for(int i = 0; i < dataInBuff.size(); i++) begin
      super.ram[startAddr+i] = dataInBuff[i];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollData(): Poll specified address until read data is equal to pollData.
  // If poll counter is reached to "pollTimeOut" value stop polling and
  // generate error message. Poll counter is incrementing after each clock.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollData(input bit32 address, bit8 pollData[$], bit32 pollTimeOut = 1000);
    bit8 dataBuff[$];
    int status;
    string tempStr;
    $display("Polling address 0x%h: @sim time %0d", address, $time);
    do begin
      this.getData(address, dataBuff, pollData.size());
      status = 0;
      for(int i = 0; i < pollData.size(); i++) begin
        if(dataBuff[i] != pollData[i]) begin
          status = 1;
          break;
        end
      end
      if(status == 1) begin
        @super.ifc.cb;
        pollTimeOut--;
      end
    end while((status == 1)&&(pollTimeOut != 0));
    //
    if(status == 1) begin
      this.tr = new();
      $display("Poll Time Out Detected at sim time %0d", $time());
      tempStr.itoa($time);
      this.tr.failedTr     = "Poll TimeOut detected. At simulation time ";
      this.tr.failedTr     = {this.tr.failedTr, tempStr, "ns"};
      super.statusBox.put(this.tr);
      this.tr = null;
    end else begin
      $display("Poll Done!");
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print poll timeout errors if there are any and
  // return errors count. Otherwise return 0.*/
  /////////////////////////////////////////////////////////////////////////////
  function int printStatus();
    this.tr = new();
    printStatus = this.statusBox.num();
    while(this.statusBox.num() != 0)begin
      void'(this.statusBox.try_get(this.tr));
      $display(this.tr.failedTr);
    end
    this.tr = null;
  endfunction
  //
endclass // WSHB_s_env
//
endpackage
