//------------------------------------------------------------------------------
//Verification Engineer: Rajkumar Raval
//Company Name: Personal Project.
//File Description: This is the top module for the SystemVerilog-OVM based module level
//verification environment for an OpenCores I2C module. Contains instantiation of the DUT, 
//Initialisation and reset. Also contain some assertions, TODO. 
//License: Released under Creative Commons Attribution - BY
//------------------------------------------------------------------------------

`include "uvm_macros.svh"
`include "uvm_i2c_interface.sv"
`include "uvm_i2c_env_pkg.svh"

module top;
//------------------------------------------------------------------------------
//Uvm package 
//------------------------------------------------------------------------------
import uvm_pkg::*;
//------------------------------------------------------------------------------
//Env package
//------------------------------------------------------------------------------
import i2c_env_pkg::*;


  logic clk, clk_sda;
  logic reset;

//------------------------------------------------------------------------------
//TB-DUT Interface
//------------------------------------------------------------------------------
	i2c_if i2c_if_top(clk, clk_sda);					    // Interface 

  wire i2c_core_scl_o;
	wire i2c_core_scl_oe;
//	wire i2c_core_scl_in;

	wire i2c_core_sda_o;
	wire i2c_core_sda_oe;
//	wire i2c_core_sda_in;

	wire temp_sda;
	wire temp_scl;

//------------------------------------------------------------------------------
//These emulates pull up registers on SCL and SDA lines
//So when i2c_if_top.sda_oe is driven low from testbench the DUT gets the respective
//line driven low. However when TB asserts the same signal high the DUT sees the
//pull up which DUT could drive low to assert 0
//------------------------------------------------------------------------------
  pullup p1_if(i2c_if_top.sda);				// Pull up sda line
  pullup p2_if(i2c_if_top.scl);				// Pull up scl line
    
//------------------------------------------------------------------------------
//These emulate the Tri-State buffers for SCL and SDA lines to and from DUT & TB
//Master to Slave and vice versa 
//-----------------------------------------------------------------------------

  assign i2c_core_sda_o = 1'b0;
	assign temp_sda = i2c_if_top.sda_oe & i2c_core_sda_oe;
	assign i2c_if_top.sda = temp_sda ? 1'bz : 1'b0;

	assign temp_scl = i2c_if_top.scl_oe & i2c_core_scl_oe;
	assign i2c_if_top.scl = temp_scl ? 1'bz : 1'b0;

//--------------------------------------------------------------------------
//DUT - I2C Module, configured to behave like a I2C slave
//--------------------------------------------------------------------------

// I2C Core (DUT)	
block i2c_core( .scl_in(i2c_if_top.scl),
				        .scl_o(i2c_core_scl_o),
				        .scl_oe(i2c_core_scl_oe),

				        .sda_in(i2c_if_top.sda),
				        .sda_o(i2c_core_sda_o),
				        .sda_oe(i2c_core_sda_oe),

				        .wb_add_i(i2c_if_top.addr_in),
				        .wb_data_i(i2c_if_top.data_in),
        				.wb_data_o(i2c_if_top.data_out),
        				.wb_stb_i(i2c_if_top.wb_stb_i),
        				.wb_cyc_i(i2c_if_top.wb_cyc_i),
        				.wb_we_i(i2c_if_top.we),
        				.wb_ack_o(i2c_if_top.ack_o),
        				.wb_clk_i(clk),
        				.wb_rst_i(i2c_if_top.reset),

        				.irq(i2c_if_top.irq),
        				.trans_comp()
				);

//--------------------------------------------------------------------------
//Passing the wrapper of the virtual interface to the configuration database
//--------------------------------------------------------------------------
  initial begin
    //Pass this physical interface to test top (which will further pass it down to env->agent->drv/sqr/mon
    uvm_config_db#(virtual i2c_if)::set( null, "uvm_test_top", "vif", i2c_if_top);
  end
  

//-----------------------------------------------------------------------
//Basic Initialisation and Reset. Reset could be made a test separately
//-------------------------------------------------------------------------
  initial begin
    clk = 0;
    clk_sda = 0;
    //run_test("init_wb");
    run_test("i2c_test1");
  end

//-----------------------------------------------------------------
//Core Clock
//-----------------------------------------------------------------
  initial 
  begin
    forever begin
      #10ns clk = ~clk;
    end
  end

//-----------------------------------------------------------------
//clock to pump data over the SDA line, from Master (TB) to Slave
//-----------------------------------------------------------------
  initial 
  begin
    forever begin
      #20 clk_sda = ~clk_sda;
    end
  end

//-----------------------------------------------------------------
//Writing assertions for protocol check, TODO
//-----------------------------------------------------------------


//-----------------------------------------------------------------
//-----------------------------------------------------------------

endmodule
