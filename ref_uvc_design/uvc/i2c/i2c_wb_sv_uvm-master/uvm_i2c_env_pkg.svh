//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This file contains package in which all the class based components of the 
//I2C verification environment has been included  
//This class instantiates the agent and subscriber.
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------

package i2c_env_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "uvm_i2c_wb_scoreboard.svh"

`include "uvm_i2c_transaction.svh"
`include "uvm_i2c_sequence.svh"
`include "uvm_i2c_sequencer.svh"
`include "uvm_i2c_master_driver.svh"
`include "uvm_i2c_monitor.svh"
`include "uvm_i2c_cov_subscriber.svh"
`include "uvm_i2c_agent.svh"


`include "uvm_wb_transaction.svh"
`include "uvm_wb_sequence.svh"
`include "uvm_wb_sequencer.svh"
`include "uvm_wb_driver.svh"
`include "uvm_wb_monitor.svh"
`include "uvm_wb_cov_subscriber.svh"
`include "uvm_wb_agent.svh"


`include "uvm_i2c_env.svh"
`include "uvm_i2c_test1_init_wb.svh"
`include "uvm_i2c_test1_wrt_data.svh"


endpackage
