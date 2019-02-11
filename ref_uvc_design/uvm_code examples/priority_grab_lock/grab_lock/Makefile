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

build:
	vlog top.sv

sim:
	vsim -c +ARB_TYPE=SEQ_ARB_FIFO -do "run -all" top -l SEQ_ARB_FIFO.log
	vsim -c +ARB_TYPE=SEQ_ARB_WEIGHTED -do "run -all" top -l SEQ_ARB_WEIGHTED.log
	vsim -c +ARB_TYPE=SEQ_ARB_RANDOM -do "run -all" top -l SEQ_ARB_RANDOM.log
	vsim -c +ARB_TYPE=SEQ_ARB_STRICT_FIFO -do "run -all" top -l SEQ_ARB_STRICT_FIFO.log
	vsim -c +ARB_TYPE=SEQ_ARB_STRICT_RANDOM -do "run -all" top -l SEQ_ARB_STRICT_RANDOM.log
	vsim -c +ARB_TYPE=SEQ_ARB_USER -do "run -all" top -l SEQ_ARB_USER.log

clean:
	rm -rf work transcript *~ vsim.wlf *.log

tar:
	@(cd ../.. ; \
	tar -zcf priority/grab_lock/uvm_priority_grab_lock.tgz \
	priority/grab_lock/top.sv \
	priority/grab_lock/Makefile \
	priority/grab_lock/README.txt; \
	cd priority/grab_lock)
