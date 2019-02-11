//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
module hdl_top;

import uvm_pkg::*;

logic clk;
logic reset;
wire[7:0] address;
wire[7:0] write_data;
wire[7:0] read_data;
wire we;
wire re;

sfr_master_bfm SFR_MASTER(.clk(clk),
                          .reset(reset),
                          .address(address),
                          .write_data(write_data),
                          .read_data(read_data),
                          .we(we),
                          .re(re));
                          
sfr_monitor_bfm SFR_MONITOR(.clk(clk),
                            .reset(reset),
                            .address(address),
                            .write_data(write_data),
                            .read_data(read_data),
                            .we(we),
                            .re(re));

sfr_dut dut (.clk(clk),
             .reset(reset),
             .address(address),
             .write_data(write_data),
             .we(we),
             .re(re),
             .read_data(read_data));

initial begin
  reset <= 1;
  clk <= 0;
  repeat(10) begin
    #10ns clk <= ~clk;
  end
  reset <= 0;
  forever begin
    #10ns clk <= ~clk;
  end
end

initial begin
  uvm_config_db #(virtual sfr_master_bfm)::set(null, "uvm_test_top", "SFR_MASTER", SFR_MASTER);
  uvm_config_db #(virtual sfr_monitor_bfm)::set(null, "uvm_test_top", "SFR_MONITOR", SFR_MONITOR);
end

endmodule
