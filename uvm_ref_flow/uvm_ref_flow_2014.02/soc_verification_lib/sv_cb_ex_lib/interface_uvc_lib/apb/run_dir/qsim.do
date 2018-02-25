clean
vlib work
vlog -sv -l qsta_compile.log -mfcu -f flist 
vsim -c +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=test_read_after_write demo_top
add wave *
run 1ms