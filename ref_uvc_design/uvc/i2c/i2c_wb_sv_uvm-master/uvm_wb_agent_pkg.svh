//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains the WB agent package in which all the class based components of the 
//WB agent has been included  
//This class instantiates the agent and subscriber.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------

package wb_agent_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;


`include "uvm_wb_transaction.svh"
`include "uvm_wb_sequence.svh"
`include "uvm_wb_sequencer.svh"
`include "uvm_wb_master_driver.svh"
`include "uvm_wb_monitor.svh"
`include "uvm_wb_agent.svh"
`include "uvm_wb_cov_subscriber.svh"

endpackage
