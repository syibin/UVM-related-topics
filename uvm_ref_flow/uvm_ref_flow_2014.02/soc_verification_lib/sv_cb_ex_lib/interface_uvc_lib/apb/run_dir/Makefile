clean:
	rm -fr csrc simv* *.key *.vpd work vsim* transc* *.log DVE* vc_h* compile library.cfg *.acdb datase*  

qsta: clean
	vlib work
	vlog -sv -l qsta_compile.log -mfcu -f flist 
	vsim -c  +UVM_TESTNAME=apb_subsystem_test apb_subsystem_top -do "run -all;quit"

q_gui:
	vsim -c +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=apb_subsystem_test apb_subsystem_top -do "run -all;quit"


vcs:clean
	vcs -sverilog -debug_all -timescale="1ns/1ps" -ntb_opts uvm -f flist -l vcs_comp.log  
	./simv  +UVM_TESTNAME=apb_subsystem_test -l run_vcs.log
dve:
	./simv -gui +UVM_TESTNAME=apb_subsystem_test -l run_vcs.log

cdn:
	irun -access +rw -uvm -f flist +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=apb_subsystem_test -l cdn_compile.log

rvra:
	vsim -c -do rvra_do.do

