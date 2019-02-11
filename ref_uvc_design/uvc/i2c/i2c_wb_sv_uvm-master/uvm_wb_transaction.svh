//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the definition of the i2c transcation
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class wb_transaction extends uvm_sequence_item;

//------------------------------------------------------------------------------
//Registering this class with the uvm factory
//------------------------------------------------------------------------------
  `uvm_object_utils(wb_transaction)

//------------------------------------------------------------------------------
//Data and address fields of I2C transaction
//------------------------------------------------------------------------------
  rand logic [7:0] addr;
  rand logic [7:0] data;
  rand bit rw_cmd_bit;

//------------------------------------------------------------------------------
//Constraints for the address
//------------------------------------------------------------------------------
  constraint c_addr {
    addr >=10;
    addr <= 20;
  }

//------------------------------------------------------------------------------
//Constraints for the data
//------------------------------------------------------------------------------
  constraint c_data {
    data >=30;
    data < 40;
  }
//------------------------------------------------------------------------------
//Constraint to control the transaction to be either I2C write or read
//------------------------------------------------------------------------------
  constraint c_rw {
    rw_cmd_bit == 0; //Master write to slave
    //rw_cmd_bit = 1; //Master read from slave
  }

//------------------------------------------------------------------------------
//Default constructor of the class
//------------------------------------------------------------------------------
  function new (string name = "");
    super.new(name);
  endfunction

endclass

