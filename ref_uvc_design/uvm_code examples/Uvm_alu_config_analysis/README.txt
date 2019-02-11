README.txt

**************
DUT

The DUT is a simple ALU that does ADD, SUB, MUL and DIV operations. The 
alu_rtl_pipelined version has a two-stage pipeline to drive out-of-order 
responses.


**************
Testbench

The Testbench has an agent with sequencer, driver, monitor and coverage
collector. The driver has been augmented with an analysis_port to provide
the "before" stream of transactions to the scoreboard. The "after" port of the
scoreboard is connected to the monitor_ap. The default test from the Makefile
is test_all_parallel, which runs four concurrent sequences, which do ADD, SUB,
MUL and DIV operations, respectively, until 100% coverage is reached in each
of four covergroups.

***************
To run the example:

cd sim
make


***************
Verifying output

This testbench is self checking. If it is successful, you will see a message
like
# UVM_INFO ./alu_tests/alu_seq_test_base.svh(56) @ 1792150: uvm_test_top [** UVM TEST PASSED **] PASSED: Congratulations!

printed at the end of simulation. If the test fails, you will see something 
like

# UVM_ERROR ./alu_tests/alu_seq_test_base.svh(58) @ 1792150: uvm_test_top [!! UVM TEST FAILED !!] FAILED: Bummer!
