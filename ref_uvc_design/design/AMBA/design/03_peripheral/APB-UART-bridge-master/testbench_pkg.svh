package testbench_pkg;
import uvm_pkg::*;
`include "apb_seq_item.svh"
`include "apb_seqr.svh"
`include "apb_driver.svh"
`include "apb_sequence.svh"
//`include "apb_mon.svh"
`include "apb_agent"
//`include "apb_sb.svh"
`include "apb_env.svh"
`include "apb_test.svh"

typedef enum {NORMAL,BURST} traffic_e_t;
endpackage : testbench_pkg
