`include "uvm_macros.svh"
`include "testbench_pkg.svh"

module top();
  import uvm_pkg::*;
  apb_uart_bridge dut0();
  
  logic clk;
  initial begin
    clk = 0;
	forever #5 clk = ~clk;
  end
  
  initial begin
    uvm_config_db#(virtual apb_uart_bridge_if)::set(uvm_root::get(),"*","dut_vif",dut0.apb_uart_bridge_if0);
	run_test("apb_test");
  end
  
  assign dut0.apb_uart_bridge_if0.PCLK = clk;
endmodule