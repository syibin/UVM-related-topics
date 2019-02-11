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

package modem_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "config_macro.svh"

//-- modem agent config --
class modem_config extends uvm_object;
  `uvm_object_utils(modem_config)

  // BFM Virtual Interfaces
  virtual modem_monitor_bfm mon_bfm;
  virtual modem_driver_bfm  drv_bfm;
   int active = 1;

   function new(string name = "modem_config");
      super.new(name);
   endfunction
endclass: modem_config


//-- sequence item --
class modem_seq_item extends uvm_sequence_item;
  rand logic[5:0] modem_bits;

  constraint clamp_top_bits {modem_bits[5:4] == 0;}

  `uvm_object_utils_begin(modem_seq_item)
    `uvm_field_int(modem_bits, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "modem_seq_item",
               uvm_sequencer_base sequencer = null,
               uvm_sequence #(modem_seq_item, modem_seq_item) parent = null);
    super.new(name); // NOTE: [super.new(name, sequencer, parent);]
  endfunction

endclass: modem_seq_item



`include "modem_driver.svh"
`include "modem_sequencer.svh"
`include "modem_basic_sequence.svh"
`include "modem_monitor.svh"
`include "modem_coverage_monitor.svh"
`include "modem_agent.svh"


endpackage: modem_agent_pkg
