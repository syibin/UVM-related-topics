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
	vlog +incdir+./agents/apb_slave_agent ./agents/apb_slave_agent/apb_slave_agent_pkg.sv
	vlog ./agents/apb_slave_agent/apb_if.sv
	vlog ./agents/apb_slave_agent/apb_slave_driver_bfm.sv
	vlog ./agents/apb_slave_agent/apb_slave_monitor_bfm.sv
	vlog ./rtl/apb3_wlm_host.sv
	vlog +incdir+./tb ./tb/env_pkg.sv ./tb/hdl_top.sv ./tb/hvl_top.sv

sim:
	vsim hdl_top hvl_top -c -do "run -all; quit"

clean_up:
	rm -rf work ../*.tgz

tar:
	cd ../ ; \
	tar -zcf slave_agent/uvm_slave_agent.tgz \
	slave_agent/agents \
	slave_agent/rtl \
	slave_agent/tb \
	slave_agent/Makefile \
	slave_agent/README
