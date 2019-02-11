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

package AXI4STR_MONITOR;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [255:0]  bit256;
typedef class AXI4STR_MONITOR_busTrans;
typedef class AXI4STR_MONITOR_busBFM;
typedef class AXI4STR_MONITOR_env;
typedef mailbox #(AXI4STR_MONITOR_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_MONITOR_busTrans:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_MONITOR_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  string                              failedTr;
  time                                transTime;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  //
endclass // AXI4STR_MONITOR_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_MONITOR_busBFM:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_MONITOR_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  // Configuration variables
  string    id_name;
  /////////////////////////////////////////////////////////////////////////////
  virtual axi4_str_monitor_if ifc;
  TransMBox statusBox;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    this.statusBox         = new();
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start main loop.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
    fork
      this.monitor_tid_dest_loop();
    join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- monitor_tid_dest_loop(): Moniotor that tid and tdest values are not
  //                           changing for the whole packet.*/
  /////////////////////////////////////////////////////////////////////////////
  local task monitor_tid_dest_loop();
    AXI4STR_MONITOR_busTrans tr;
    int startPacket;
    bit8 tid, tdest;
    startPacket = 1;
    // Clock alignment
    this.ifc.clockAlign();
    // Start main loop
    forever begin
      do begin
        @this.ifc.cb;
      end while(((this.ifc.cb.tvalid & this.ifc.cb.tready) !== 1'b1));
      // Data processing.
      tr               = new();
      if(startPacket == 1) begin
        tdest          = this.ifc.cb.tdest;
        tid            = this.ifc.cb.tid;
        startPacket    = 0;
      end else begin
        if((tdest != this.ifc.cb.tdest) || (tid != this.ifc.cb.tid)) begin
          tr.failedTr = "Monitor violation: tdest or tid was changed";
          tr.transTime = $time();
          statusBox.put(tr);
        end
      end
      if(this.ifc.cb.tlast == 1'b1) startPacket = 1;
      tr               = null;
    end
  endtask
  //
endclass // AXI4STR_MONITOR_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class AXI4STR_MONITOR_env:
///////////////////////////////////////////////////////////////////////////////
class AXI4STR_MONITOR_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local AXI4STR_MONITOR_busTrans tr;
  local AXI4STR_MONITOR_busBFM   axiBfm;
  local int envStarted;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Takes physical interface as an input value and connects it to
  // virtual interface. Create transaction mailboxes.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual axi4_str_monitor_if ifc);
    this.axiBfm                  = new();
    this.axiBfm.ifc              = ifc;
    this.envStarted              = 0;
    this.axiBfm.id_name          = id_name;
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
  /*- printStatus(): Print poll timeout errors.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    this.tr = new();
    statusBoxSize = this.axiBfm.statusBox.num();
    while(this.axiBfm.statusBox.num() != 0)begin
      void'(this.axiBfm.statusBox.try_get(this.tr));
      $display("Violation: %s", this.tr.failedTr);
      $display("Simulation Time: %f", this.tr.transTime);
    end
    this.tr = null;
    $display("The %s monotor has %d errors", this.axiBfm.id_name, statusBoxSize);
  endfunction
  //
endclass // AXI4STR_MONITOR_env
//
endpackage
