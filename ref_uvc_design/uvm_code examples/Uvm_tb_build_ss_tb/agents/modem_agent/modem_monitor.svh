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
 //
class modem_monitor extends uvm_component;

  `uvm_component_utils(modem_monitor)
   

  // Virtual Interface
  local virtual modem_monitor_bfm m_bfm;

  //------------------------------------------
  // Data Members
  //------------------------------------------
  modem_config m_cfg;
  
  //------------------------------------------
  // Component Members
  //------------------------------------------
  uvm_analysis_port #(modem_seq_item) ap;

  //------------------------------------------
  // Methods
  //------------------------------------------
  
  // Standard UVM Methods:

  function new(string name = "modem_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    `get_config(modem_config, m_cfg, "modem_config")
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;
    
    ap = new("analysis_port", this);
  endfunction : build_phase


  task run_phase(uvm_phase phase);
    m_bfm.run();
  endtask : run_phase

  // Proxy Methods:
  
  function void notify_transaction(modem_seq_item item);
    ap.write(item);
  endfunction : notify_transaction

 endclass: modem_monitor



