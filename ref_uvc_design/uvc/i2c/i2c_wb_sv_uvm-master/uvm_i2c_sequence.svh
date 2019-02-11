//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description:  This file contains the sequence component of type transaction. 
//Generates sequence of transactions.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_sequence extends uvm_sequence #(i2c_transaction);
//------------------------------------------------------------------------------
//Registering the class with factory
//------------------------------------------------------------------------------
  `uvm_object_utils(i2c_sequence)

//------------------------------------------------------------------------------
//Constructor
//------------------------------------------------------------------------------
    function new (string name = "");
      super.new(name);
    endfunction

//------------------------------------------------------------------------------
//Body method which instantiates the transaction and creates the sequence
//randomises the data in the transaction
//------------------------------------------------------------------------------
    task body();
      forever
      begin
        i2c_transaction i2c_tx;
        i2c_tx = i2c_transaction::type_id::create("i2c_tx");
        start_item(i2c_tx);
        assert(i2c_tx.randomize());
        finish_item(i2c_tx);
      end
    endtask
endclass

