`define UART_BASE_ADDRESS      32'h0 //Added             
`define UART_INTF_REGISTER     32'h0 //Same to UART_BASE_ADDRESS?? 
`define UART_INTC_REGISTER     32'h4 
`define UART_MODE_REGISTER     32'h8 
`define UART_STATUS_REGISTER   32'hC //Not found in the spec 
`define UART_RXBUF_REGISTER    32'h10                  
`define UART_TXBUF_REGISTER    32'h14

`include "interface.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "environment.sv"
//`include "testcase_one.sv"
//`include "testcase_two.sv"
//`include "testcase_three.sv"
//`include "testcase_combined.sv"