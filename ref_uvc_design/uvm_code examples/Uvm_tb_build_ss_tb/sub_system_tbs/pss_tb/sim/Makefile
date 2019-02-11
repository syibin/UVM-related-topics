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
BLOCK_TB     ?= ../../../block_level_tbs
RTL          ?= ../../../rtl
AGENTS       ?= ../../../agents
UTILS        ?= ../../../utils
TAR_PATH     ?= ../../../../
TEST         ?= pss_spi_interrupt_test
UVM_HOME     = $(QUESTA_HOME)/verilog_src/uvm-1.2

all: work uvm rtl build tb run

debug: work uvm rtl build tb opt sim

uvm:
	vlog +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv -ccflags -DQUESTA \
                 -ccflags -Wno-maybe-uninitialized \
                 -ccflags -Wno-missing-declarations \
                 -ccflags -Wno-return-type \
                 ${UVM_HOME}/src/dpi/uvm_dpi.cc \

rtl:
	vlog +incdir+$(RTL)/spi/rtl/verilog $(RTL)/spi/rtl/verilog/*.v
	vlog +incdir+$(RTL)/gpio/rtl/verilog $(RTL)/gpio/rtl/verilog/*.v
	vlog -sv +incdir+$(RTL)/uart/rtl $(RTL)/uart/rtl/*.v
	vlog $(RTL)/icpit/rtl/*.v -timescale 1ns/10ps
	vlog +incdir+$(RTL)/gpio/rtl/verilog $(RTL)/ahb2apb/rtl/*.sv -timescale 1ns/10ps
	vlog +incdir+$(RTL)/gpio/rtl/verilog $(RTL)/pss/rtl/pss.sv -timescale 1ns/10ps
	vlog $(RTL)/pss/rtl/pss_wrapper.sv -timescale 1ns/10ps

tarball: clean tar

work:
	vlib work

build:
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/apb_agent +incdir+$(UTILS) $(AGENTS)/apb_agent/apb_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/spi_agent +incdir+$(UTILS) $(AGENTS)/spi_agent/spi_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/ahb_agent +incdir+$(UTILS) $(AGENTS)/ahb_agent/ahb_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/gpio_agent +incdir+$(UTILS) $(AGENTS)/gpio_agent/gpio_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/modem_agent +incdir+$(UTILS) $(AGENTS)/modem_agent/modem_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(AGENTS)/uart_agent +incdir+$(UTILS) $(AGENTS)/uart_agent/uart_agent_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/apb_agent/apb_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/apb_agent/apb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/apb_agent/apb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/spi_agent/spi_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/spi_agent/spi_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/spi_agent/spi_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/gpio_agent/gpio_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/gpio_agent/gpio_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/gpio_agent/gpio_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/ahb_agent/ahb_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/ahb_agent/ahb_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/ahb_agent/ahb_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/modem_agent/modem_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/modem_agent/modem_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/modem_agent/modem_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/uart_agent/serial_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/uart_agent/uart_monitor_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(AGENTS)/uart_agent/uart_driver_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(UTILS)/interrupt/intr_pkg.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(UTILS)/interrupt/intr_if.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src $(UTILS)/interrupt/intr_bfm.sv -timescale 1ns/10ps -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/spi_tb/register_model $(BLOCK_TB)/spi_tb/register_model/spi_reg_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/gpio_tb/register_model $(BLOCK_TB)/gpio_tb/register_model/gpio_reg_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+../register_model ../register_model/pss_reg_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/spi_tb/env $(BLOCK_TB)/spi_tb/env/spi_env_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/gpio_tb/env $(BLOCK_TB)/gpio_tb/env/gpio_env_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+../env ../env/pss_env_pkg.sv -suppress 2263
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/spi_tb/sequences $(BLOCK_TB)/spi_tb/sequences/spi_bus_sequence_lib_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/spi_tb/sequences $(BLOCK_TB)/spi_tb/sequences/spi_test_seq_lib_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/gpio_tb/sequences $(BLOCK_TB)/gpio_tb/sequences/gpio_bus_sequence_lib_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+$(BLOCK_TB)/gpio_tb/sequences $(BLOCK_TB)/gpio_tb/sequences/gpio_test_sequence_lib_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+../sequences ../sequences/pss_test_seq_lib_pkg.sv
	vlog +incdir+$(UVM_HOME)/src +incdir+../test ../test/pss_test_lib_pkg.sv -suppress 2263

tb:
	vlog -timescale 1ns/10ps ../tb/apb_prober.sv -timescale 1ns/10ps
	vlog -timescale 1ns/10ps ../tb/binder.sv -timescale 1ns/10ps
	vlog -timescale 1ns/10ps +incdir+$(RTL)/gpio/rtl/verilog ../tb/hvl_top.sv -timescale 1ns/10ps
	vlog -timescale 1ns/10ps +incdir+$(RTL)/gpio/rtl/verilog ../tb/hdl_top.sv -timescale 1ns/10ps

opt:
	vopt hdl_top hvl_top -o opt -debug -designfile design.bin

sim:
	vsim -c opt -qwavedb=+signal+class -do "run -a; quit" +UVM_TESTNAME="$(TEST)"

viz:
	visualizer -designfile design.bin -wavefile qwave.db

run:
	vsim -c -do "run -all" hvl_top hdl_top +UVM_TESTNAME="$(TEST)" -suppress 8887 -suppress 12003 -permit_unmatched_virtual_intf

clean:
	@rm -rf work transcript *~ vsim.wlf *.log *.tgz *.db *.bin
	@find ../../../ -name "*~" -delete

tar:
	@(cd $(TAR_PATH);\
	tar -zcf tb_build/sub_system_tbs/pss_tb/sim/uvm_tb_build_ss_tb.tgz \
	tb_build/agents \
        tb_build/utils \
	tb_build/rtl \
	tb_build/block_level_tbs/gpio_tb/env \
	tb_build/block_level_tbs/gpio_tb/register_model \
	tb_build/block_level_tbs/gpio_tb/sequences \
	tb_build/block_level_tbs/gpio_tb/tb \
	tb_build/block_level_tbs/gpio_tb/test \
	tb_build/block_level_tbs/spi_tb/env \
	tb_build/block_level_tbs/spi_tb/register_model \
	tb_build/block_level_tbs/spi_tb/sequences \
	tb_build/block_level_tbs/spi_tb/tb \
	tb_build/block_level_tbs/spi_tb/test \
	tb_build/sub_system_tbs/pss_tb/env \
	tb_build/sub_system_tbs/pss_tb/test \
	tb_build/sub_system_tbs/pss_tb/sequences \
	tb_build/sub_system_tbs/pss_tb/register_model \
	tb_build/sub_system_tbs/pss_tb/tb \
	tb_build/sub_system_tbs/pss_tb/sim/Makefile \
	tb_build/sub_system_tbs/pss_tb/sim/README.txt)
