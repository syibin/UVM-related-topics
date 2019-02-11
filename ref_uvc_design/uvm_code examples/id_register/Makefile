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
# ###############################################
# UVM Register - id_register - a quirky register.
# ###############################################
# Questa 10.0b or later will automatically provide
# a +incdir+$(UVM_HOME)/src for vlog, and will automatically
# provide a -sv_lib $UVM_HOME/lib/uvm_dpi for vsim.
#
builtin:
	rm -rf work
	vlib work
	vlog +incdir+apb_agent apb_agent/apb_agent_pkg.sv apb_agent/apb_driver_bfm.sv apb_agent/apb_monitor_bfm.sv
	vlog reg_dut.sv regmodel_pkg.sv uvm_tb_pkg.sv hvl_top.sv hdl_top.sv
	vopt hdl_top hvl_top -o opt
	vsim -c opt -do "run -all; quit -f"



# Make a tarfile for the online cookbook. It prefers .tgz
#  suffix.
tarball: clean
	(cd ..; \
	tar -zcf id_register/uvm_id_register.tgz \
	id_register/README.txt \
	id_register/Makefile \
	id_register/reg_dut.sv \
	id_register/apb_agent \
	id_register/regmodel_pkg.sv \
	id_register/uvm_tb_pkg.sv \
	id_register/hdl_top.sv \
	id_register/hvl_top.sv \
	; \
	)
	@(cd ..; echo "Made `pwd`/uvm_id_register.tgz")

clean: .FORCE
	rm -rf *~ work vsim.wlf* *.log transcript *.vstf *.tgz
	rm -f uvm_dpi.dll

.FORCE:
