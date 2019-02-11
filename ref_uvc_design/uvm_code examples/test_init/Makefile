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
all: work build sim

tarball: clean_up tar

work:	
	vlib work

build:
	vlog agent_a_pkg.sv
	vlog agent_b_pkg.sv
	vlog agent_c_pkg.sv
	vlog env_1_pkg.sv
	vlog env_2_pkg.sv
	vlog env_top_pkg.sv
	vlog top_vseq_pkg.sv
	vlog top.sv
	vopt top_tb -o opt
	
sim:
	vsim opt +UVM_TESTNAME=init_vseq_from_test -do "run -all; q" -c

clean_up:
	rm -rf work transcript *.tgz
	
tar:
	cd ../; \
	tar -zcf test_init/uvm_test_init.tgz test_init/*.sv \
	test_init/Makefile \
	test_init/README

