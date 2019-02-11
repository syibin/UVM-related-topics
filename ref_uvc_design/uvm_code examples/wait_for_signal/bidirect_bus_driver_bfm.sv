
//------------------------------------------------------------------------------
//   Copyright 2007-2018 Mentor Graphics Corporation
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

interface bidirect_bus_driver_bfm (
   input  logic        clk,
   input  logic        resetn,
   output logic [31:0] addr,
   output logic [31:0] write_data,
   output logic        rnw,
   output logic        valid,
   input  logic        ready,
   input  logic [31:0] read_data,
   input  logic        error
);

  import bidirect_bus_pkg::*;

  //Notice the automatic keyword.  It should only be used for individaul signal
  // access. Tasks inside of interfaces are static by default
  task automatic wait_for_clock( int n = 1 );
    repeat( n ) @( posedge clk );
  endtask : wait_for_clock

  task automatic wait_for_reset();
    // Wait for reset to end
    @(posedge resetn);
  endtask : wait_for_reset

  function void clear_sigs();
    // Default conditions:
    valid = 0;
    rnw = 1;
  endfunction : clear_sigs

  task drive(bus_seq_item req);
    repeat(req.delay) begin
      @(posedge clk);
    end
    valid = 1;
    addr = req.addr;
    rnw = req.read_not_write;
    if(req.read_not_write == 0) begin
      write_data = req.write_data;
    end
    while(ready != 1) begin
      @(posedge clk);
    end
    if(req.read_not_write == 1) begin
      req.read_data = read_data;
    end
    req.error = error;
    valid = 0; // End the bus transaction
  endtask : drive

endinterface: bidirect_bus_driver_bfm
