//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the definition of the wb agent. The agent comprises of
//sequencer, Wishbone driver, I2C driver and a monitor.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class wb_agent extends uvm_agent; 
  
//------------------------------------------------------------------------------
//Registering the class with factory
//------------------------------------------------------------------------------
  `uvm_component_utils (wb_agent);
 
//------------------------------------------------------------------------------
//Declaring the analysis port which is connected to the analysis port of the monitor
//this is to pass transactions from the monitor to another component(s) in the 
//verification environment
//------------------------------------------------------------------------------
  uvm_analysis_port #(wb_transaction) aport;   

//------------------------------------------------------------------------------
//Instantiating various components of the agent
//Sequencer, Wishbone driver, I2C driver and a monitor
//------------------------------------------------------------------------------
  wb_sequencer      wb_sequencer_h;
  wb_driver         wb_driver_h;
  wb_monitor        wb_monitor_h;
  wb_cov_subscriber     wb_cov_subscriber_h;

//------------------------------------------------------------------------------
//Instantiating the virtual interface in order retrieve the interface from the
//configuration database. So that driver can drive the signals of the DUT
//from the class based environment
//------------------------------------------------------------------------------
  virtual i2c_if i2c_vi;

//------------------------------------------------------------------------------
//Constructor
//------------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    aport = new("aport", this);
  endfunction

//------------------------------------------------------------------------------
//Overriding the default build method in order to create various objects using
//factory method
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wb_sequencer_h       = wb_sequencer::type_id::create("wb_sequencer_h", this);
    wb_driver_h       = wb_driver::type_id::create("wb_driver_h", this);
    wb_monitor_h      = wb_monitor::type_id::create("wb_monitor_h", this);
    wb_cov_subscriber_h      = wb_cov_subscriber::type_id::create("wb_cov_subscriber_h", this);

    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end 
    uvm_config_db#(virtual i2c_if)::set( this, "wb_driver_h", "vif", i2c_vi);
    uvm_config_db#(virtual i2c_if)::set( this, "wb_monitor_h", "vif", i2c_vi);

  endfunction

//------------------------------------------------------------------------------
//Connect method: Connecting the port of driver to the and export of the sequencer and
//connecting the analysis port of the monitor to the analysis port of this agent
//------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    wb_driver_h.seq_item_port.connect( wb_sequencer_h.seq_item_export);
    wb_monitor_h.aport.connect(aport);
    wb_monitor_h.aport.connect(wb_cov_subscriber_h.analysis_export);
  endfunction

endclass


