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
// This example illustrates how to implement a unidirectional sequence-driver use model.
// The example used is an ADPCM like undirectional communication protocol. There is no
// response, so there is no DUT, just an interface.
//

module top_hdl;

adpcm_if ADPCM();

adpcm_driver_bfm adpcm_drv(
   .clk   (ADPCM.clk),
   .frame (ADPCM.frame),
   .data  (ADPCM.data)
);

// Free running clock
initial begin
  ADPCM.clk = 0;
  forever begin
    #10 ADPCM.clk = ~ADPCM.clk;
  end
end

initial begin
  uvm_pkg::uvm_config_db #(virtual adpcm_driver_bfm)::
    set(null, "uvm_test_top", "adpcm_drv_bfm" , adpcm_drv);
end

endmodule: top_hdl


interface adpcm_if;

logic clk;
logic frame;
logic[3:0] data;

endinterface: adpcm_if


interface adpcm_driver_bfm (
   input  logic       clk,
   output logic       frame,
   output logic [3:0] data
);

import adpcm_pkg::*;

initial begin
  frame <= 0;
  data <= 0;
end

task drive(adpcm_seq_item req);
  repeat (req.delay) begin // Delay between packets
    @(posedge clk);
  end

  frame <= 1; // Start of frame

  for (int i = 0; i < 8; i++) begin // Send nibbles
    @(posedge clk);
    data <= req.data[3:0];
    req.data = req.data >> 4;
  end

  frame <= 0; // End of frame
endtask: drive

endinterface: adpcm_driver_bfm
