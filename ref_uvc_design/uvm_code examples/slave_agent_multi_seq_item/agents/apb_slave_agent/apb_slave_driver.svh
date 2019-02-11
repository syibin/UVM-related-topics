//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

//
// Class Description:
//
//
class apb_slave_driver extends uvm_driver #(uvm_sequence_item, uvm_sequence_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_slave_driver)

// Virtual Interface
  virtual apb_slave_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
apb_slave_agent_config m_cfg;
//------------------------------------------
// Methods
//------------------------------------------
// Standard UVM Methods:
extern function new(string name = "apb_slave_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: apb_slave_driver

function apb_slave_driver::new(string name = "apb_slave_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_slave_driver::build_phase(uvm_phase phase);
  m_cfg = apb_slave_agent_config::get_config(this);
  m_bfm = m_cfg.drv_bfm;
  m_bfm.set_apb_index(m_cfg.apb_index);
endfunction: build_phase

task apb_slave_driver::run_phase(uvm_phase phase);
  uvm_sequence_item item;
  apb_slave_setup_item req;
  apb_slave_access_item rsp;

  m_bfm.reset();
  
  forever begin
    // Setup Phase
    seq_item_port.get_next_item(item);
    assert ($cast(req, item));
    m_bfm.setup_phase(req);
    seq_item_port.item_done();

    // Access Phase
    seq_item_port.get_next_item(item);
    assert ($cast(rsp, item));
    m_bfm.access_phase(rsp);
    seq_item_port.item_done();
  end

endtask: run_phase
