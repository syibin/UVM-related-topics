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

tarball: clean tar

work:
	vlib work

build: build_tb build_hdl opt

build_tb:
	vlog ../mbus_slave/mbus_types_pkg.sv ../mbus_slave/mbus_slave.sv
	vlog +incdir+./mbus_pipelined_agent ./mbus_pipelined_agent/mbus_pipelined_agent_pkg.sv
	vlog top_tb.sv

build_hdl:
	vlog ../mbus_slave/mbus_types_pkg.sv ../mbus_slave/mbus_slave.sv
	vlog ./mbus_pipelined_agent/mbus_pipelined_driver_bfm.sv
	vlog top_hdl.sv

opt:
	vopt top_tb top_hdl -o opt

sim:
	vsim -c -do "run -all" opt

gui:
	vsim -classdebug top_tb -voptargs=+acc

clean:
	rm -rf work transcript *~ vsim.wlf *.log

tar:
	@(cd ../../ ; \
	tar -zcf use_models/pipelined_item_done/uvm_use_models_pipelined_item_done.tgz \
	use_models/pipelined_item_done/top_tb.sv \
	use_models/pipelined_item_done/top_hdl.sv \
	use_models/pipelined_item_done/Makefile \
	use_models/pipelined_item_done/README.txt \
	use_models/mbus_slave \
	use_models/pipelined_item_done/mbus_pipelined_agent; \
	cd use_models/pipelined_item_done)
