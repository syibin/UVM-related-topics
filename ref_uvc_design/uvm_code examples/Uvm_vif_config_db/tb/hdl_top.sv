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

sfr_if SFR(.clk(clk), .reset(reset));

sfr_dut dut (.clk(clk),
             .reset(reset),
             .address(SFR.address),
             .write_data(SFR.write_data),
             .we(SFR.we),
             .re(SFR.re),
             .read_data(SFR.read_data));

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
  uvm_config_db #(virtual sfr_if)::set(null, "uvm_test_top", "SFR", SFR);
end

endmodule
