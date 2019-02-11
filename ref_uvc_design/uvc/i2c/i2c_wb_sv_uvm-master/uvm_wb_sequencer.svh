//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains sequencer component which "plays" the sequence of transactions
//on the driver
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class wb_sequencer extends uvm_sequencer #(wb_transaction);
  `uvm_component_utils(wb_sequencer)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

endclass

