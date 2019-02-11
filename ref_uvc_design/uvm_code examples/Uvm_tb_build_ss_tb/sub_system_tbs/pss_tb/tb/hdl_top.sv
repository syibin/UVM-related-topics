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

// PCLK and PRESETn
//
logic HCLK;
logic HRESETn;

//
// Instantiate the pin interfaces:
//
apb_if APB(HCLK, HRESETn); // APB interface - shared between passive agents
apb_if APB_dummy(1'b0, 1'b0); // APB interface - shared between passive agents
ahb_if AHB(HCLK, HRESETn);   // AHB interface
spi_if SPI();  // SPI Interface
gpio_if GPO();
gpio_if GPI();
gpio_if GPOE();
serial_if UART_RX();
serial_if UART_TX();
modem_if MODEM();
intr_if ICPIT(); // Interrupt

//
// Instantiate the BFM interfaces:
//
apb_monitor_bfm APB_SPI_mon_bfm(
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
//apb_driver_bfm APB_SPI_drv_bfm(
//   .PCLK    (APB.PCLK),
//   .PRESETn (APB.PRESETn),
//   .PADDR   (APB.PADDR),
//   .PRDATA  (APB.PRDATA),
//   .PWDATA  (APB.PWDATA),
//   .PSEL    (APB.PSEL),
//   .PENABLE (APB.PENABLE),
//   .PWRITE  (APB.PWRITE),
//   .PREADY  (APB.PREADY)
//);
apb_monitor_bfm APB_GPIO_mon_bfm(
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
apb_driver_bfm APB_GPIO_drv_bfm(
   .PCLK    (APB_dummy.PCLK),
   .PRESETn (APB_dummy.PRESETn),
   .PADDR   (APB_dummy.PADDR),
   .PRDATA  (APB_dummy.PRDATA),
   .PWDATA  (APB_dummy.PWDATA),
   .PSEL    (APB_dummy.PSEL),
   .PENABLE (APB_dummy.PENABLE),
   .PWRITE  (APB_dummy.PWRITE),
   .PREADY  (APB_dummy.PREADY)
);
//apb_driver_bfm APB_GPIO_drv_bfm(
//   .PCLK    (APB.PCLK),
//   .PRESETn (APB.PRESETn),
//   .PADDR   (APB.PADDR),
//   .PRDATA  (APB.PRDATA),
//   .PWDATA  (APB.PWDATA),
//   .PSEL    (APB.PSEL),
//   .PENABLE (APB.PENABLE),
//   .PWRITE  (APB.PWRITE),
//   .PREADY  (APB.PREADY)
//);
ahb_monitor_bfm AHB_mon_bfm(
   .HCLK    (AHB.HCLK),
   .HRESETn (AHB.HRESETn),
   .HADDR   (AHB.HADDR),
   .HTRANS  (AHB.HTRANS),
   .HWRITE  (AHB.HWRITE),
   .HSIZE   (AHB.HSIZE),
   .HBURST  (AHB.HBURST),
   .HPROT   (AHB.HPROT),
   .HWDATA  (AHB.HWDATA),
   .HRDATA  (AHB.HRDATA),
   .HRESP   (AHB.HRESP),
   .HREADY  (AHB.HREADY),
   .HSEL    (AHB.HSEL)
);
ahb_driver_bfm AHB_drv_bfm(
   .HCLK    (AHB.HCLK),
   .HRESETn (AHB.HRESETn),
   .HADDR   (AHB.HADDR),
   .HTRANS  (AHB.HTRANS),
   .HWRITE  (AHB.HWRITE),
   .HSIZE   (AHB.HSIZE),
   .HBURST  (AHB.HBURST),
   .HPROT   (AHB.HPROT),
   .HWDATA  (AHB.HWDATA),
   .HRDATA  (AHB.HRDATA),
   .HRESP   (AHB.HRESP),
   .HREADY  (AHB.HREADY),
   .HSEL    (AHB.HSEL)
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
gpio_monitor_bfm GPO_mon_bfm(
   .clk     (GPO.clk),
   .gpio    (GPO.gpio),
   .ext_clk (GPO.ext_clk)
);
//gpio_driver_bfm GPO_drv_bfm(
//   .clk     (GPO.clk),
//   .gpio    (GPO.gpio),
//   .ext_clk (GPO.ext_clk)
//);
gpio_monitor_bfm GPI_mon_bfm(
   .clk     (GPI.clk),
   .gpio    (GPI.gpio),
   .ext_clk (GPI.ext_clk)
);
gpio_driver_bfm GPI_drv_bfm(
   .clk     (GPI.clk),
   .gpio    (GPI.gpio),
   .ext_clk (GPI.ext_clk)
);
gpio_monitor_bfm GPOE_mon_bfm(
   .clk     (GPOE.clk),
   .gpio    (GPOE.gpio),
   .ext_clk (GPOE.ext_clk)
);
//gpio_driver_bfm GPOE_drv_bfm(
//   .clk     (GPOE.clk),
//   .gpio    (GPOE.gpio),
//   .ext_clk (GPOE.ext_clk)
//);
uart_monitor_bfm UART_RX_mon_bfm(
   .sclk  (UART_RX.clk),
   .sdata (UART_RX.sdata)
);
uart_driver_bfm UART_RX_drv_bfm(
   .sclk  (UART_RX.clk),
   .sdata (UART_RX.sdata)
);
uart_monitor_bfm UART_TX_mon_bfm(
   .sclk  (UART_TX.clk),
   .sdata (UART_TX.sdata)
);
//uart_driver_bfm UART_TX_drv_bfm(
//   .sclk  (UART_TX.clk),
//   .sdata (UART_TX.sdata)
//);
modem_monitor_bfm MODEM_mon_bfm(
   .rts_pad_o (MODEM.rts_pad_o),
   .cts_pad_i (MODEM.cts_pad_i),
   .dtr_pad_o (MODEM.dtr_pad_o),
   .dsr_pad_i (MODEM.dsr_pad_i),
   .ri_pad_i  (MODEM.ri_pad_i),
   .dcd_pad_i (MODEM.dcd_pad_i)
);
modem_driver_bfm MODEM_drv_bfm(
   .rts_pad_o (MODEM.rts_pad_o),
   .cts_pad_i (MODEM.cts_pad_i),
   .dtr_pad_o (MODEM.dtr_pad_o),
   .dsr_pad_i (MODEM.dsr_pad_i),
   .ri_pad_i  (MODEM.ri_pad_i),
   .dcd_pad_i (MODEM.dcd_pad_i)
);
intr_bfm ICPIT_bfm(
   .IRQ  (ICPIT.IRQ),
   .IREQ (ICPIT.IREQ)
);

// Binder
binder probe();

// DUT Wrapper:
pss_wrapper wrapper(.ahb(AHB),
                   .spi(SPI),
                   .gpi(GPI),
                   .gpo(GPO),
                   .gpoe(GPOE),
                   .icpit(ICPIT),
                   .uart_rx(UART_RX),
                   .uart_tx(UART_TX),
                   .modem(MODEM));


// UVM initial block:
// Virtual interface wrapping & run_test()
initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
  uvm_config_db #(virtual apb_monitor_bfm)  ::set(null, "uvm_test_top", "APB_SPI_mon_bfm", APB_SPI_mon_bfm);
  //uvm_config_db #(virtual apb_driver_bfm) ::set(null, "uvm_test_top", "APB_SPI_drv_bfm", APB_SPI_drv_bfm);
  uvm_config_db #(virtual apb_monitor_bfm)  ::set(null, "uvm_test_top", "APB_GPIO_mon_bfm", APB_GPIO_mon_bfm);
  //uvm_config_db #(virtual apb_driver_bfm) ::set(null, "uvm_test_top", "APB_GPIO_drv_bfm", APB_GPIO_drv_bfm);
  uvm_config_db #(virtual ahb_monitor_bfm)  ::set(null, "uvm_test_top", "AHB_mon_bfm", AHB_mon_bfm);
  uvm_config_db #(virtual ahb_driver_bfm)   ::set(null, "uvm_test_top", "AHB_drv_bfm", AHB_drv_bfm);
  uvm_config_db #(virtual spi_monitor_bfm)  ::set(null, "uvm_test_top", "SPI_mon_bfm", SPI_mon_bfm);
  uvm_config_db #(virtual spi_driver_bfm)   ::set(null, "uvm_test_top", "SPI_drv_bfm", SPI_drv_bfm);
  uvm_config_db #(virtual gpio_monitor_bfm) ::set(null, "uvm_test_top", "GPO_mon_bfm", GPO_mon_bfm);
  //uvm_config_db #(virtual gpio_driver_bfm) ::set(null, "uvm_test_top", "GPO_drv_bfm", GPO_drv_bfm);
  uvm_config_db #(virtual gpio_monitor_bfm) ::set(null, "uvm_test_top", "GPOE_mon_bfm", GPOE_mon_bfm);
  //uvm_config_db #(virtual gpio_driver_bfm) ::set(null, "uvm_test_top", "GPOE_drv_bfm", GPOE_drv_bfm);
  uvm_config_db #(virtual gpio_monitor_bfm) ::set(null, "uvm_test_top", "GPI_mon_bfm", GPI_mon_bfm);
  uvm_config_db #(virtual gpio_driver_bfm)  ::set(null, "uvm_test_top", "GPI_drv_bfm", GPI_drv_bfm);
  uvm_config_db #(virtual uart_monitor_bfm) ::set(null, "uvm_test_top", "UART_RX_mon_bfm", UART_RX_mon_bfm);
  uvm_config_db #(virtual uart_driver_bfm)  ::set(null, "uvm_test_top", "UART_RX_drv_bfm", UART_RX_drv_bfm);
  uvm_config_db #(virtual uart_monitor_bfm) ::set(null, "uvm_test_top", "UART_TX_mon_bfm", UART_TX_mon_bfm);
//  uvm_config_db #(virtual uart_driver_bfm)  ::set(null, "uvm_test_top", "UART_TX_drv_bfm", UART_TX_drv_bfm);
  uvm_config_db #(virtual modem_monitor_bfm)::set(null, "uvm_test_top", "MODEM_mon_bfm", MODEM_mon_bfm);
  uvm_config_db #(virtual modem_driver_bfm) ::set(null, "uvm_test_top", "MODEM_drv_bfm", MODEM_drv_bfm);
  uvm_config_db #(virtual intr_bfm)         ::set(null,"uvm_test_top","ICPIT_bfm" , ICPIT_bfm);
end

//
// Clock and reset initial block:
//
initial begin
  HCLK = 1;
  forever #10ns HCLK = ~HCLK;
end
initial begin 
  HRESETn = 0;
  repeat(4) @(posedge HCLK);
  HRESETn = 1;
end

// Clock assignments:
assign GPO.clk = HCLK;
assign GPOE.clk = HCLK;
assign GPI.clk = HCLK;

endmodule: hdl_top
