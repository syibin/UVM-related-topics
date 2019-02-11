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

package SPI_S;
typedef bit [7:0]    bit8;
typedef class SPI_s_busTrans;
`ifdef VCS
typedef mailbox TransMBox;
`else
typedef mailbox #(SPI_s_busTrans) TransMBox;
`endif
///////////////////////////////////////////////////////////////////////////////
// Class SPI_s_busConfig:
///////////////////////////////////////////////////////////////////////////////
class SPI_s_busConfig;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  time                                 pollTimeOut  = 40ms;
  // SPI bus timing control variables
  time                                 t_InitDelay  = 20ns;
  // SPI mode
  int                                  cpol         = 0;
  int                                  cpha         = 0;
  int                                  msb          = 1;
  int                                  burstSize    = 1;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////

endclass // SPI_s_busConfig
///////////////////////////////////////////////////////////////////////////////
// Class SPI_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class SPI_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  bit8                         dataByte;
  //
endclass // SPI_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class SPI_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class SPI_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local TransMBox inBox, outBox;
  virtual spi_s_if ifc;
  local SPI_s_busTrans tr;
  local SPI_s_busConfig cfg;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Assign virtual interface, mailbox and configuration handles
  // created in the SPI_env class to the local variables.*/
  /////////////////////////////////////////////////////////////////////////////
  function new (virtual spi_s_if ifc, SPI_s_busConfig cfg, TransMBox inBox, outBox);
    this.ifc             = ifc;
    this.cfg             = cfg;
    this.inBox           = inBox;
    this.outBox          = outBox;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop():*/
  /////////////////////////////////////////////////////////////////////////////
  task run_loop();
    bit8 sendData, receiveData;
    this.ifc.miso  <= 1'b0;
    #this.cfg.t_InitDelay;
    forever begin
      // Wait for slave select negedge to start burst processing
      @(negedge this.ifc.ss);
      //
      for (int i = 0; i < this.cfg.burstSize; i++) begin
        // Get data from input buffer
        if(this.inBox.try_get(this.tr) == 0) begin
          sendData = 8'haa;
        end else begin
          sendData = this.tr.dataByte;
        end
        repeat(8) begin
          // If cpha is 0 then data should be available before first clock edge
          #10ps // Delaying data out to be sure that master read correct data
          if(this.cfg.cpha == 0) begin
            if (this.cfg.msb) begin
              this.ifc.miso  <= sendData[7];
              sendData <<= 1;
            end else begin
              this.ifc.miso  <= sendData[0];
              sendData >>= 1;
            end
          end
          // Wait for first clock edge
          if(this.cfg.cpol == 0) @(posedge this.ifc.sclk);
          else @(negedge this.ifc.sclk);
          // If cpha is 0 then data should be read after first clock edge
          if(this.cfg.cpha == 0) begin
            if (this.cfg.msb) receiveData = {receiveData[6:0], this.ifc.mosi};
            else receiveData = {this.ifc.mosi, receiveData[7:1]};
          end
          // If cpha is 1 then data should be available after first clock edge
          #10ps // Delaying data out to be sure that master read correct data
          if(this.cfg.cpha == 1) begin
            if (this.cfg.msb) begin
              this.ifc.miso  <= sendData[7];
              sendData <<= 1;
            end else begin
              this.ifc.miso  <= sendData[0];
              sendData >>= 1;
            end
          end
          // Wait for second clock edge
          if(this.cfg.cpol == 0) @(negedge this.ifc.sclk);
          else @(posedge this.ifc.sclk);
          // If cpha is 1 then data should be read after second clock edge
          if(this.cfg.cpha == 1) begin
            if (this.cfg.msb) receiveData = {receiveData[6:0], this.ifc.mosi};
            else receiveData = {this.ifc.mosi, receiveData[7:1]};
          end
        end
        // Put master written data to the output buffer
        this.tr = new();
        this.tr.dataByte = receiveData;
        this.outBox.put(this.tr);
        this.tr = null;
      end
      // Wait for slave select posedge to finish burst
      @(posedge this.ifc.ss);
    end
  endtask
  //
endclass // SPI_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class SPI_s_env:
///////////////////////////////////////////////////////////////////////////////
class SPI_s_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local TransMBox inBox, outBox;
  virtual spi_s_if ifc;
  local SPI_s_busBFM bfm;
  local SPI_s_busConfig cfg;
  local SPI_s_busTrans tr;
  local int envStarted = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to the virtual.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(virtual spi_s_if ifc);
    this.ifc               = ifc;
    this.cfg               = new();
    this.inBox             = new();
    this.outBox            = new();
    this.bfm               = new (this.ifc, this.cfg, this.inBox, this.outBox);
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start main loop in the BFM class.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      fork
        this.bfm.run_loop();
      join_none
      envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setMode(): Set SPI bus mode. (Polarity and Phase)*/
  /////////////////////////////////////////////////////////////////////////////
  function void setMode(int mode);
    // Set SPI mode. Phase.
    if ((mode == 1) || (mode == 3)) this.cfg.cpha = 1;
    else this.cfg.cpha = 0;
    // Set SPI mode. Polarity.
    if ((mode == 2) || (mode == 3)) this.cfg.cpol = 1;
    else this.cfg.cpol = 0;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setPollTimeOut(): Sets the maximum poll time after which poll task will
  //  be stopped and poll time out error message generated.*/
  /////////////////////////////////////////////////////////////////////////////
  function void setPollTimeOut(time pollTimeOut);
    this.cfg.pollTimeOut = pollTimeOut;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- setConfig(): Set burst size and select which bit should be
  //  transmitted first. (MSB or LSB).*/
  /////////////////////////////////////////////////////////////////////////////
  function void setConfig(int msb, burstSize);
    this.cfg.msb        = msb;
    this.cfg.burstSize  = burstSize;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- putData(): Put data to the input buffer. It will be read by master.*/
  /////////////////////////////////////////////////////////////////////////////
  task putData (bit8 dataInBuff[$]);
    for (int i = 0; i < dataInBuff.size(); i++) begin
      this.tr           = new();
      this.tr.dataByte  = dataInBuff[i];
      this.inBox.put(this.tr);
      this.tr           = null;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get data buffer from the memory starting from "startAddr"
  //  address. Output data buffer is a bytes sequence (SystemVerilog queue).*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(output bit8 dataOutBuff[$], input int lenght);
    dataOutBuff.delete();
    for(int i = 0; i < lenght; i++) begin
      this.tr           = new();
      fork: wait_data
        this.outBox.get(this.tr);
        begin
          #this.cfg.pollTimeOut;
          $display("Error: TimeOut detected");
        end
      join_any
      disable wait_data;
      dataOutBuff = {dataOutBuff, this.tr.dataByte};
      this.tr           = null;
    end
  endtask
  //
endclass // SPI_s_env
//
endpackage
