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

interface control_if;

  logic clk;
  logic rst;
  logic go_0;
  logic go_1;
  logic go_2;
  logic go_3;

endinterface: control_if

module hdl_top;

interrupt_if IRQ[4]();
control_if CONTROL();

dsp_con_driver_bfm dsp_con_drv_bfm(
  .clk  (CONTROL.clk),
  .rst  (CONTROL.rst),
  .go_0 (CONTROL.go_0),
  .go_1 (CONTROL.go_1),
  .go_2 (CONTROL.go_2),
  .go_3 (CONTROL.go_3)
);

dsp_chain DUT(.intr(IRQ), .control(CONTROL));


// Clock-Reset
initial begin
  CONTROL.clk = 0;
  CONTROL.rst = 1;
  repeat(6) begin
    #10ns CONTROL.clk = ~CONTROL.clk;
  end
  CONTROL.rst = 0;
  forever begin
    #10ns CONTROL.clk = ~CONTROL.clk;
  end
end

initial begin
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual dsp_con_driver_bfm)::set(null, "uvm_test_top", "dsp_con_drv_bfm", dsp_con_drv_bfm);
end

for (genvar ii = 0; ii < 4; ii++)
  initial begin : int_gen_block
    import uvm_pkg::uvm_config_db;
    uvm_config_db #(virtual interrupt_if)::set(null, "uvm_test_top", $sformatf("IRQ%0d_vif", ii) , IRQ[ii]);
  end
endmodule: hdl_top

module hvl_top();

import uvm_pkg::*;
import dsp_con_pkg::*;

initial begin
  run_test("dsp_con_test");
end


endmodule : hvl_top
