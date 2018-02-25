# clear the console
clear

# create project library and make sure it is empty
alib work
adel -all

transcript file rvra_comp.log
# compile project's source file (alongside the UVM library)
alog $UVMCOMP -msg 0 -error_limit 1 -dbg -f flist

transcript file rvra_sim.log

# run simulation
asim +access +rw  $UVMSIM apb_subsystem_top +UVM_TESTNAME=apb_subsystem_test +UVM_VERBOSITY=UVM_FULL +UVM_OBJECTION_TRACE
wave -rec sim:/apb_subsystem_top/* 
run -all
