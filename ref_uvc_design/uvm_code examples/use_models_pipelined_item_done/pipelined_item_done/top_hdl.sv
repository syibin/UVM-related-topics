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

module top_hdl;

mbus_if MBUS();
gpio_if GPIO();

mbus_pipelined_driver_bfm mbus_pipelined_drv(
  .MCLK    (MBUS.MCLK),
  .MRESETN (MBUS.MRESETN),
  .MADDR   (MBUS.MADDR),
  .MWDATA  (MBUS.MWDATA),
  .MREAD   (MBUS.MREAD),
  .MOPCODE (MBUS.MOPCODE),
  .MRDY    (MBUS.MRDY),
  .MRDATA  (MBUS.MRDATA),
  .MRESP   (MBUS.MRESP)
);

mbus_slave dut(.bus(MBUS), .gpio(GPIO));

// Clock and reset process
initial begin
  MBUS.MRESETN = 0;
  MBUS.MCLK = 0;
  repeat (6) begin
    #10 MBUS.MCLK = ~MBUS.MCLK;
  end
  MBUS.MRESETN = 1;
  forever begin
    #10 MBUS.MCLK = ~MBUS.MCLK;
  end
end

// GPIO Clock
assign GPIO.clk = MBUS.MCLK;

initial begin
  uvm_pkg::uvm_config_db #(virtual mbus_pipelined_driver_bfm)::
    set(null, "uvm_test_top", "mbus_pipelined_drv", mbus_pipelined_drv);
end

endmodule: top_hdl
