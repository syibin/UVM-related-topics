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
all: clean_up lib sv sim

tarball: clean_up tar

lib: 
	vlib work

sv:
	vlog messaging_example.sv
	vopt top -o opt

sim:
	vsim -c opt +UVM_TESTNAME=message_test -do "run -all; quit"

high_verbosity:
	vsim -c opt +UVM_TESTNAME=message_test +UVM_VERBOSITY=UVM_HIGH -do "run -all; quit"

clean_up:
	rm -rf work transcript *.tgz *.log *.bck

tar:
	tar -zcf uvm_messaging_example.tgz messaging_example.sv Makefile README.txt



