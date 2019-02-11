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

build: build_tb build_hdl

build_tb:
	vlog top_tb.sv

build_hdl:
	vlog top_hdl.sv

sim:
	vsim -c -do "run -all" top_tb top_hdl 

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log *.tgz

tar:
	@(cd ../; \
	tar -zcf ./unidirectional/uvm_use_models_unidirectional.tgz ./unidirectional/top_tb.sv \
	./unidirectional/top_hdl.sv ./unidirectional/Makefile ./unidirectional/README.txt )
