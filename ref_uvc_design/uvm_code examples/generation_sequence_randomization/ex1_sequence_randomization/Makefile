#------------------------------------------------------------------------------
#   Copyright 2010-2018 Mentor Graphics Corporation
#   All Rights Reserved Worldwide
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
all: work build opt sim

tarball: clean_up tar

work:
	vlib work

build:
	vlog ../common/bus_if.sv
	vlog ../common/dut.sv
	vlog ../common/bus_agent_pkg.sv
	vlog ../sequence_library/bus_seq_lib_pkg.sv
	vlog ../tests/test_lib_pkg.sv
	vlog ../common/top_tb.sv

opt:
	vopt -o opt top_tb -debug +designfile

sim: opt
	vsim -c -do "run -all" -sv_seed 10 opt +UVM_TESTNAME=seq_rand_test -qwavedb=+signal+transaction+class+memory=4096,4+uvm_schematic

vis:
	visualizer design.bin qwave.db

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log design.bin qwave.db *.tgz

tar:
	@(cd ../.. ;\
	tar -zcf generation/ex1_sequence_randomization/uvm_generation_seq_randomization.tgz \
	generation/common \
	generation/sequence_library \
	generation/tests \
	generation/ex1_sequence_randomization/Makefile \
	generation/ex1_sequence_randomization/README.txt; \
	cd generation/ex1_sequence_randomization)
