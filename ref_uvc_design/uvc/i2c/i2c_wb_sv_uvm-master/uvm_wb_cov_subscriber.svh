//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the coverage subscriber component. Coverage groups and bins are
//defined here for the purpose of functional coverage. Under construction
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class wb_cov_subscriber extends uvm_subscriber #(wb_transaction);
  `uvm_component_utils(wb_cov_subscriber)

    bit cmd;
    logic [7:0] addr;
    logic [7:0] data;

//------------------------------------------------------------------------------
//cover group
//------------------------------------------------------------------------------
    covergroup cover_bus;
      //coverpoint cmd;
//------------------------------------------------------------------------------
//cover bins containing address
//------------------------------------------------------------------------------
      coverpoint addr { 
        bins a[8] = {[0:127]}; 
      }
//------------------------------------------------------------------------------
//cover bins containing data
//------------------------------------------------------------------------------
      coverpoint data {
        bins d[8] = {[0:255]};
      }
    endgroup

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

//------------------------------------------------------------------------------
//Write method of the subscriber which captures transcations and samples them
//for coverage
//------------------------------------------------------------------------------

    function void write(wb_transaction t);
      data = t.data;
      addr = t.addr;
      cover_bus.sample();
      `uvm_info("MYINFO", {"Transaction Received", get_full_name(),""}, UVM_LOW);

    endfunction
    
endclass


