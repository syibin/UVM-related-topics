//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the monitor component. Still under construction.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_monitor extends uvm_monitor;
//------------------------------------------------------------------------------
//Registering the class
//------------------------------------------------------------------------------
  `uvm_component_utils(i2c_monitor);

//------------------------------------------------------------------------------
//instantiating the analysis port
//------------------------------------------------------------------------------
  uvm_analysis_port #(i2c_transaction) aport;

//------------------------------------------------------------------------------
//Instantiating the virtual interface
//------------------------------------------------------------------------------
  virtual i2c_if i2c_vi;

//------------------------------------------------------------------------------
//constructor
//------------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    aport = new("aport", this);
  endfunction

//------------------------------------------------------------------------------
//build method. Here we retrieve the interface from the configuration database.
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
        `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});

    end 
  endfunction

//------------------------------------------------------------------------------
//Main run method which monitors the pin wiggles and creates transactions.
//State machines that detect data on the SDA lines will have to be implemented.
//Here the monitor behaves as a I2C slave. TODO
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
      forever
      begin
        i2c_transaction i2c_tx;
        i2c_tx = i2c_transaction::type_id::create("i2c_tx");
        @(posedge i2c_vi.clk);
        //i2c_tx.sda = i2c_vi.sda;
        //i2c_tx.addr = i2c_vi.addr;
        //i2c_tx.data = i2c_vi.data;
      end
      //aport.write(i2c_tx);
    endtask
endclass

//-------------------------------

