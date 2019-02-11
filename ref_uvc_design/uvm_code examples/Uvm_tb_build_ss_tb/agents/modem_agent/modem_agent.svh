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

class modem_agent extends uvm_agent;
  `uvm_component_utils(modem_agent)

  modem_monitor    m_monitor;
  modem_driver     m_driver;
  modem_sequencer  m_sequencer;
  modem_coverage_monitor m_cov;
  modem_config     m_cfg;
  uvm_analysis_port #(modem_seq_item) ap;

  function new(string name = "modem_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction



    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `get_config(modem_config, m_cfg, "modem_config")
      ap = new("modem_agent_ap", this);
      m_cov = modem_coverage_monitor::type_id::create("m_cov", this);
      m_monitor = modem_monitor::type_id::create("monitor", this);
      m_monitor.m_cfg = m_cfg;
      if (m_cfg.active) begin
        m_driver = modem_driver::type_id::create("drv", this);
        m_driver.m_cfg = m_cfg;
        m_sequencer = modem_sequencer::type_id::create("sequencer", this);
      end
    endfunction: build_phase


  function void connect_phase(uvm_phase phase);
    ap = m_monitor.ap;
    ap.connect(m_cov.analysis_export);
    if(m_cfg.active) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      end
  endfunction: connect_phase

endclass: modem_agent
