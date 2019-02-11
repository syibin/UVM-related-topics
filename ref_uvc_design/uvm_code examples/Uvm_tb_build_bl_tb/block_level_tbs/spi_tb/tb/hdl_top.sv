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

module hdl_top;
  // pragma attribute hdl_top partition_module_xrtl

`include "timescale.v"

// PCLK and PRESETn
//
logic PCLK;
logic PRESETn;

//
// Instantiate the pin interfaces:
//
apb_if APB(PCLK, PRESETn);   // APB interface
spi_if SPI();  // SPI Interface
intr_if INTR();   // Interrupt

//
// Instantiate the BFM interfaces:
//
apb_monitor_bfm APB_mon_bfm(
   .PCLK    (APB.PCLK),
   .PRESETn (APB.PRESETn),
   .PADDR   (APB.PADDR),
   .PRDATA  (APB.PRDATA),
   .PWDATA  (APB.PWDATA),
   .PSEL    (APB.PSEL),
   .PENABLE (APB.PENABLE),
   .PWRITE  (APB.PWRITE),
   .PREADY  (APB.PREADY)
);
apb_driver_bfm APB_drv_bfm(
   .PCLK    (APB.PCLK),
   .PRESETn (APB.PRESETn),
   .PADDR   (APB.PADDR),
   .PRDATA  (APB.PRDATA),
   .PWDATA  (APB.PWDATA),
   .PSEL    (APB.PSEL),
   .PENABLE (APB.PENABLE),
   .PWRITE  (APB.PWRITE),
   .PREADY  (APB.PREADY)
);
spi_monitor_bfm SPI_mon_bfm(
   .clk  (SPI.clk),
   .cs   (SPI.cs),
   .miso (SPI.miso),
   .mosi (SPI.mosi)
);
spi_driver_bfm SPI_drv_bfm(
   .clk  (SPI.clk),
   .cs   (SPI.cs),
   .miso (SPI.miso),
   .mosi (SPI.mosi)
);
intr_bfm INTR_bfm(
   .IRQ  (INTR.IRQ),
   .IREQ (INTR.IREQ)
);

  
// DUT
spi_top DUT(
    // APB Interface:
    .PCLK(PCLK),
    .PRESETN(PRESETn),
    .PSEL(APB.PSEL[0]),
    .PADDR(APB.PADDR[4:0]),
    .PWDATA(APB.PWDATA),
    .PRDATA(APB.PRDATA),
    .PENABLE(APB.PENABLE),
    .PREADY(APB.PREADY),
    .PSLVERR(),
    .PWRITE(APB.PWRITE),
    // Interrupt output
    .IRQ(INTR.IRQ),
    // SPI signals
    .ss_pad_o(SPI.cs),
    .sclk_pad_o(SPI.clk),
    .mosi_pad_o(SPI.mosi),
    .miso_pad_i(SPI.miso)
);


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual apb_monitor_bfm)::set(null, "uvm_test_top", "APB_mon_bfm", APB_mon_bfm);
  uvm_config_db #(virtual apb_driver_bfm) ::set(null, "uvm_test_top", "APB_drv_bfm", APB_drv_bfm);
  uvm_config_db #(virtual spi_monitor_bfm)::set(null, "uvm_test_top", "SPI_mon_bfm", SPI_mon_bfm);
  uvm_config_db #(virtual spi_driver_bfm) ::set(null, "uvm_test_top", "SPI_drv_bfm", SPI_drv_bfm);
  uvm_config_db #(virtual intr_bfm)       ::set(null, "uvm_test_top", "INTR_bfm", INTR_bfm);
end

//
// Clock and reset initial block:
//
initial begin
  PCLK = 0;
  forever #10ns PCLK = ~PCLK;
end
initial begin 
  PRESETn = 0;
  repeat(4) @(posedge PCLK);
  PRESETn = 1;
end

endmodule: hdl_top
