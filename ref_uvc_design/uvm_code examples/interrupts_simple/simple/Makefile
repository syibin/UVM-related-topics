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
	vlog +incdir+../utils/interrupt ../utils/interrupt/interrupt_pkg.sv ../utils/interrupt/interrupt_if.sv
	vlog ../bidirect_bus_agent_pkg.sv
	vlog top.sv
	vopt hdl_top hvl_top -o opt

sim:
	vsim -c -do "run -all" opt

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log *.tgz

tar:
	@(cd ../.. ; \
	tar -zcf interrupts/simple/uvm_interrupts_simple.tgz \
	interrupts/bidirect_bus_agent_pkg.sv \
	interrupts/utils \
	interrupts/simple/top.sv \
	interrupts/simple/Makefile \
	interrupts/simple/README.txt; \
	cd interrupts/simple)
