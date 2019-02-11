// ----------------------------------------------------------
// Copyright 2018 Mentor Graphics Corporation
// All Rights Reserved Worldwide
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ----------------------------------------------------------
module hdl_top;

import uvm_pkg::*;

logic PCLK;
logic PRESETn;

wire[31:0] PADDR;
wire[15:0] PSEL;
wire[31:0] PWDATA;
wire[31:0] PRDATA;
wire PENABLE;
wire PREADY;
wire PSLVERR;

reg_dut DUT(.PCLK(PCLK),
            .PRESETn(PRESETn),
            .PADDR(PADDR),
            .PWDATA(PWDATA),
            .PWRITE(PWRITE),
            .PSEL(PSEL[0]),
            .PENABLE(PENABLE),
            .PRDATA(PRDATA),
            .PREADY(PREADY));

apb_driver_bfm APB_MASTER(.PCLK(PCLK),
                          .PRESETn(PRESETn),
                          .PADDR(PADDR),
                          .PWDATA(PWDATA),
                          .PWRITE(PWRITE),
                          .PSEL(PSEL),
                          .PENABLE(PENABLE),
                          .PRDATA(PRDATA),
                          .PREADY(PREADY));

apb_monitor_bfm APB_MONITOR(.PCLK(PCLK),
                            .PRESETn(PRESETn),
                            .PADDR(PADDR),
                            .PWDATA(PWDATA),
                            .PWRITE(PWRITE),
                            .PSEL(PSEL),
                            .PENABLE(PENABLE),
                            .PRDATA(PRDATA),
                            .PREADY(PREADY));

initial begin
  PRESETn = 0;
  PCLK = 0;
  repeat(10) begin
    #10ns PCLK = ~PCLK;
  end
  PRESETn = 1;
  forever begin
    #10ns PCLK = ~PCLK;
  end
end

initial begin
  uvm_config_db #(virtual apb_driver_bfm)::set(null, "uvm_test_top", "APB_MASTER", APB_MASTER);
  uvm_config_db #(virtual apb_monitor_bfm)::set(null, "uvm_test_top", "APB_MONITOR", APB_MONITOR);
end

endmodule
