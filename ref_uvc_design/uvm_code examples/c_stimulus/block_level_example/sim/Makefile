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
RTL ?= ../rtl
AGENTS ?= ../agents
PKG ?= ../../c_stimulus_pkg
TAR_PATH ?= ../../../
UVM_TB ?= ../uvm_tb

all: work build dpi run

tarball: clean tar

work:
	vlib work

build:
	vlog  +incdir+$(PKG) $(PKG)/c_stimulus_pkg.sv -dpiheader sv_dpi.h
	vlog  +incdir+$(PKG) $(PKG)/isr_pkg.sv -dpiheader sv_dpi.h
	vlog +incdir+$(RTL)/spi/rtl/verilog $(RTL)/spi/rtl/verilog/*.v +acc
	vlog  +incdir+$(AGENTS)/apb_agent $(AGENTS)/apb_agent/apb_agent_pkg.sv
	vlog  +incdir+$(AGENTS)/spi_agent $(AGENTS)/spi_agent/spi_agent_pkg.sv
	vlog  +incdir+$(UVM_TB)/uvm_register_model $(UVM_TB)/uvm_register_model/spi_reg_pkg.sv
	vlog $(AGENTS)/apb_agent/apb_if.sv -timescale 1ns/10ps
	vlog $(AGENTS)/spi_agent/spi_if.sv -timescale 1ns/10ps
	vlog $(UVM_TB)/tb/intr_if.sv -timescale 1ns/10ps
	vlog  +incdir+$(UVM_TB)/env $(UVM_TB)/env/spi_env_pkg.sv
	vlog  +incdir+$(UVM_TB)/sequences $(UVM_TB)/sequences/spi_bus_sequence_lib_pkg.sv
	vlog  +incdir+$(UVM_TB)/sequences $(UVM_TB)/sequences/spi_sequence_lib_pkg.sv
	vlog  +incdir+$(UVM_TB)/sequences $(UVM_TB)/sequences/spi_virtual_seq_lib_pkg.sv
	vlog  +incdir+$(UVM_TB)/test $(UVM_TB)/test/spi_test_lib_pkg.sv -dpiheader sv_dpi.h
	vlog  -timescale 1ns/10ps +incdir+$(RTL)/spi/rtl/verilog $(UVM_TB)/tb/top_tb.sv

dpi:
	vlog +incdir+$(PKG) $(PKG)/reg_api.c
	vlog +incdir+../c_code ../c_code/spi_int_test.c -ccflags -I$(PKG)
	vlog +incdir+../c_code ../c_code/spi_c_poll_test.c -ccflags -I$(PKG)



run:
	vsim -c -do "run -all" top_tb +UVM_TESTNAME=spi_c_int_test 
	vsim -c -do "run -all" top_tb +UVM_TESTNAME=spi_c_poll_test 

clean:
	@rm -rf work transcript *~ vsim.wlf *.log *.tgz *.h

tar:
	@(cp README.txt ../../.; cd $(TAR_PATH);\
	tar -zcf uvm_c_stimulus_bl_example.tgz \
	c_stimulus/block_level_example/agents \
	c_stimulus/block_level_example/rtl \
	c_stimulus/block_level_example/uvm_tb \
	c_stimulus/block_level_example/c_code \
	c_stimulus/c_stimulus_pkg \
	c_stimulus/block_level_example/sim/Makefile \
	c_stimulus/README.txt)

