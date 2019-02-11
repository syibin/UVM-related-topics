
//-------------------------------------------
// Top level Test module
//  Includes all env component and sequences files 
//-------------------------------------------
 import uvm_pkg::*;
`include "uvm_macros.svh"

 //Include all files

`include "i2c_if.svh"
`include "i2c_m.v"
`include "i2c_seq.svh"
`include "i2c_driver_seq_mon.svh"
`include "i2c_agent_env_config.svh"
`include "i2c_sequences.svh"
`include "i2c_test.svh"

//--------------------------------------------------------
//Top level module that instantiates  just a physical apb interface
//No real DUT or APB slave as of now
//--------------------------------------------------------
module test;

   import uvm_pkg::*;

    //Instantiate a physical interface for APB interface here and connect the pclk input
    i2c_if i2cvif();
  
   initial begin
      i2cvif.sig_clk=0;
   end

    //Generate a clock
   always begin
      forever #5 i2cvif.sig_clk = ~i2cvif.sig_clk;
   end
 
  //Attach VIF to actual DUT
  i2c  my_i2c (.a(i2cvif.sig_a), .b(i2cvif.sig_b), .z(i2cvif.sig_z), .clk(i2cvif.sig_clk), .rst(i2cvif.sig_rst), 
						.ab_ready(i2cvif.sig_ab_ready), .ab_valid(i2cvif.sig_ab_valid),
						.z_valid(i2cvif.sig_z_valid));
  
  initial begin
    //Pass above physical interface to test top
    //(which will further pass it down to env->agent->drv/sqr/mon
    uvm_config_db#(virtual i2c_if)::set(uvm_root::get(), "uvm_test_top", "i2cvif", i2cvif);
  
    //Call the run_test - but passing run_test argument as test class name
    run_test("apb_base_test");

    $finish();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
  end  
  
endmodule
