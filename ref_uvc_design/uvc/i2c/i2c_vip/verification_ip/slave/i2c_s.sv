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

package I2C_S;
typedef bit [7:0]    bit8;
typedef class I2C_s_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(I2C_s_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class I2C_s_busConfig:
///////////////////////////////////////////////////////////////////////////////
class I2C_s_busConfig;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  int                                  deviceAddr;
  int                                  ackMode = 0;
  time                                 pollTimeOut = 40ms;
  // I2C bus timing control variables
  string                               busSpeedMode;
  time                                 t_InitDelay;
  time                                 t_Valid;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- speedModeInit(): Set I2C bus timing control variables according to the
  //  selected speed mode.*/
  /////////////////////////////////////////////////////////////////////////////
  function void speedModeInit();
    if(this.busSpeedMode == "Standart") begin
      this.t_InitDelay      = 1us;
      this.t_Valid          = 3450;
    end else if(this.busSpeedMode == "Fast") begin
      this.t_InitDelay      = 500ns;
      this.t_Valid          = 900;
    end else if(this.busSpeedMode == "FastPlus") begin
      this.t_InitDelay      = 100ns;
      this.t_Valid          = 450;
    end
  endfunction
endclass // I2C_s_busConfig
///////////////////////////////////////////////////////////////////////////////
// Class I2C_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class I2C_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  enum {WRITE, READ}           TrType;
  bit   [6:0]                  address;
  bit8                         dataByte;
  string                       failedTrInfo;
  //
endclass // I2C_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class I2C_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class I2C_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  TransMBox statusBox;
  virtual i2c_s_if ifc;
  local I2C_s_busTrans tr;
  local I2C_s_busConfig cfg;
  bit8  ramArray [256];
  bit8  ramAddr;
  int   addrOverflow;
  event memWrite;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Assign virtual interface, mailboxe and configuration handles
  // created in the I2C_env class to the local variables.*/
  /////////////////////////////////////////////////////////////////////////////
  function new (virtual i2c_s_if ifc, I2C_s_busConfig cfg, TransMBox statusBox);
    this.ifc             = ifc;
    this.cfg             = cfg;
    this.statusBox       = statusBox;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- sclPosedge(): After scl posedge wait 1 time step to avoid races.*/
  /////////////////////////////////////////////////////////////////////////////
  task sclPosedge();
    @(posedge this.ifc.scl);#1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- sclNegedge(): After scl negedge wait 1 time step to avoid races.*/
  /////////////////////////////////////////////////////////////////////////////
  task sclNegedge();
    @(negedge this.ifc.scl);#1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getAddress(): Get I2C slave address and generate acknowledge if the
  //  address is equal to configured one.*/
  /////////////////////////////////////////////////////////////////////////////
  local task getAddress();
    repeat (8) begin
      this.sclPosedge();
      this.tr.dataByte = {this.tr.dataByte[6:0],  this.ifc.sda};
    end
    this.tr.address = this.tr.dataByte[7:1];
    // Acknowledge
    this.sclNegedge();
    #this.cfg.t_Valid;
    if(this.tr.address == this.cfg.deviceAddr) begin
      this.ifc.sda_oe  <= 1'b0;
    end
      this.sclPosedge();
      this.sclNegedge();
      #(this.cfg.t_Valid-2);
      this.ifc.sda_oe  <= 1'b1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- masterWrite():*/
  /////////////////////////////////////////////////////////////////////////////
  local task masterWrite(output int stopRepeat);
    string tempStr;
    while (1) begin
      this.sclPosedge();
      this.tr.dataByte = {this.tr.dataByte[6:0],  this.ifc.sda};
      @(negedge this.ifc.scl or this.ifc.sda);
      if(this.ifc.scl == 1'b1) begin
        if(this.ifc.sda) stopRepeat = 1;
        else stopRepeat = 0;
        return;
      end
      repeat (7) begin
        this.sclPosedge();
        this.tr.dataByte = {this.tr.dataByte[6:0],  this.ifc.sda};
      end
      if(this.addrOverflow == 0) begin
        this.ramArray[this.ramAddr] = this.tr.dataByte;
        ->this.memWrite;
      end else begin
        $display("Memory overflow Detected at sim time %0d", $time());
        tempStr.itoa($time);
        this.tr.failedTrInfo     = "Memory overflow detected. At simulation time ";
        this.tr.failedTrInfo     = {this.tr.failedTrInfo, tempStr, "ns"};
        this.statusBox.put(tr);
      end
      this.ramAddr++;
      // Acknowledge
      this.sclNegedge();
      #this.cfg.t_Valid;
      if(this.addrOverflow == 0) begin
        this.ifc.sda_oe  <= 1'b0;
      end
      this.sclPosedge();
      this.sclNegedge();
      #(this.cfg.t_Valid-2);
      this.ifc.sda_oe  <= 1'b1;
      if ((this.ramAddr == 0) && (this.cfg.ackMode == 1)) begin
        this.addrOverflow = 1;
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- masterRead():*/
  /////////////////////////////////////////////////////////////////////////////
  local task masterRead(output int stopRepeat);
    int ack;
    do begin
      this.tr.dataByte = this.ramArray[this.ramAddr];
      repeat (8) begin
        this.ifc.sda_oe    <= this.tr.dataByte[7];
        this.sclPosedge();
        this.sclNegedge();
        #(this.cfg.t_Valid-1);
        this.tr.dataByte = this.tr.dataByte[6:0] << 1;
      end
      // Acknowledge
      this.ifc.sda_oe  <= 1'b1;
      this.sclPosedge();
      ack = this.ifc.sda;
      this.sclNegedge();
      #(this.cfg.t_Valid);
      this.ramAddr++;
    end while (ack == 0);
      this.sclPosedge();
      if(this.ifc.sda == 1'b0) stopRepeat = 1;
      else stopRepeat = 0;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop():*/
  /////////////////////////////////////////////////////////////////////////////
  task run_loop();
    int stopRepeat;
    this.tr = new();
    this.ifc.sda_oe  <= 1'b1;
    #this.cfg.t_InitDelay;
    forever begin
      // Wait for start condition
      do @(negedge this.ifc.sda);
      while (this.ifc.scl == 1'b0);
      // Wait for start repeat condition
      do begin
        this.addrOverflow = 0;
        this.ramAddr = 8'd0;
        this.sclNegedge();
        // Address phase
        this.getAddress();
        if(this.tr.address != this.cfg.deviceAddr) begin
          break;
        end
        if(this.tr.dataByte[0]) begin
          this.tr.TrType = I2C_s_busTrans::READ;
        end else begin
          this.tr.TrType = I2C_s_busTrans::WRITE;
        end
        // Data phase
        if(this.tr.TrType == I2C_s_busTrans::READ) begin
          this.masterRead(stopRepeat);
        end else begin
          this.masterWrite(stopRepeat);
        end
      end while (stopRepeat == 0);
    end
  endtask
  //
endclass // I2C_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class I2C_s_env:
///////////////////////////////////////////////////////////////////////////////
class I2C_s_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local TransMBox statusBox;
  virtual i2c_s_if ifc;
  local I2C_s_busBFM bfm;
  local I2C_s_busConfig cfg;
  local I2C_s_busTrans tr;
  local int envStarted = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to the virtual.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(virtual i2c_s_if ifc, string busSpeedMode, int deviceAddr);
    if((busSpeedMode != "Standart") && (busSpeedMode != "Fast") &&
       (busSpeedMode != "FastPlus")) begin
      $display("Error: Wrong speed mode selected.");
      $finish;
    end
    this.ifc               = ifc;
    this.cfg               = new();
    this.statusBox         = new();
    this.bfm               = new (this.ifc, this.cfg, this.statusBox);
    this.cfg.busSpeedMode  = busSpeedMode;
    this.setAddress(deviceAddr);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start main loop in the BFM class.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      this.cfg.speedModeInit();
      fork
        this.bfm.run_loop();
      join_none
      envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setSpeedMode(): Set bus speed mode. Use "Standart", "Fast",
  //  and "FastPlus" values for corresponding speed mode.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setSpeedMode(string busSpeedMode);
    if((busSpeedMode != "Standart") && (busSpeedMode != "Fast") &&
       (busSpeedMode != "FastPlus")) begin
      $display("Error: Wrong speed mode selected.");
      $finish;
    end
    this.cfg.busSpeedMode  = busSpeedMode;
    this.cfg.speedModeInit();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setAddress(): Set slave device address.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setAddress(int deviceAddr);
    this.cfg.deviceAddr = deviceAddr;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setAckMode(): Enables or disables not acknowledge generation during
  //  memory overflow. If it is enabled not acknowledge will be generated and
  //  memory will not be overwritten.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setAckMode(int ackMode);
    this.cfg.ackMode = ackMode;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setPollTimeOut(): Sets the maximum poll time after which poll task will
  //  be stopped and poll time out error message generated.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setPollTimeOut(time pollTimeOut);
    this.cfg.pollTimeOut = pollTimeOut;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- putData(): Put data buffer to the memory starting from "startAddr"
  // address. Input data buffer is a bytes sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task putData (input bit8 startAddr, bit8 dataInBuff[$]);
    for (int i = 0; i < dataInBuff.size(); i++) begin
      this.bfm.ramArray[startAddr+i] = dataInBuff[i];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- putWord(): Put one byte data to the memory.*/
  /////////////////////////////////////////////////////////////////////////////
  function void putWord (input bit8 address, bit8 dataWord);
    this.bfm.ramArray[address]   = dataWord;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- getWord(): Get one byte data from the memory.*/
  /////////////////////////////////////////////////////////////////////////////
  function bit8 getWord (input bit8 address);
    getWord = this.bfm.ramArray[address];
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get data buffer from the memory starting from "startAddr"
  //  address. Output data buffer is a bytes sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(input bit8 startAddr, output bit8 dataOutBuff[$], input int lenght);
    dataOutBuff = {};
    for(int i = 0; i < lenght; i++) begin
      dataOutBuff = {dataOutBuff, this.bfm.ramArray[startAddr+i]};
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollWord(): Poll internal memory address until the data word is equal
  //  to expected data. If time out occurres generates error message and
  //  returns.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollWord(bit8 memAddr, expWord);
    string tempStr;
    $display("Polling data at address 0x%h: @sim time %0d", memAddr, $time);
    fork: poll_loop
      begin
        while(this.bfm.ramArray[memAddr] != expWord) begin
          @(this.bfm.memWrite);
        end
         $display("Poll Done!");
      end
      begin
        #this.cfg.pollTimeOut;
        this.tr = new();
        $display("Poll Time Out Detected at sim time %0d", $time());
        tempStr.itoa($time);
        this.tr.failedTrInfo     = "Poll TimeOut detected. At simulation time ";
        this.tr.failedTrInfo     = {this.tr.failedTrInfo, tempStr, "ns"};
        this.statusBox.put(tr);
        this.tr = null;
      end
    join_any
    disable poll_loop;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print memory overflow and poll time out errors. Return
  // error count.*/
  /////////////////////////////////////////////////////////////////////////////
  function int printStatus();
    this.tr = new();
    printStatus = this.statusBox.num();
    while(this.statusBox.num() != 0)begin
      void'(this.statusBox.try_get(tr));
      $display(this.tr.failedTrInfo);
    end
    this.tr = null;
  endfunction
  //
endclass // I2C_s_env
//
endpackage
