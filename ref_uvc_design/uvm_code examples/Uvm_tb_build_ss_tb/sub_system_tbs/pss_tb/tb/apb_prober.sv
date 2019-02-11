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

module apb_prober(input PCLK,
              input PRESETn,
              input logic[31:0] PADDR,
              input logic[31:0] SPI_PRDATA,
              input logic[31:0] GPIO_PRDATA,
              input logic[31:0] ICPIT_PRDATA,
              input logic[31:0] UART_PRDATA,
              input SPI_PREADY,
              input GPIO_PREADY,
              input ICPIT_PREADY,
              input UART_PREADY,
              input logic[31:0] PWDATA,
              input logic[3:0] PSEL,
              input PENABLE,
              input PWRITE);

assign APB.PCLK = PCLK;
assign APB.PRESETn = PRESETn;
assign APB.PADDR = PADDR;
// Mux according to which PSEL line is active
assign APB.PRDATA = ({32{PSEL[0]}} & SPI_PRDATA) |
                    ({32{PSEL[1]}} & GPIO_PRDATA) |
                    ({32{PSEL[2]}} & ICPIT_PRDATA) |
                    ({32{PSEL[3]}} & UART_PRDATA);
assign APB.PWDATA = PWDATA;
assign APB.PSEL = {28'h0, PSEL};
assign APB.PENABLE = PENABLE;
assign APB.PWRITE = PWRITE;
// Mux according to which PSEL line is active
assign APB.PREADY = (PSEL[0] & SPI_PREADY) |
                    (PSEL[1] & GPIO_PREADY) |
                    (PSEL[2] & ICPIT_PREADY) |
                    (PSEL[3] & UART_PREADY);

endmodule: apb_prober

