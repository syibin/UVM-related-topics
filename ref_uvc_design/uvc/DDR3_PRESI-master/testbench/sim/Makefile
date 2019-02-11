

#TEST?=ddr3_reset_test
TEST?=ddr3_single_write_test
#EXTRA?=+UVM_VERBOSITY=UVM_DEBUG +UVM_CONFIG_DB_TRACE +UVM_PHASE_TRACE 
EXTRA?=+UVM_VERBOSITY=UVM_HIGH 

all : clean lib build run extract 

lib :
	vlib work
	vmap work work 

build :
	#vlog +define+sg093 +define+x8 -timescale=1 ps/1ps -mfcu -f rtl.f -f tb.f +cover=bcesfx
	vlog +define+sg093 +define+x8 -timescale=1ps/1ps -f rtl.f -f tb.f +cover=bcesfx

run :
	vsim -c -novopt -cover ddr3_hvl_top ddr3_top +UVM_TESTNAME=$(TEST) $(EXTRA)  -do "run -all;coverage save -onexit ddr3_cov.ucdb;exit"

gui :
	vsim -i -novopt ddr3_hvl_top ddr3_top +UVM_TESTNAME=$(TEST) $(EXTRA) 

extract :
	vcover report -details -html ddr3_cov.ucdb

clean:
	rm -rf work ddr3_cov.ucdb covhtmlreport 

