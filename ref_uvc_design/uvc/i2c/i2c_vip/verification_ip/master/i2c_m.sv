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

package I2C_M;
typedef bit [7:0]    bit8;
typedef class I2C_m_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(I2C_m_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class I2C_m_busConfig:
///////////////////////////////////////////////////////////////////////////////
class I2C_m_busConfig;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // I2C bus timing control variables
  string                               busSpeedMode;
  time                                 t_InitDelay;
  time                                 t_Low;
  time                                 t_High;
  time                                 t_HoldStart;
  time                                 t_SetupStart;
  time                                 t_HoldData;
  time                                 t_SetupData;
  time                                 t_Buff;
  time                                 t_Valid;
  time                                 t_SetupStop;
  // Error control variables
  string                               notAck = "Not acknowledge detected.";
  // Address mode
  int                                  addrMode = 0;
  // Randomization level
  int                                  rndLevel = 0;
  // Constraint control variables
  int                                  t_step;
  int                                  t_max;
  time                                 t_LowMin;
  rand int                             t_LowTemp;
  time                                 t_HighMin;
  rand int                             t_HighTemp;
  time                                 t_HoldStartMin;
  rand int                             t_HoldStartTemp;
  time                                 t_SetupStartMin;
  rand int                             t_SetupStartTemp;
  time                                 t_BuffMin;
  rand int                             t_BuffTemp;
  time                                 t_SetupStopMin;
  rand int                             t_SetupStopTemp;
  // Random constraints for I2C bus timing variables
  constraint c_timing {
    this.t_LowTemp          inside {[0:this.t_max]};
    this.t_HighTemp         inside {[0:this.t_max]};
    this.t_HoldStartTemp    inside {[0:this.t_max]};
    this.t_SetupStartTemp   inside {[0:this.t_max]};
    this.t_BuffTemp         inside {[0:this.t_max]};
    this.t_SetupStopTemp    inside {[0:this.t_max]};
  }
  // Post randomize
  function void post_randomize;
    this.t_Low          = this.t_LowMin + this.t_LowTemp*t_step;
    this.t_High         = this.t_HighMin + this.t_HighTemp*t_step;
    this.t_HoldStart    = this.t_HoldStartMin + this.t_HoldStartTemp*t_step;
    this.t_SetupStart   = this.t_SetupStartMin + this.t_SetupStartTemp*t_step;
    this.t_Buff         = this.t_BuffMin + this.t_BuffTemp*t_step;
    this.t_SetupStop    = this.t_SetupStopMin + this.t_SetupStopTemp*t_step;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- speedModeInit(): Set all I2C bus timing control variables acording to
  //  speed mode.*/
  /////////////////////////////////////////////////////////////////////////////
  task speedModeInit();
    if(this.busSpeedMode == "Standart") begin
      this.setTiming(5us, 5us, 5us, 5us, 300ns, 250ns, 5us, 3450ns, 5us);
      this.t_InitDelay      = 5us;
      this.t_step           = 1000;
    end else if(this.busSpeedMode == "Fast") begin
      this.setTiming(1600, 900, 900, 900, 300, 100, 1600, 900, 900);
      this.t_InitDelay      = 2000;
      this.t_step           = 250;
    end else if(this.busSpeedMode == "FastPlus") begin
      this.setTiming(620, 380, 380, 380, 300, 50, 620, 450, 380);
      this.t_InitDelay      = 1000;
      this.t_step           = 100;
    end
    // Random constraints
    this.t_LowMin         = this.t_Low;
    this.t_HighMin        = this.t_High;
    this.t_HoldStartMin   = this.t_HoldStart;
    this.t_SetupStartMin  = this.t_SetupStart;
    this.t_BuffMin        = this.t_Buff;
    this.t_SetupStopMin   = this.t_SetupStop;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- genRndDelay(): Randomize all random variables in the class.*/
  /////////////////////////////////////////////////////////////////////////////
  function void genRndDelay();
    assert (this.randomize())
    else $fatal(0, "I2C_m_busConfig: Randomize failed");
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Enable random delays and set random constraints.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRndDelay(int t_max, rndLevel);
    this.t_max    = t_max;
    this.rndLevel = rndLevel;
    this.c_timing.constraint_mode(1);
    this.rand_mode(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTiming(): Set I2C bus custom timing.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTiming(time t_Low, t_High, t_HoldStart, t_SetupStart,
                              t_HoldData, t_SetupData, t_Buff, t_Valid, t_SetupStop);
    this.rand_mode(0);
    this.constraint_mode(0);
    this.t_Low        = t_Low;
    this.t_High       = t_High;
    this.t_HoldStart  = t_HoldStart;
    this.t_SetupStart = t_SetupStart;
    this.t_HoldData   = t_HoldData;
    this.t_SetupData  = t_SetupData;
    this.t_Buff       = t_Buff;
    this.t_Valid      = t_Valid;
    this.t_SetupStop  = t_SetupStop;
  endtask
  //
endclass // I2C_m_busConfig
///////////////////////////////////////////////////////////////////////////////
// Class I2C_m_busTrans:
///////////////////////////////////////////////////////////////////////////////
class I2C_m_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  enum {WRITE, READ, IDLE, WAIT}      TrType;
  bit8                                address;
  bit8                                dataBuff[];
  int                                 genStop;
  int                                 TrNum;
  int                                 dataLength;
  time                                idleTime;
  string                              failedTrInfo;
  //
endclass // I2C_m_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class I2C_m_busBFM:
///////////////////////////////////////////////////////////////////////////////
class I2C_m_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  virtual i2c_m_if ifc;
  TransMBox trInBox, trOutBox, statusBox;
  local I2C_m_busTrans tr;
  local I2C_m_busConfig cfg;
  local int blockCnt = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Assign virtual interface, mailboxes and configuration handles
  // created in the I2C_env class to the local variables.*/
  /////////////////////////////////////////////////////////////////////////////
  function new (virtual i2c_m_if ifc,
                input TransMBox trInBox, trOutBox,
                statusBox, I2C_m_busConfig cfg);
    this.ifc             = ifc;
    this.trInBox         = trInBox;
    this.trOutBox        = trOutBox;
    this.statusBox       = statusBox;
    this.cfg             = cfg;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- byteWrite(): Write one byte and get acknowledge bit.*/
  /////////////////////////////////////////////////////////////////////////////
  local task byteWrite(bit8 dataIn, output bit ack);
    if(this.cfg.rndLevel > 0) this.cfg.genRndDelay();
    for (int i = 0; i < 8; i++) begin
      // Set data bit.
      this.ifc.sda_oe    <= dataIn[7];
      // Wait for one clock cycles before SCK posedge. Satisfy data
      // set-up time.
      #this.cfg.t_SetupData;
      this.ifc.scl_oe     <= 1'b1;
      if(this.cfg.rndLevel > 1) this.cfg.genRndDelay();
      #this.cfg.t_High;
      this.ifc.scl_oe     <= 1'b0;
      // After last bit release SDA. Prepare bus for acknowledge bit.
      if (i != 7) begin
        #(this.cfg.t_Low - this.cfg.t_SetupData);
      end
      dataIn <<= 1;
    end
    // Acknowledge
    #this.cfg.t_Valid;
    this.ifc.sda_oe    <= 1'b1;
    #(this.cfg.t_Low - this.cfg.t_Valid);
    this.ifc.scl_oe     <= 1'b1;
    #1
    ack = ifc.sda;
    #(this.cfg.t_High-1);
    this.ifc.scl_oe     <= 1'b0;
    #this.cfg.t_Valid;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- byteRead(): Read one byte and write acknowledge bit.*/
  /////////////////////////////////////////////////////////////////////////////
  local task byteRead(bit ack, output bit8 dataOut);
    if(this.cfg.rndLevel > 0) this.cfg.genRndDelay();
    for (int i = 0; i < 8; i++) begin
      this.ifc.scl_oe     <= 1'b1;
      #1;
      dataOut          = {dataOut[6:0], ifc.sda};
      #(this.cfg.t_High - 1);
      if(this.cfg.rndLevel > 1) this.cfg.genRndDelay();
      this.ifc.scl_oe     <= 1'b0;
      if(i != 7) begin
        #(this.cfg.t_Low);
      end
    end
    // Acknowledge
    #(this.cfg.t_Valid);
    this.ifc.sda_oe    <= ack;
    #(this.cfg.t_Low - this.cfg.t_Valid);
    this.ifc.scl_oe     <= 1'b1;
    #(this.cfg.t_High);
    this.ifc.scl_oe     <= 1'b0;
    #(this.cfg.t_Valid);
    this.ifc.sda_oe    <= 1'b1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- burstReadWrite(): Generates I2C bus read/write timings. Gets address,
  //  data and transaction type(read/write) from I2C_m_busTrans class.*/
  /////////////////////////////////////////////////////////////////////////////
  local task burstReadWrite();
    string faildInfo, tempStr;
    bit ack;
    if(this.cfg.rndLevel == 0) this.cfg.genRndDelay();
    // Generate I2C start condition
    this.ifc.sda_oe    <= 1'b0;
    #this.cfg.t_HoldStart;
    this.ifc.scl_oe     <= 1'b0;
    #(this.cfg.t_Low - this.cfg.t_SetupData);
    // Send address and read/write bits
    this.byteWrite({this.tr.address[6:0], (this.tr.TrType == I2C_m_busTrans::READ)}, ack);
    if(ack == 1'b0) begin
      if(this.tr.TrType == I2C_m_busTrans::WRITE) begin
        // Send data buffer
        for (int i = 0; i < this.tr.dataLength; i++) begin
          #(this.cfg.t_Low - this.cfg.t_Valid - this.cfg.t_SetupData);
          this.byteWrite(this.tr.dataBuff[i], ack);
          if(ack == 1'b1) break;
        end
      end else begin
        // Recieve data buffer
        for (int i = 0; i < this.tr.dataLength; i++) begin
          #(this.cfg.t_Low - this.cfg.t_Valid);
          this.byteRead(((i+1) == this.tr.dataLength), this.tr.dataBuff[i]);
        end
      end
    end
    if (ack == 1'b1) begin
      faildInfo.itoa(this.tr.TrNum);
      faildInfo = {this.cfg.notAck, " Transaction number is ",faildInfo};
      faildInfo = {faildInfo, "\nSimulation time is "};
      tempStr.itoa($time);
      faildInfo = {faildInfo, tempStr, "ns"};
      this.tr.failedTrInfo = faildInfo;
      this.statusBox.put(this.tr);
    end
    // Generate stop condition or prepare for start repeat.
    if (this.tr.genStop == 1) begin
      this.ifc.sda_oe    <= 1'b0;
      #(this.cfg.t_Low - this.cfg.t_Valid);
      this.ifc.scl_oe     <= 1'b1;
      #(this.cfg.t_SetupStop);
      this.ifc.sda_oe    <= 1'b1;
      #(this.cfg.t_Buff);
    end else begin
      ifc.sda_oe    <= 1'b1;
      #(this.cfg.t_Low - this.cfg.t_Valid);
      this.ifc.scl_oe     <= 1'b1;
      #(this.cfg.t_SetupStart);
    end
    this.ifc.sda_oe      <= 1'b1;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for corresponding clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle();
    #this.tr.idleTime;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop(): Poll "trInBox" mailboxes until it is not empty.
  // Check transaction type and call corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task run_loop();
    // Initial values
    this.ifc.sda_oe    <= 1'b1;
    this.ifc.scl_oe     <= 1'b1;
    #this.cfg.t_InitDelay;
    // Main loop
    forever begin
      this.trInBox.get(this.tr);
      if(this.tr.TrType == I2C_m_busTrans::IDLE) begin
        this.busIdle();
      end else if (this.tr.TrType == I2C_m_busTrans::WAIT) begin
        this.trOutBox.put(tr);
      end else begin
        this.burstReadWrite();
      end
      // During read transaction put read data to the "trOutBox"
      if(this.tr.TrType == I2C_m_busTrans::READ)begin
        this.trOutBox.put(tr);
      end
    end
  endtask
  //
endclass // I2C_m_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class I2C_m_env:
///////////////////////////////////////////////////////////////////////////////
class I2C_m_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local TransMBox trInBox, trOutBox, statusBox;
  virtual i2c_m_if ifc;
  local I2C_m_busTrans tr;
  local I2C_m_busBFM bfm;
  local I2C_m_busConfig cfg;
  // "TrNum": Is storing transactions count during all simulation time.
  local int TrNum = 0;
  local int envStarted = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Takes physical interface as an input value and connects it to
  // virtual interface. Creates transaction mailbox, configuration and BFM
  // objects.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(virtual i2c_m_if ifc, string busSpeedMode);
    if((busSpeedMode != "Standart") && (busSpeedMode != "Fast") &&
       (busSpeedMode != "FastPlus")) begin
      $display("Error: Wrong speed mode selected.");
      $finish;
    end
    this.ifc               = ifc;
    this.trInBox           = new();
    this.trOutBox          = new();
    this.statusBox       = new();
    this.cfg               = new();
    this.bfm               = new (ifc, trInBox, trOutBox, statusBox, cfg);
    this.cfg.busSpeedMode  = busSpeedMode;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Starts main loop in the BFM class. Only after this task
  // transactions will appear on the I2C bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      this.cfg.speedModeInit();
      fork
        this.bfm.run_loop();
      join_none
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setSpeedMode(): Set I2C bus speed mode. Use "Standart", "Fast",
  //  and "FastPlus" values for corresponding speed mode.*/
  /////////////////////////////////////////////////////////////////////////////
  task setSpeedMode(string busSpeedMode);
    if((busSpeedMode != "Standart") && (busSpeedMode != "Fast") &&
       (busSpeedMode != "FastPlus")) begin
      $display("Error: Wrong speed mode selected.");
      $finish;
    end
    this.cfg.busSpeedMode  = busSpeedMode;
    this.cfg.speedModeInit();
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setAddrMode(): Sets I2C bus address mode. 0 specifies 7 bit and 1
  //  specifies 10 bit address mode.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setAddrMode(int addrMode);
    this.cfg.addrMode = addrMode;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setTiming(): Set I2C bus custom timing. For more information about I2C
  //  timings see I2C bus specification.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTiming(time t_Low, t_High, t_HoldStart, t_SetupStart, t_HoldData,
                     t_SetupData, t_Buff, t_Valid, t_SetupStop);
    this.cfg.setTiming(t_Low, t_High, t_HoldStart, t_SetupStart, t_HoldData,
                       t_SetupData, t_Buff, t_Valid, t_SetupStop);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRndDelay(): Enable random delays. Set maximum allowed delays and
  // randomization level.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRndDelay(int t_max, rndLevel);
    this.cfg.setRndDelay(t_max, rndLevel);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setErrMsg(): The specified string will be displayed when acknowledge
  //  error is detected.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setErrMsg (string errMsgStr);
    this.cfg.notAck = errMsgStr;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- writeData(): Generate Start condition then send address, write bit and
  // data buffer. If "genStop" is 1 then generate stop condition.
  // Input data buffer is a byte sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task writeData(input int address, bit8 dataInBuff[$], int genStop = 0);
    this.tr         = new();
    TrNum++;
    this.tr.TrType  = I2C_m_busTrans::WRITE;
    if(this.cfg.addrMode == 0) begin
      // 7 bit address mode
      this.tr.address     = address;
      this.tr.dataBuff    = new[dataInBuff.size()];
      this.tr.dataBuff[0] = dataInBuff[0];
    end else begin
      // 10 bit address mode
      this.tr.address     = {6'b011110, address[9:8]};
      this.tr.dataBuff    = new[(dataInBuff.size()+1)];
      this.tr.dataBuff[0] = address[7:0];
    end
    this.tr.TrNum   = TrNum;
    this.tr.dataLength = this.tr.dataBuff.size();
    this.tr.genStop    = genStop;
    for (int i = 1; i < this.tr.dataLength; i++) begin
      this.tr.dataBuff[i] = dataInBuff[i];
    end
    this.trInBox.put(this.tr);
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readData(): Generate Start condition then send address, read bit. Read
  // data and put to the output data buffer. If "genStop" is 1 then generate
  // stop condition.
  // Output data buffer is a byte sequence (SystemVerilog queue)*/
  /////////////////////////////////////////////////////////////////////////////
  task readData(input int address, output bit8 dataOutBuff[$], input int lenght, genStop = 0);
    this.tr         = new();
    if(this.cfg.addrMode == 1) begin
      // 10 bit address mode
      this.writeData({6'b011110, address[9:8]}, {address[7:0]}, 0);
      this.tr.address = {6'b011110, address[9:8]};
      this.tr.genStop  = 1;
    end else begin
      // 7 bit address mode
      this.tr.genStop  = genStop;
      this.tr.address   = address;
    end
    TrNum++;
    this.tr.TrType  = I2C_m_busTrans::READ;
    this.tr.TrNum   = TrNum;
    this.tr.dataBuff = new[lenght];
    this.tr.dataLength = lenght;
    this.trInBox.put(this.tr);
    this.trOutBox.get(this.tr);
    dataOutBuff = {};
    for (int i = 0; i < lenght; i++) begin
      dataOutBuff[i] = this.tr.dataBuff[i];
    end
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for a specified time.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle(time idleTime);
    this.tr             = new();
    this.tr.TrType      = I2C_m_busTrans::IDLE;
    this.tr.idleTime    = idleTime;
    this.trInBox.put(this.tr);
    this.tr             = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- softReset(): Send soft reset command to all slave devices.*/
  /////////////////////////////////////////////////////////////////////////////
  task softReset();
    int addrMode;
    addrMode = this.cfg.addrMode;
    this.cfg.addrMode = 0;
    this.writeData(7'd0, {8'h06});
    this.cfg.addrMode = addrMode;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- waitCommandDone(): Wait untill all instructions in the input mailbox are
  //  finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task waitCommandDone();
    this.tr         = new();
    this.tr.TrType  = I2C_m_busTrans::WAIT;
    this.trInBox.put(this.tr);
    this.trOutBox.get(this.tr);
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print all not acknoledge errors if there are any and
  // return error count. Otherwise return 0.*/
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
endclass // I2C_m_env
//
endpackage
