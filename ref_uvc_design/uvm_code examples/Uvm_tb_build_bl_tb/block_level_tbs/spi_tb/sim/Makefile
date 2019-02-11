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
RTL          ?= ../../../rtl
AGENTS       ?= ../../../agents
UTILS        ?= ../../../utils
TAR_PATH     ?= ../../../../
TEST         ?= spi_interrupt_test

all: work build run

tarball: clean tar

work:
	vlib work

build: work
	vlog -incr +incdir+$(RTL)/spi/rtl/verilog $(RTL)/spi/rtl/verilog/*.v
	vlog -incr +incdir+$(AGENTS)/apb_agent +incdir+$(UTILS) $(AGENTS)/apb_agent/apb_agent_pkg.sv -suppress 2263
	vlog -incr +incdir+$(AGENTS)/spi_agent +incdir+$(UTILS) $(AGENTS)/spi_agent/spi_agent_pkg.sv -suppress 2263
	vlog -incr +incdir+../register_model ../register_model/spi_reg_pkg.sv -suppress 2263
	vlog -incr $(AGENTS)/apb_agent/apb_if.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/apb_agent/apb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/apb_agent/apb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/spi_agent/spi_if.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/spi_agent/spi_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(AGENTS)/spi_agent/spi_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(UTILS)/interrupt/intr_pkg.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(UTILS)/interrupt/intr_if.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr $(UTILS)/interrupt/intr_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog -incr +incdir+../env ../env/spi_env_pkg.sv -suppress 2263
	vlog -incr +incdir+../sequences ../sequences/spi_bus_sequence_lib_pkg.sv -suppress 2263
	vlog -incr +incdir+../sequences ../sequences/spi_test_seq_lib_pkg.sv
	vlog -incr +incdir+../test ../test/spi_test_lib_pkg.sv -suppress 2263
	vlog -incr -timescale 1ns/10ps +incdir+$(RTL)/spi/rtl/verilog ../tb/hvl_top.sv
	vlog -incr -timescale 1ns/10ps +incdir+$(RTL)/spi/rtl/verilog ../tb/hdl_top.sv

debug:
	vopt -debug -designfile design.bin hvl_top hdl_top -o opt
	vsim -c -do "run -all" opt -qwavedb=signal
	visualizer -designfile design.bin -wavefile qwave.db

run:
	vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME="$(TEST)" -suppress 8887

clean:
	@rm -rf work transcript *~ vsim.wlf *.log *.tgz
	@find ../../../ -name "*~" -delete

tar:
	@(cd $(TAR_PATH);\
	tar -zcf tb_build/block_level_tbs/spi_tb/sim/uvm_tb_build_bl_tb.tgz \
	tb_build/agents/apb_agent \
	tb_build/agents/spi_agent \
	tb_build/utils \
	tb_build/rtl/spi \
	tb_build/block_level_tbs/spi_tb/env \
	tb_build/block_level_tbs/spi_tb/test \
	tb_build/block_level_tbs/spi_tb/sequences \
	tb_build/block_level_tbs/spi_tb/register_model \
	tb_build/block_level_tbs/spi_tb/tb \
	tb_build/block_level_tbs/spi_tb/sim/Makefile \
	tb_build/block_level_tbs/spi_tb/sim/README.txt)
