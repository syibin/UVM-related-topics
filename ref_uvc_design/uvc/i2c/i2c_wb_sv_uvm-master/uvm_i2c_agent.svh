//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the definition of the i2c agent. The agent comprises of
//sequencer, Wishbone driver, I2C driver and a monitor.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_agent extends uvm_agent; 
  
//------------------------------------------------------------------------------
//Registering the class with factory
//------------------------------------------------------------------------------
  `uvm_component_utils (i2c_agent);
 
//------------------------------------------------------------------------------
//Declaring the analysis port which is connected to the analysis port of the monitor
//this is to pass transactions from the monitor to another component(s) in the 
//verification environment
//------------------------------------------------------------------------------
  uvm_analysis_port #(i2c_transaction) aport;   

//------------------------------------------------------------------------------
//Instantiating various components of the agent
//Sequencer, Wishbone driver, I2C driver and a monitor
//------------------------------------------------------------------------------
  i2c_sequencer     i2c_sequencer_h;
  i2c_master_driver i2c_master_driver_h;
  i2c_monitor       i2c_monitor_h;
  i2c_cov_subscriber    i2c_cov_subscriber_h;

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
    i2c_sequencer_h       = i2c_sequencer::type_id::create("i2c_sequencer_h", this);
    i2c_master_driver_h   = i2c_master_driver::type_id::create("i2c_master_driver_h", this);
    i2c_monitor_h         = i2c_monitor::type_id::create("i2c_monitor_h", this);
    i2c_cov_subscriber_h      = i2c_cov_subscriber::type_id::create("i2c_cov_subscriber_h", this);

    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end 
    uvm_config_db#(virtual i2c_if)::set( this, "i2c_master_driver_h", "vif", i2c_vi);
    uvm_config_db#(virtual i2c_if)::set( this, "i2c_monitor_h", "vif", i2c_vi);

  endfunction

//------------------------------------------------------------------------------
//Connect method: Connecting the port of driver to the and export of the sequencer and
//connecting the analysis port of the monitor to the analysis port of this agent
//------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    i2c_master_driver_h.seq_item_port.connect( i2c_sequencer_h.seq_item_export);
    i2c_monitor_h.aport.connect(aport);
    i2c_monitor_h.aport.connect(i2c_cov_subscriber_h.analysis_export);
  endfunction

endclass


