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
all: lib sv opt sim

lib:
	vlib work

sv:
	vlog +incdir+../sfr_agent ../sfr_agent/sfr_agent_pkg.sv \
             ../sfr_agent/sfr_master_bfm.sv ../sfr_agent/sfr_monitor_bfm.sv \
             +incdir+../sfr_test_pkg ../sfr_test_pkg/sfr_test_pkg.sv \
             ../tb/*.sv ../rtl/sfr_dut.sv

opt:
	vopt hdl_top hvl_top -o opt

sim:
	vsim -c opt +UVM_TESTNAME=sfr_test -do "run -a; quit -f"

tarball:
	rm -rf work transcript ../*.tgz
	cp -r ../../rtl ../.
	@(cd ..;\
	tar -zcf uvm_ac_config_db.tgz rtl sfr_agent tb sfr_test_pkg sim README.txt )
	chmod -R 777 ../rtl
	rm -r ../rtl 

clean:
	rm -rf work transcript
	
