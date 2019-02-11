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

build: build_common build_tb build_hdl opt

build_common:
	vlog ../mbus_slave/mbus_types_pkg.sv

build_tb:
	vlog +incdir+./mbus_pipelined_agent ./mbus_pipelined_agent/mbus_pipelined_agent_pkg.sv
	vlog top_tb.sv

build_hdl:
	vlog ../mbus_slave/mbus_slave.sv
	vlog ./mbus_pipelined_agent/mbus_pipelined_driver_bfm.sv
	vlog top_hdl.sv

opt:
	vopt top_hdl top_tb -o opt

sim:
	vsim -c -do "run -all" opt

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log *.tgz

tar:
	@(cd ../../ ; \
	tar -zcf use_models/pipelined_get_put/uvm_use_models_pipelined_get_put.tgz \
	use_models/pipelined_get_put/top_hdl.sv \
	use_models/pipelined_get_put/top_tb.sv \
	use_models/pipelined_get_put/Makefile \
	use_models/pipelined_get_put/README.txt \
	use_models/mbus_slave \
	use_models/pipelined_get_put/mbus_pipelined_agent; \
	cd use_models/pipelined_get_put)
