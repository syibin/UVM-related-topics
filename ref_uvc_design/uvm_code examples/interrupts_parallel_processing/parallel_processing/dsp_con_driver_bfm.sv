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

interface dsp_con_driver_bfm (
  input  logic clk,
  input  logic rst,
  output logic go_0,
  output logic go_1,
  output logic go_2,
  output logic go_3
);

  import dsp_con_pkg::*;

  task wait_for_reset();
    @(negedge rst);
  endtask : wait_for_reset
  
  task wait_for_clock();
    @(negedge clk);
  endtask : wait_for_clock

  task drive(dsp_con_seq_item req);
    @(posedge clk);
      go_0 <= req.go[0];
      go_1 <= req.go[1];
      go_2 <= req.go[2];
      go_3 <= req.go[3];
    // Take the go signals low after 1 clock
    @(posedge CONTROL.clk);
      go_0 <= 0;
      go_1 <= 0;
      go_2 <= 0;
      go_3 <= 0;
  endtask : drive

endinterface: dsp_con_driver_bfm
