//------------------------------------------------------------
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
//------------------------------------------------------------
//
// BFM Interface Description:
//
//
interface gpio_driver_bfm (
  input  logic        clk,
  output logic [31:0] gpio,
  output bit          ext_clk
);

  import gpio_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

function void clear_sigs();
  ext_clk <= 0;
endfunction : clear_sigs

task drive (gpio_seq_item req);
  @(posedge clk);
  #1ns;
  foreach(req.use_ext_clk[i]) begin
    if(req.use_ext_clk[i] == 0) begin
        gpio[i] <= req.gpio[i];
    end
  end
  repeat(2)
    @(negedge clk);
  foreach(req.use_ext_clk[i]) begin
    if(req.use_ext_clk[i] == 1) begin
      if(req.ext_clk_edge[i] == 1) begin
        gpio[i] <= req.gpio[i];
      end
    end
  end
  repeat(2)
    @(negedge clk);
  ext_clk <= 1;
  repeat(5)
    @(negedge clk);
  foreach(req.use_ext_clk[i]) begin
    if(req.use_ext_clk[i] == 1) begin
      if(req.ext_clk_edge[i] == 0) begin
        gpio[i] <= req.gpio[i];
      end
    end
  end
    repeat(5)
      @(negedge clk);
  ext_clk <= 0;
  repeat(5)
    @(negedge clk);
endtask : drive

endinterface: gpio_driver_bfm
