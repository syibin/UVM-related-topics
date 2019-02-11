//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the interface between the DUT and the testbench. 
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

interface i2c_if(input clk, input clk_sda);

//logic clk;					    // System_clk						
//logic rst;					    // Reset
logic reset;

logic scl_oe;					  // SCL Output Enable
//logic scl_o;				    // SCL output
logic sda_oe;				    // SDA output enable
//logic sda_o;				    // SDL output

wire scl;					      // SCL input
wire sda;					      // SDA input

logic [7:0] addr_in;	  // Address Input 
logic [7:0] data_in;	  // Data Input 
logic  [7:0] data_out;	// Data Output 
logic wb_stb_i;				  // Strobe 
logic wb_cyc_i;				  // Cycle valid
logic we;					      // Write Enable
logic trans_comp;			  // Transacation Complete
logic ack_o;				    // Ack
logic irq;					    // Interrupt

endinterface  : i2c_if

