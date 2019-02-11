#
#------------------------------------------------------------------------------
#   Copyright 2018 Mentor Graphics Corporation
#   All Rights Reserved Worldwide
#
#   Licensed under the Apache License, Version 2.0 (the
#   "License"); you may not use this file except in
#   compliance with the License.  You may obtain a copy of
#   the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in
#   writing, software distributed under the License is
#   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied.  See
#   the License for the specific language governing
#   permissions and limitations under the License.
#------------------------------------------------------------------------------
RTL      ?= ../dut
AGENTS   ?= ../agents
UTILS    ?= ../utils
TAR_PATH ?= ../../

all: work build sim

tarball: clean tar

work:
	vlib work


build:
	vlog +incdir+$(RTL) $(RTL)/*.v $(RTL)/*.sv
	vlog +incdir+$(AGENTS)/ahb_agent +incdir+$(UTILS) $(AGENTS)/ahb_agent/ahb_agent_pkg.sv -suppress 2263
	vlog +incdir+../register_model ../register_model/mem_ss_reg_pkg.sv
	vlog $(AGENTS)/ahb_agent/ahb_if.sv -timescale 1ns/10ps
	vlog $(AGENTS)/ahb_agent/ahb_monitor_bfm.sv -timescale 1ns/10ps 
	vlog $(AGENTS)/ahb_agent/ahb_driver_bfm.sv -timescale 1ns/10ps 
	vlog +incdir+../env ../env/mem_ss_env_pkg.sv
	vlog +incdir+../sequences ../sequences/mem_ss_seq_lib_pkg.sv
	vlog +incdir+../test ../test/mem_ss_test_lib_pkg.sv
	vlog -timescale 1ns/10ps +incdir+$(RTL) ../tb/hvl_top.sv
	vlog -timescale 1ns/10ps +incdir+$(RTL) ../tb/hdl_top.sv

sim:
	vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME=mem_ss_test 

clean:
	@rm -rf work transcript *~ vsim.wlf *.log *.tgz

tar:
	@(cd $(TAR_PATH);\
	tar zcf mem_example/sim/uvm_register_mem_example.tgz \
	mem_example/dut \
	mem_example/agents \
	mem_example/env \
	mem_example/test \
	mem_example/utils \
	mem_example/sequences \
	mem_example/tb \
	mem_example/register_model \
	mem_example/sim/Makefile \
	mem_example/sim/README.txt)
