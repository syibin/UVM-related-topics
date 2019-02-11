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
SIMPLE_HOME = ./simple_ovc

all: work build sim

tarball: clean_up tar

work:
	vlib work

build:
	vlog +incdir+$(SIMPLE_HOME) $(SIMPLE_HOME)/simple_pkg.sv
	vlog top.sv


sim:
	vsim -c  -do "run -all" top

clean_up:
	rm -rf work transcript *~ vsim.wlf *.log *.tgz
	
tar:
	@(cd ../.. ; \
	tar -zcf virtual_sequences/standalone_find_all/uvm_virt_seq_find_all.tgz \
	virtual_sequences/standalone_find_all/simple_ovc \
	virtual_sequences/standalone_find_all/top.sv \
	virtual_sequences/standalone_find_all/Makefile \
	virtual_sequences/standalone_find_all/README.txt; \
	cd virtual_sequences/standalone_find_all)
	
	
	
