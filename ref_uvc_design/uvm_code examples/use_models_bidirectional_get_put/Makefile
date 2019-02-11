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
	vlog top_tb.sv top_hdl.sv

sim:
	vsim -c -do "run -all" top_tb top_hdl

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log

tar:
	@(cd ../../ ; \
	tar -zcf use_models/bidirectional_get_put/uvm_use_models_bidir_get_put.tgz \
	use_models/bidirectional_get_put/top_tb.sv \
	use_models/bidirectional_get_put/top_hdl.sv \
	use_models/bidirectional_get_put/Makefile \
	use_models/bidirectional_get_put/README.txt; \
	cd use_models/bidirectional_get_put)
