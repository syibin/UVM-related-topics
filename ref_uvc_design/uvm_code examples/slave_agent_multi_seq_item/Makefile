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
	vlog ./agents/apb_slave_agent/apb_if.sv
	vlog +incdir+./agents/apb_slave_agent ./agents/apb_slave_agent/apb_slave_agent_pkg.sv
	vlog ./agents/apb_slave_agent/apb_slave_monitor_bfm.sv ./agents/apb_slave_agent/apb_slave_driver_bfm.sv
	vlog ./rtl/apb3_wlm_host.sv
	vlog +incdir+./tb ./tb/env_pkg.sv ./tb/top.sv

sim:
	vsim -voptargs=+acc top_tb -c -do "run -all; quit"

clean_up:
	rm -rf work transcript *.tgz

tar:
	cd ../ ; \
	tar -zcf slave_agent_multi_seq_item/uvm_slave_agent_multi_seq_item.tgz \
	slave_agent_multi_seq_item/agents \
	slave_agent_multi_seq_item/rtl \
	slave_agent_multi_seq_item/tb \
	slave_agent_multi_seq_item/Makefile \
	slave_agent_multi_seq_item/README
