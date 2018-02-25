clean
vlib work
vlog -sv -l qsta_compile.log -mfcu -f flist 
vsim -c +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=uart_sequence_test demo_top
add wave *
run 1ms