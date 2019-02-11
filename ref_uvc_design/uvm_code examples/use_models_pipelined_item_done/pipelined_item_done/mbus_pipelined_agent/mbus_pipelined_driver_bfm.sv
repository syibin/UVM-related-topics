//
//------------------------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------
//
// This class implements a pipelined driver
//
import mbus_types_pkg::*;
import mbus_pipelined_agent_pkg::*;

interface mbus_pipelined_driver_bfm (
  input  logic         MCLK,
  input  logic         MRESETN,
  output logic [31:0]  MADDR,
  output logic [31:0]  MWDATA,
  output logic         MREAD,
  output mbus_opcode_e MOPCODE,
  input  logic         MRDY,
  input  logic [31:0]  MRDATA,
  input  mbus_resp_e   MRESP
);

mbus_pipelined_driver proxy;

mbus_seq_item current_tr;

event do_data_phase;

task begin_transfer(mbus_seq_item req);
  command_phase(req);

  pipeline_lock_get(); // Start of data phase: grab semaphore

  current_tr = req;
  ->do_data_phase;
endtask: begin_transfer

always begin
  @do_data_phase;

  @(posedge MCLK);

  data_phase(current_tr);
  proxy.end_transfer(current_tr);

  pipeline_lock_put(); // End of data phase: release semaphore
end

task wait_for_reset();
  @(posedge MRESETN);
  @(posedge MCLK);
endtask

task command_phase(mbus_seq_item req);
  MADDR <= req.MADDR;
  MREAD <= req.MREAD;
  MOPCODE <= req.MOPCODE;
  @(posedge MCLK);
  while (!MRDY == 1) begin
    @(posedge MCLK);
  end
  if (req.MREAD == 0) begin
    MWDATA <= req.MWDATA;
  end
endtask: command_phase

task data_phase(mbus_seq_item req);
  while (MRDY != 1) begin
    @(posedge MCLK);
  end
  req.MRESP = MRESP;
  if (req.MREAD == 1) begin
    req.MRDATA = MRDATA;
  end
endtask: data_phase

bit pipeline_lock = 0;

task pipeline_lock_get();
  while (pipeline_lock) begin
    @(posedge MCLK);
  end
  pipeline_lock = 1;
endtask: pipeline_lock_get

function void pipeline_lock_put();
  pipeline_lock = 0;
endfunction: pipeline_lock_put

endinterface: mbus_pipelined_driver_bfm
