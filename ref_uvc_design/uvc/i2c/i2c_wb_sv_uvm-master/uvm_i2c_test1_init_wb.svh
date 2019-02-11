//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains a test which instantiates the entire verification 
//environment and configures it to run the test on the DUT 
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

class init_wb extends uvm_test; 
//------------------------------------------------------------------------------
//Registering the class with factory
//------------------------------------------------------------------------------
  `uvm_component_utils(init_wb)

//------------------------------------------------------------------------------
//Instantiating the env
//------------------------------------------------------------------------------
  i2c_env i2c_env_h;
//------------------------------------------------------------------------------
//Instantiating the virtual interface in order retrieve the interface from the
//configuration database. So that driver can drive the signals of the DUT
//from the class based environment
//------------------------------------------------------------------------------
  virtual i2c_if i2c_vi;
 
//------------------------------------------------------------------------------
//Constructor
//------------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

//------------------------------------------------------------------------------
//Build method which creates the environment using factory method
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    i2c_env_h = i2c_env::type_id::create("i2c_env_h", this);
    if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", i2c_vi)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end 
    uvm_config_db#(virtual i2c_if)::set( this, "i2c_env_h", "vif", i2c_vi);
  endfunction

//------------------------------------------------------------------------------
//Run method which creates and starts a sequence on the DUT using the sequencer
//------------------------------------------------------------------------------
  //Run phase - Create an wb_sequence and start it on the wb_sequencer
  task run_phase( uvm_phase phase );
    wb_sequence seq;
    seq = wb_sequence ::type_id::create("seq");
    phase.raise_objection( this, "Starting wb_sequence" );
    $display("%t Starting sequence wb_sequence run_phase",$time);
    seq.start(i2c_env_h.wb_agent_h.wb_sequencer_h);
    #3us;
    phase.drop_objection( this , "Finished wb_seq" );
  endtask: run_phase
  
endclass


