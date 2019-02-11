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
all: clean_up work compile sim

tarball: clean_up tar

work:
	vlib work

compile: a b c abc env test

a:
	vlog a.sv

b:
	vlog b.sv

c:
	vlog c.sv

abc:
	vlog abc_layering.sv

env:
	vlog env.sv

test:
	vlog test.sv
	vopt top -o opt

sim:
	vsim -c -do "run -all; q" opt +UVM_TESTNAME=test

tar:
	@(cd .. ; \
	tar -zcf ./many_to_one/uvm_many_to_one.tgz \
	./many_to_one/*.sv \
	./many_to_one/*.svh \
	./many_to_one/Makefile \
	./many_to_one/README.txt ; \
	cd many_to_one)
       
clean_up:
	rm -rf work transcript *~ vsim* *.tgz

