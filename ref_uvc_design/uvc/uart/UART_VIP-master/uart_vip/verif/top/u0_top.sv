`timescale 1ns/1ns
`include "../../u0if.sv"
module u0_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "defines.sv"
  `include "../uart_tx_uvc/uart_env.svh"
  `include "../test/uart_test.sv"

  reg clk, rst;

  int  br;
  real fosc;
  int  delay;

  // interface instance
  u0if u0_if();

  // Design instance
  u0 u0_inst(u0_if);

  initial begin
    uvm_config_db #(virtual u0if)::set(null,"*","u0_if",u0_if);
    clk = 1;
    rst = 1;
    #50 rst = 0;
    // #10000 $finish;
  end 

  always 
    #delay clk = !clk;

  // Assigning/Passing clk and rst to interface signals. 
  assign u0_if.clk = clk;
  assign u0_if.rst = rst;

  u0_xtn    xtn_h;
  u0_uvc    uvc_h;

  function void build();
    // xtn_h  = u0_xtn::type_id::create("xtn_h");
    // drvr_h = u0_driver::type_id::create("drvr_h",);
    // assert(xtn_h.randomize());
    // xtn_h.print();
  endfunction 

  initial begin
    delay = 5;
    // fosc  = (1000000000/(2*delay))*1;
    // br = $ceil(fosc/(16*(10)));
    // $display(" fosc   %d ,  br  %d ",fosc, br);
    run_test("u0_test");
  end 

  // Dumping output files. 
  initial begin
    $dumpfile("u0.vcd");
    $dumpvars(0,u0_top);
  end 


  // Create an agent, env, test. Or follow the labs in the UVM Labs

endmodule : u0_top
