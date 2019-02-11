all: work rtl agents tb sim

work:
	vlib work

rtl:
	vlog ../rtl/*.sv

agents:
	vlog ../tb/agents/signal_agent/signal_if.sv
	vlog ../tb/agents/apb_agent/apb_if.sv
	vlog +incdir+../tb/agents/apb_agent ../tb/agents/apb_agent/apb_agent_pkg.sv
	vlog +incdir+../tb/agents/signal_agent ../tb/agents/signal_agent/signal_agent_pkg.sv

tb:
	vlog ../tb/registers/biquad_reg_pkg.sv
	vlog +incdir+../tb/env ../tb/env/biquad_env_pkg.sv
	vlog +incdir+../tb/sequences ../tb/sequences/biquad_vseq_pkg.sv
	vlog +incdir+../tb/test ../tb/test/biquad_test_pkg.sv
	vlog ../tb/tb/biquad_tb.sv

sim:
	vsim biquad_tb +UVM_TESTNAME=biquad_smoke_test -c -do "coverage save biquad_smoke.ucdb -onexit;run -all;quit -f"

guisim:
	vsim biquad_tb +UVM_TESTNAME=biquad_smoke_test 

soak_test:
	vsim biquad_tb +UVM_TESTNAME=biquad_test -c -do "coverage save biquad_soak.ucdb -onexit;run -all;quit -f"

clean:
	rm -r work

tarball: clean tgz

tgz:
	@(cd ../../; \
	tar -zcf biquad_example/sim/biquad_example.tgz \
	biquad_example/tb \
	biquad_example/rtl \
	biquad_example/sim/Makefile \
	biquad_example/README)


