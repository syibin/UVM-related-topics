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

package SPI_M;
typedef bit [7:0]    bit8;
typedef class SPI_m_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(SPI_m_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class SPI_m_busConfig:
///////////////////////////////////////////////////////////////////////////////
class SPI_m_busConfig;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // SPI bus timing control variables
  time                                 t_clk      = 20ns;
  time                                 t_ss_h2l   = 30ns;
  time                                 t_ss_l2h   = 30ns;
  time                                 t_ss_high  = 50ns;
  // SPI mode
  int                                  cpol       = 0;
  int                                  cpha       = 0;
  int                                  msb        = 1;
  int                                  burstSize  = 1;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- setTiming(): Set SPI bus custom timing.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTiming(time t_clk, t_ss_h2l, t_ss_l2h, t_ss_high);
    this.t_clk        = t_clk;
    this.t_ss_h2l     = t_ss_h2l;
    this.t_ss_l2h     = t_ss_l2h;
    this.t_ss_high    = t_ss_high;
  endtask
  //
endclass // SPI_m_busConfig
///////////////////////////////////////////////////////////////////////////////
// Class SPI_m_busTrans:
///////////////////////////////////////////////////////////////////////////////
class SPI_m_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  enum {WRITE_READ, IDLE}             TrType;
  bit8                                dataInBuff[$];
  bit8                                dataOutBuff[$];
  int                                 slaveNum;
  int                                 TrNum;
  int                                 dataLength;
  time                                idleTime;
  //
endclass // SPI_m_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class SPI_m_busBFM:
///////////////////////////////////////////////////////////////////////////////
class SPI_m_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  virtual spi_m_if ifc;
  TransMBox trInBox, trOutBox;
  local SPI_m_busTrans tr;
  local SPI_m_busConfig cfg;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Assign virtual interface, mailboxes and configuration handles
  // created in the SPI_env class to the local variables.*/
  /////////////////////////////////////////////////////////////////////////////
  function new (virtual spi_m_if ifc, input TransMBox trInBox, trOutBox,
                                            SPI_m_busConfig cfg);
    this.ifc             = ifc;
    this.trInBox         = trInBox;
    this.trOutBox        = trOutBox;
    this.cfg             = cfg;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- byteReadWrite(): Generates SPI bus read/write timings for 1 byte data.*/
  /////////////////////////////////////////////////////////////////////////////
  task byteReadWrite(bit8 dataIn, output bit8 dataOut);
    repeat (8) begin
      // In (cpha == 0) mode data should be available before clock fist edge
      // (posedge or negedge depends on cpol)
      #10ps // Delaying data out to be sure that slave read correct data
      if(this.cfg.cpha == 0) begin
        if (this.cfg.msb == 1) this.ifc.mosi            <= dataIn[7];
        else                   this.ifc.mosi            <= dataIn[0];
      end
      // Clock first edge (posedge or negedge)
      #((this.cfg.t_clk/2) - 10ps) this.ifc.sclk <= ~this.ifc.sclk;
      // In (cpha == 0) mode data should be read during current clock edge
      // (posedge or negedge depends on cpol).
      if (this.cfg.cpha == 0) begin
        if (this.cfg.msb == 1) dataOut = {dataOut[6:0], this.ifc.miso};
        else                   dataOut = {this.ifc.miso, dataOut[7:1]};
      end
      #10ps // Delaying data out to be sure that slave read correct data
      if(this.cfg.cpha == 1) begin
        if (this.cfg.msb == 1) this.ifc.mosi            <= dataIn[7];
        else this.ifc.mosi                              <= dataIn[0];
      end
      if (this.cfg.msb == 1) dataIn <<= 1;
      else                   dataIn >>= 1;
      // Clock second edge (posedge or negedge)
      #((this.cfg.t_clk/2) - 10ps) this.ifc.sclk <= ~this.ifc.sclk;
      if (this.cfg.cpha == 1) begin
        if (this.cfg.msb == 1) dataOut = {dataOut[6:0], this.ifc.miso};
        else                   dataOut = {this.ifc.miso, dataOut[7:1]};
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- burstReadWrite(): Generates SPI bus read/write timings. Gets data
  //  from SPI_m_busTrans class.*/
  /////////////////////////////////////////////////////////////////////////////
  local task burstReadWrite();
    bit8 dataOut;
    int  byteCnt;
    this.tr.dataOutBuff = {};
    // Burst start.
    this.ifc.ss[this.tr.slaveNum]    <= 1'b0;
    if (this.cfg.t_ss_h2l > (this.cfg.t_clk/2)) begin
      #(this.cfg.t_ss_h2l - (this.cfg.t_clk/2));
    end
    //
    byteCnt = 0;
    for (int i = 1; i <= this.tr.dataLength; i++) begin
      this.byteReadWrite(this.tr.dataInBuff[i-1], dataOut);
      this.tr.dataOutBuff = {this.tr.dataOutBuff, dataOut};
      byteCnt++;
      if(((i%this.cfg.burstSize) == 0) || (i == this.tr.dataLength)) begin
        byteCnt = 0;
        #this.cfg.t_ss_l2h;
        this.ifc.ss[this.tr.slaveNum]    <= 1'b1;
        #(this.cfg.t_ss_high);
        if(i != this.tr.dataLength) begin
          this.ifc.ss[this.tr.slaveNum]    <= 1'b0;
          if (this.cfg.t_ss_h2l > (this.cfg.t_clk/2)) begin
            #(this.cfg.t_ss_h2l - (this.cfg.t_clk/2));
          end
        end
      end
    end
    //
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for the specified time.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle();
    #this.tr.idleTime;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- init():Set default values for outputs.*/
  /////////////////////////////////////////////////////////////////////////////
  task init();
    this.ifc.ss        <= 8'hff;
    this.ifc.mosi      <= 1'b0;
    if(this.cfg.cpol == 1) this.ifc.sclk <= 1'b1;
    else this.ifc.sclk <= 1'b0;
    #this.cfg.t_ss_high;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop(): Get mailbox data. Check transaction type and call
  //  corresponding function.*/
  /////////////////////////////////////////////////////////////////////////////
  task run_loop();
    // Initial values
    this.init();
    // Main loop
    forever begin
      this.trInBox.get(this.tr);
      if(this.tr.TrType == SPI_m_busTrans::IDLE) begin
        this.busIdle();
      end else if (this.tr.TrType == SPI_m_busTrans::WRITE_READ) begin
        this.burstReadWrite();
        this.trOutBox.put(tr);
      end
    end
  endtask
  //
endclass // SPI_m_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class SPI_m_env:
///////////////////////////////////////////////////////////////////////////////
class SPI_m_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local TransMBox trInBox, trOutBox;
  virtual spi_m_if ifc;
  local SPI_m_busTrans tr;
  local SPI_m_busBFM bfm;
  local SPI_m_busConfig cfg;
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
  function new(virtual spi_m_if ifc);
    this.ifc               = ifc;
    this.trInBox           = new();
    this.trOutBox          = new();
    this.cfg               = new();
    this.bfm               = new (this.ifc, this.trInBox, this.trOutBox, this.cfg);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Starts main loop in the BFM class. Only after this task
  // transactions will appear on the SPI bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      fork
        this.bfm.run_loop();
      join_none
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTiming(): Set SPI bus custom timing. For more information about SPI
  //  timings see SPI bus specification.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTiming(time t_clk, t_ss_h2l, t_ss_l2h, t_ss_high);
    this.cfg.setTiming(t_clk, t_ss_h2l, t_ss_l2h, t_ss_high);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setConfig(): Set burst size and select which bit should be
  //  transmitted first. (MSB or LSB).*/
  /////////////////////////////////////////////////////////////////////////////
  function void setConfig(int msb, burstSize);
    this.cfg.msb        = msb;
    this.cfg.burstSize  = burstSize;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setMode(): Set SPI bus mode. (Polarity and Phase)*/
  /////////////////////////////////////////////////////////////////////////////
  task setMode(int mode);
    // Set SPI mode. Phase.
    if ((mode == 1) || (mode == 3)) this.cfg.cpha = 1;
    else this.cfg.cpha = 0;
    // Set SPI mode. Polarity.
    if ((mode == 2) || (mode == 3)) this.cfg.cpol = 1;
    else this.cfg.cpol = 0;
    this.bfm.init();
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readWriteData(): Initiate SPI read/write transfers. Select specified
  // slave and start data processing. Input and output data buffers are a byte
  // sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task readWriteData(input int slaveNum, bit8 dataInBuff[$],
                     output bit8 dataOutBuff[$], input int dataLength = 0);
    this.tr           = new();
    TrNum++;
    this.tr.TrType    = SPI_m_busTrans::WRITE_READ;
    this.tr.TrNum     = TrNum;
    this.tr.slaveNum  = slaveNum;
    if (dataLength == 0) this.tr.dataLength = dataInBuff.size();
    else this.tr.dataLength = dataLength;
    //
    for (int i = 0; i < dataInBuff.size(); i++) begin
      this.tr.dataInBuff = {this.tr.dataInBuff, dataInBuff[i]};
    end
    this.trInBox.put(this.tr);
    this.trOutBox.get(this.tr);
    dataOutBuff = {};
    for (int i = 0; i < this.tr.dataLength; i++) begin
      dataOutBuff = {dataOutBuff, this.tr.dataOutBuff[i]};
    end
    this.tr = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for a specified time.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle(time idleTime);
    this.tr             = new();
    this.tr.TrType      = SPI_m_busTrans::IDLE;
    this.tr.idleTime    = idleTime;
    this.trInBox.put(this.tr);
    this.tr             = null;
  endtask
  //
endclass // SPI_m_env
//
endpackage
