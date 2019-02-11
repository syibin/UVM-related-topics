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
all: lib sv sim

lib:
	vlib work

sv:
	vlog +incdir+../agent ../agent/alu_agent_pkg.sv ../agent/alu_monitor_bfm.sv ../agent/alu_driver_bfm.sv \
	../alu/*.sv +incdir+../uvm_tb ../uvm_tb/alu_tb_pkg.sv
	vlog ../tb/*.sv
	vopt hdl_top hvl_top -o opt

sim:
	vsim -c opt +UVM_TESTNAME=test_all_parallel -do "run -all; quit -f"

tarball: clean tar

clean:
	rm -rf work transcript *.log ../*.tgz

tar:
	@(cd ..; \
	tar -zcf uvm_alu_config_analysis.tgz alu agent uvm_tb tb sim README.txt )


