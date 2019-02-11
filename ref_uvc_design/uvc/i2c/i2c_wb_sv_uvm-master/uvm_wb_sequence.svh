//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description:  This file contains the sequence component of type transaction. 
//Generates sequence of transactions.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class wb_sequence extends uvm_sequence #(wb_transaction);
//------------------------------------------------------------------------------
//Registering the class with factory
//------------------------------------------------------------------------------
  `uvm_object_utils(wb_sequence)

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
        wb_transaction wb_tx;
        wb_tx = wb_transaction::type_id::create("wb_tx");
        start_item(wb_tx);
        assert(wb_tx.randomize());
        finish_item(wb_tx);
      end
    endtask
endclass

