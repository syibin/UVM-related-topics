//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the definition of the i2c verification env class. 
//This class instantiates the agent and subscriber.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_env extends uvm_env; 
//------------------------------------------------------------------------------
//Registering the class with the factory utils
//------------------------------------------------------------------------------
  `uvm_component_utils(i2c_env)

//------------------------------------------------------------------------------
//Instantiating the agent and coverage subscriber
//------------------------------------------------------------------------------
  i2c_agent i2c_agent_h;
  wb_agent wb_agent_h;
  i2c_wb_scoreboard i2c_wb_scoreboard_h;
  //i2c_subscriber i2c_subscriber_h;
  //wb_subscriber wb_subscriber_h;


//------------------------------------------------------------------------------
//Instantiating the virtual interface in order retrieve the interface from the
//configuration database. So that driver can drive the signals of the DUT
//from the class based environment
//------------------------------------------------------------------------------
  virtual i2c_if i2c_vi;

//------------------------------------------------------------------------------
//Constructor for this class
//------------------------------------------------------------------------------

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

//------------------------------------------------------------------------------
//Build method which creates agent and subscriber objects using factory method
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i2c_wb_scoreboard_h = i2c_wb_scoreboard::type_id::create("i2c_wb_scoreboard_h", this);
    i2c_agent_h = i2c_agent::type_id::create("i2c_agent_h", this);
    //i2c_subscriber_h = i2c_subscriber::type_id::create("i2c_subscriber_h", this);
    wb_agent_h = wb_agent::type_id::create("wb_agent_h", this);
    //wb_subscriber_h = wb_subscriber::type_id::create("wb_subscriber_h", this);

    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end

    uvm_config_db#(virtual i2c_if)::set( this, "i2c_agent_h", "vif", i2c_vi);
    uvm_config_db#(virtual i2c_if)::set( this, "wb_agent_h", "vif", i2c_vi);

  endfunction

//------------------------------------------------------------------------------
//Connecting the analysis port of the agent to the export of the coverage subscriber
//in order to receive transaction for coverage purposes
//------------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    //i2c_agent_h.aport.connect(i2c_subscriber_h.analysis_export);
    //wb_agent_h.aport.connect(wb_subscriber_h.analysis_export);
  endfunction


endclass


