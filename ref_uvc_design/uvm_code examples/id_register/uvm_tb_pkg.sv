// ----------------------------------------------------------
// Copyright 2018 Mentor Graphics Corporation
// All Rights Reserved Worldwide
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ----------------------------------------------------------
package uvm_tb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import regmodel_pkg::*;
import apb_agent_pkg::*;

class env_config extends uvm_object;

`uvm_object_utils(env_config)

apb_agent_config apb_master_cfg;

reg2apb_adapter m_reg2apb;
uvm_reg_predictor#(apb_seq_item) m_apb2reg_predictor;

block_B id_rb;

function new(string name = "env_config");
  super.new(name);
  id_rb = block_B::type_id::create("id_rb");
  // Build and configure the register model
  id_rb.build();
endfunction


endclass

class env extends uvm_component;

`uvm_component_utils(env)

function new(string name = "env", uvm_component parent = null);
  super.new(name, parent);
endfunction

apb_agent apb_master;
env_config cfg;

// Register layer adapter
reg2apb_adapter m_reg2apb;
// Register predictor
uvm_reg_predictor#(apb_seq_item) m_apb2reg_predictor;


function void build_phase(uvm_phase phase);
  apb_master = apb_agent::type_id::create("apb_master", this);
  apb_master.m_cfg = cfg.apb_master_cfg;

  // Build the register model predictor
  m_apb2reg_predictor = uvm_reg_predictor#(apb_seq_item)::type_id::create("m_apb2reg_predictor", this);
  m_reg2apb = reg2apb_adapter::type_id::create("m_reg2apb");

endfunction

function void connect_phase(uvm_phase phase);
  cfg.id_rb.default_map.set_sequencer(apb_master.m_sequencer, m_reg2apb);
  //
  // Register prediction part:
  //
  // Replacing implicit register model prediction with explicit prediction
  // based on APB bus activity observed by the APB agent monitor
  // Set the predictor map:
  m_apb2reg_predictor.map = cfg.id_rb.default_map;
  // Set the predictor adapter:
  m_apb2reg_predictor.adapter = m_reg2apb;
  // Disable the register models auto-prediction
  cfg.id_rb.default_map.set_auto_predict(0);
  // Connect the predictor to the bus agent monitor analysis port
  apb_master.ap.connect(m_apb2reg_predictor.bus_in);

endfunction

endclass

class test_seq extends uvm_sequence #(apb_seq_item);

`uvm_object_utils(test_seq)

block_B rb;

function new(string name = "test_seq");
  super.new(name);
endfunction

uvm_status_e   status;
uvm_reg_data_t data;

int errors;
uvm_reg_data_t id_data[] = '{'ha0, 'ha1, 'ha2, 'ha3, 'ha4,
                             'ha5, 'ha6, 'ha7, 'ha8, 'ha9};


task body;
  `uvm_info("Test", "Demonstrating ID register and RO/WO sharing...",UVM_NONE);

  // *****************************************
  // Issue a READ and then do a check.
  //
  for(int i = 0; i < 25; i++) begin
    rb.ID.read(status, data);
  end
  // *****************************************
  // Write to the ID register (changes the pointer).
  // Then read.
  `uvm_info("Write ID pointer test", "", UVM_MEDIUM)
  for(int i = 0; i < 25; i++) begin
    uvm_reg_data_t rdata, wdata;
    wdata = i % 10;

    // Writes the pointer.
    rb.ID.write(status, wdata);
    // Reads the ID.
    rb.ID.read(status, rdata);

    if(rdata != id_data[wdata]) begin
      `uvm_error("ID_IDX_WR", $sformatf("Index %0d returned %0d expected %0d", wdata, rdata, id_data[wdata]))
    end
  end
  `uvm_info("Co-located TEST", "", UVM_MEDIUM)
  begin
    // Leftover, old tests.
    rb.W.write(status, 32'hDEADBEEF);
    rb.R.read(status, data);

  end

endtask

endclass

class test extends uvm_component;

`uvm_component_utils(test)

function new(string name = "test", uvm_component parent = null);
  super.new(name, parent);
endfunction

env tb_env;
env_config env_cfg;
apb_agent_config apb_master_cfg;

function void build_phase(uvm_phase phase);
  env_cfg = env_config::type_id::create("env_cfg");
  apb_master_cfg = apb_agent_config::type_id::create("apb_master_cfg");
  if(!uvm_config_db #(virtual apb_driver_bfm)::get(this, "", "APB_MASTER", apb_master_cfg.drv_bfm)) begin
    `uvm_error("UVM_CFG_DB", "Unable to find apb_driver_bfm in uvm_config_db")
  end
  if(!uvm_config_db #(virtual apb_monitor_bfm)::get(this, "", "APB_MONITOR", apb_master_cfg.mon_bfm)) begin
    `uvm_error("UVM_CFG_DB", "Unable to find apb_monitor_bfm in uvm_config_db")
  end
  apb_master_cfg.start_address[0] = 32'h0;
  apb_master_cfg.range[0] = 32'h1000;
  env_cfg.apb_master_cfg = apb_master_cfg;
  tb_env = env::type_id::create("tb_env", this);
  tb_env.cfg = env_cfg;
endfunction

task run_phase(uvm_phase phase);
  test_seq t = test_seq::type_id::create("t");
  t.rb = env_cfg.id_rb;

  phase.raise_objection(this);
  #1us;
  t.start(tb_env.apb_master.m_sequencer);
  phase.drop_objection(this);

endtask

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    svr = uvm_report_server::get_server();

    if(svr.get_severity_count(UVM_ERROR) == 0) begin
      `uvm_info("** UVM TEST PASSED **", "No comparison errors occured", UVM_MEDIUM)
    end
    else begin
      `uvm_error("!! UVM TEST FAILED !!", "ID register comparison errors")
    end

  endfunction

endclass

endpackage
