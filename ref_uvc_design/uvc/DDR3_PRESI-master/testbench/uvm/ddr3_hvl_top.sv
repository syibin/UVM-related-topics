///top testbench module ///

////////////////////////////////////////////////////////////////////////////
//	ddr3_hvl_top.sv - Top module for the config db
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////

module ddr3_hvl_top;

import uvm_pkg::*;
import ddr3_tb_pkg::*;


initial begin
        //$timeformat (-9, 3, " ns", 1);
	$timeformat (-12,3," ps",10);


	uvm_config_db #(virtual ddr3_interface)::set(null,"uvm_test_top","DDR3_interface",ddr3_top.i);

	run_test();	
end 


endmodule 
