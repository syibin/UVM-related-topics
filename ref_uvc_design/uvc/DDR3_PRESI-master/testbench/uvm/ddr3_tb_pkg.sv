////////////////////////////////////////////////////////////////////////////
//	ddr3_tb_pkg.sv - package file where we include the macros and paramters. 
//					It also has address, mode structures.
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////


/// testbench components ///

package ddr3_tb_pkg;

// include parameters and uvm macros
`include "uvm_macros.svh";
`include "1024Mb_ddr3_parameters.vh";
import uvm_pkg::*;

parameter MASK=1;
parameter MASK_I=0;

// Various commands that are done in Memory Controller
typedef enum {DESELECT,NOP,ZQ_CAL_L,ZQ_CAL_S,ACTIVATE,READ,WRITE,PRECHARGE,REFRESH,SELF_REFRESH,DLL_DIS,MSR,RESET} command_t;

						// usedefined data type for the rows column and bank
typedef bit [ROW_BITS-1:0]  row_t;
typedef bit [BA_BITS-1:0]   bank_t;
typedef bit [COL_BITS-1:0]  column_t;

typedef logic [DQ_BITS-1:0]   data_t;

typedef bit [ADDR_BITS-1:0] bus_addr_t;

					// structure for the adrress bus
typedef struct packed {bank_t ba;bus_addr_t bus_addr;} cfg_mode_reg_t;

typedef struct packed {row_t row;bank_t bank;column_t column;} proc_addr_t;  // address packed as row bank and column

typedef int unsigned u_int_t;

function u_int_t ceil(input real number);
	if (number > $rtoi(number))
		ceil = unsigned'($rtoi(number)) + 1;
	else
		ceil = unsigned'($rtoi(number));

endfunction




// include all the uvm files.
//include "../duv/ddr3_interface.sv";
include "ddr3_seq_item.sv";
include "mode_reg_0.sv";
include "mode_reg_1.sv";
include "mode_reg_2.sv";
include "mode_reg_3.sv";
include "ddr3_tb_reg_model.sv";
include "ddr3_sequencer.sv";
include "ddr3_tb_driver.sv";
include "ddr3_input_monitor.sv";
include "ddr3_coverage.sv";
include "ddr3_env.sv";
include "../sequences/ddr3_rst_seq.sv";
include "../sequences/ddr3_mode_reg0_seq.sv";
include "../sequences/ddr3_mode_reg1_seq.sv";
include "../sequences/ddr3_mode_reg2_seq.sv";
include "../sequences/ddr3_mode_reg3_seq.sv";
include "../sequences/ddr3_set_reg0_seq.sv";
include "../sequences/ddr3_set_reg1_seq.sv";
include "../sequences/ddr3_set_reg2_seq.sv";
include "../sequences/ddr3_set_reg3_seq.sv";
include "../sequences/ddr3_set_all_reg_seq.sv";
include "../sequences/ddr3_write_seq.sv";
include "../sequences/ddr3_write_test_seq.sv";
include "../tests/ddr3_base_test.sv";
include "../tests/ddr3_reset_test.sv";
include "../tests/ddr3_all_mode_reg_test.sv";
include "../tests/ddr3_single_write_test.sv";

endpackage  
