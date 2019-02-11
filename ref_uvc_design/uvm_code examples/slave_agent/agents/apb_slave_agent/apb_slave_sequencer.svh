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
`ifndef apb_slave_sequencer
`define apb_slave_sequencer

//
// Class Description:
//
//
class apb_slave_sequencer extends uvm_sequencer #(apb_slave_seq_item, apb_slave_seq_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(apb_slave_sequencer)

// Standard UVM Methods:
extern function new(string name="apb_slave_sequencer", uvm_component parent = null);

endclass: apb_slave_sequencer

function apb_slave_sequencer::new(string name="apb_slave_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

`endif // apb_slave_sequencer
