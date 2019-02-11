//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the scoreboard component which compares and checks the transactions that
//are input to DUT and output from WB and vice versa
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_wb_scoreboard extends uvm_component;
  `uvm_component_utils(i2c_wb_scoreboard)


//------------------------------------------------------------------------------
//Constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction

//------------------------------------------------------------------------------
//Class build method. 
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction

endclass


