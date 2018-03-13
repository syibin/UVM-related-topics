clean
vlib work
vlog -sv -l qsta_compile.log -mfcu -f flist 
#vsim -c  +UVM_TESTNAME=apb_subsystem_test apb_subsystem_top -do "run -all;quit"
vsim -c -suppress 3009 -debugDB +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=apb_subsystem_test apb_subsystem_top -do "run -all"

