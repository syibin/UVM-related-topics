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
// Connect up interfaces to the signal ports on the
// PSS DUT
//
module pss_wrapper(interface ahb,
                   interface spi,
                   interface gpi,
                   interface gpo,
                   interface gpoe,
                   interface icpit,
                   interface uart_rx,
                   interface uart_tx,
                   interface modem);

wire baud;

pss DUT(// AHB Host interface
        .HCLK(ahb.HCLK),
        .HRESETn(ahb.HRESETn),
        .HADDR(ahb.HADDR),
        .HTRANS(ahb.HTRANS),
        .HWRITE(ahb.HWRITE),
        .HSIZE(ahb.HSIZE),
        .HBURST(ahb.HBURST),
        .HPROT(ahb.HPROT),
        .HWDATA(ahb.HWDATA),
        .HSEL(ahb.HSEL),
        .HRDATA(ahb.HRDATA),
        .HREADY(ahb.HREADY),
        .HRESP(ahb.HRESP),
        // SPI interface
        .spi_cs(spi.cs),
        .spi_clk(spi.clk),
        .spi_mosi(spi.mosi),
        .spi_miso(spi.miso),
        // GPIO Interface
        .gpi(gpi.gpio),
        .gpo(gpo.gpio),
        .gpoe(gpoe.gpio),
        // UART Interface
        .rxd(uart_rx.sdata),
        .txd(uart_tx.sdata),
        // modem signals
        .rts(modem.rts_pad_o),
        .cts(modem.cts_pad_i),
        .dtr(modem.dtr_pad_o),
        .dsr(modem.dsr_pad_i),
        .ri(modem.ri_pad_i),
        .dcd(modem.dcd_pad_i),
        .baud(baud),
        // Interrupts
        .IREQ(icpit.IREQ[4:0]),
        .IRQ(icpit.IRQ));

endmodule: pss_wrapper
