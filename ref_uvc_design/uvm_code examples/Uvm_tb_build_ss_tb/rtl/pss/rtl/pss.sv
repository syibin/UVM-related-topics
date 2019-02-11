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

`include "timescale.v"
`include "gpio_defines.v"

//
// The Peripheral sub-system (PSS) comprises the following IP
//
// AHB2APB Bridge - Configured for 3 slaves
// SPI Master
// GPIO
// ICPIT
//

module pss(// AHB Host interface
           input HCLK,
           input HRESETn,
           input[31:0] HADDR,
           input[1:0] HTRANS,
           input HWRITE,
           input[2:0] HSIZE,
           input[2:0] HBURST,
           input[3:0] HPROT,
           input[31:0] HWDATA,
           input HSEL,
           output [31:0] HRDATA,
           output HREADY,
           output [1:0] HRESP,
           // SPI interface
           output[7:0] spi_cs,
           output spi_clk,
           output spi_mosi,
           input spi_miso,
           // GPIO Interface
           input[31:0] gpi,
           output[31:0] gpo,
           output[31:0] gpoe,
           // UART Interface
           input rxd,
           output txd,
           // modem signals
           output rts,
           input cts,
           output dtr,
           input dsr,
           input ri,
           input dcd,
           output baud,
           // External Interrupts
           input[4:0] IREQ,
           output IRQ);

wire[31:0] PADDR;
wire[31:0] PWDATA;
wire PENABLE;
wire PWRITE;
wire[3:0] PSEL;
wire[31:0] SPI_PRDATA;
wire SPI_PREADY;
wire[31:0] GPIO_PRDATA;
wire GPIO_PREADY;
wire[31:0] ICPIT_PRDATA;
wire ICPIT_PREADY;
wire[31:0] UART_PRDATA;
wire UART_PREADY;
wire UART_IREQ;
wire SPI_IREQ;
wire GPIO_IREQ;
wire PIT_OUT;
wire WATCHDOG;

typedef logic[31:0] read_port_t[3];


// AHB2APB Bridge
ahb_apb_bridge
  #(.NO_OF_SLAVES(4),
    .SLAVE_START_ADDR_0(0),
    .SLAVE_END_ADDR_0(32'hFF),
    .SLAVE_START_ADDR_1(32'h100),
    .SLAVE_END_ADDR_1(32'h1FF),
    .SLAVE_START_ADDR_2(32'h200),
    .SLAVE_END_ADDR_2(32'h2FF),
    .SLAVE_START_ADDR_3(32'h300),
    .SLAVE_END_ADDR_3(32'h3FF)
    )
    U_BRIDGE
    (
     // AHB Host side signals:
     .HCLK(HCLK),
     .HRESETn(HRESETn),
     .HADDR(HADDR),
     .HTRANS(HTRANS),
     .HWRITE(HWRITE),
     .HSIZE(HSIZE),
     .HBURST(HBURST),
     .HPROT(HPROT),
     .HWDATA(HWDATA),
     .HSEL(HSEL),
     .HRDATA(HRDATA),
     .HREADY(HREADY),
     .HRESP(HRESP),
     // APB Slave side signals:
     .PADDR(PADDR),
     .PWDATA(PWDATA),
     .PENABLE(PENABLE),
     .PWRITE(PWRITE),
     .PSEL(PSEL),
     .PRDATA('{UART_PRDATA, ICPIT_PRDATA, GPIO_PRDATA, SPI_PRDATA}),
     .PREADY({UART_PREADY, ICPIT_PREADY, GPIO_PREADY, SPI_PREADY}),
     .PSLVERR(4'b0));

spi_top U_SPI(
    // APB Interface:
    .PCLK(HCLK),
    .PRESETN(HRESETn),
    .PSEL(PSEL[0]),
    .PADDR(PADDR[4:0]),
    .PWDATA(PWDATA),
    .PRDATA(SPI_PRDATA),
    .PENABLE(PENABLE),
    .PREADY(SPI_PREADY),
    .PSLVERR(),
    .PWRITE(PWRITE),
    // Interrupt output
    .IRQ(SPI_IREQ),
    // SPI signals
    .ss_pad_o(spi_cs),
    .sclk_pad_o(spi_clk),
    .mosi_pad_o(spi_mosi),
    .miso_pad_i(spi_miso)
);

gpio_top U_GPIO(
  // APB Interface:
  .PCLK(HCLK),
  .PRESETN(HRESETn),
  .PSEL(PSEL[1]),
  .PADDR(PADDR[7:0]),
  .PWDATA(PWDATA),
  .PRDATA(GPIO_PRDATA),
  .PENABLE(PENABLE),
  .PREADY(GPIO_PREADY),
  .PSLVERR(),
  .PWRITE(PWRITE),
  // Interrupt output
  .IRQ(GPIO_IREQ),
`ifdef GPIO_AUX_IMPLEMENT
  // Auxiliary inputs interface
  .aux_i({PIT_OUT, WATCHDOG, 30'h0}),
`endif //  GPIO_AUX_IMPLEMENT
  // External GPIO Interface
  .ext_pad_i(gpi),
  .ext_pad_o(gpo),
  .ext_padoe_o(gpoe)
`ifdef GPIO_CLKPAD
  , .clk_pad_i(1'b0) // Disabled
`endif
);

icpit U_ICPIT(// APB Interface signals:
              .PCLK(HCLK),
              .PRESETN(HRESETn),
              .PADDR(PADDR[4:2]),
              .PSEL(PSEL[2]),
              .PENABLE(PENABLE),
              .PWRITE(PWRITE),
              .PWDATA(PWDATA),
              .PRDATA(ICPIT_PRDATA),
              .PREADY(ICPIT_PREADY),
              // Interrupt signals:
              .IRQ(IRQ),
              .IREQ({IREQ[4:0], UART_IREQ, GPIO_IREQ, SPI_IREQ}),
              // PIT Terminal Count
              .PIT_OUT(PIT_OUT),
              // Watchdog Terminal Count
              .WATCHDOG(WATCHDOG));

uart_top U_UART(
                // APB Signals
                .PCLK(HCLK),

                // Wishbone signals
                .PRESETn(HRESETn),
                .PADDR(PADDR),
                .PWDATA(PWDATA),
                .PRDATA(UART_PRDATA),
                .PWRITE(PWRITE),
                .PENABLE(PENABLE),
                .PSEL(PSEL[3]),
                .PREADY(UART_PREADY),
                .int_o(UART_IREQ), // interrupt request

                // UART signals
                // serial input/output
                .stx_pad_o(txd),
                .srx_pad_i(rxd),

                // modem signals
                .rts_pad_o(rts),
                .cts_pad_i(cts),
                .dtr_pad_o(dtr),
                .dsr_pad_i(dsr),
                .ri_pad_i(ri),
                .dcd_pad_i(dcd),
                .baud_o(baud)
                );

endmodule: pss
