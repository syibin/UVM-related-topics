//------------------------------------------------------------
//   Copyright 2011-2018 Mentor Graphics Corporation
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

package agent_b_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class b_seq_item extends uvm_sequence_item;

`uvm_object_utils(b_seq_item)

rand int number;

function new(string name = "b_seq_item");
  super.new(name);
endfunction

endclass: b_seq_item

class b_driver extends uvm_driver #(b_seq_item);

`uvm_component_utils(b_driver)

int i;

function new(string name = "b_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  b_seq_item t;
  i = 0;

  forever begin
    seq_item_port.get(t);
    `uvm_info("B_DRIVER", $sformatf("Received transaction %0d with value %0d", i, t.number), UVM_LOW)
    i++;
  end
endtask: run_phase

endclass: b_driver

class b_agent extends uvm_component;

`uvm_component_utils(b_agent)

b_driver m_driver;
uvm_sequencer #(b_seq_item) m_sequencer;

function new(string name = "b_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_driver = b_driver::type_id::create("m_driver", this);
  m_sequencer = uvm_sequencer #(b_seq_item)::type_id::create("m_sequencer", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
endfunction: connect_phase

endclass: b_agent

class b_seq extends uvm_sequence #(b_seq_item);

`uvm_object_utils(b_seq)

function new(string name = "b_seq");
  super.new(name);
endfunction

task body;
  b_seq_item item = b_seq_item::type_id::create("item");

  repeat(10) begin
    start_item(item);
    assert(item.randomize());
    finish_item(item);
  end

endtask: body

endclass: b_seq

endpackage: agent_b_pkg
