//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//
// This pkgs contains the "a_agent" which is agent that converts
// sequence_items into messages
//
package a_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class a_seq_item extends uvm_sequence_item;

`uvm_object_utils(a_seq_item)

function new(string name = "a_seq_item");
  super.new(name);
endfunction

rand int a; // No need for the various methods?
string s;

endclass: a_seq_item

class a_sequencer extends uvm_sequencer #(a_seq_item);

`uvm_component_utils(a_sequencer)

function new(string name = "a_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: a_sequencer

class a_driver extends uvm_driver #(a_seq_item);

`uvm_component_utils(a_driver)

integer sucessful_Override = 0;
function new(string name = "a_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);

a_seq_item req;

forever begin
  seq_item_port.get_next_item(req);
  #10;
  req.a = req.a + 1;
  `uvm_info("RUN:", $sformatf("Heartbeat:%s", req.s), UVM_LOW);
  if(req.s != "C_SEQ") 
      `uvm_error("run", "Sequence override not sucessful")
  else 
	  sucessful_Override++;
  seq_item_port.item_done();
end

endtask: run_phase

function void report_phase(uvm_phase phase);
 if(sucessful_Override == 3)
     `uvm_info("** UVM TEST PASSED **", "All Overrides done correctly", UVM_NONE)
  else begin
     `uvm_error("** UVM TEST FAILED **", "Incorrect override detected")
  end
endfunction: report_phase


endclass: a_driver

class a_agent extends uvm_component;

`uvm_component_utils(a_agent)

a_sequencer m_sequencer;
a_driver m_driver;

function new(string name = "a_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  m_driver = a_driver::type_id::create("m_driver", this);
  m_sequencer = a_sequencer::type_id::create("m_sequencer", this);
endfunction: build_phase

function void connect_phase(uvm_phase phase);
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
endfunction: connect_phase

endclass: a_agent

class a_seq extends uvm_sequence #(a_seq_item);
`uvm_object_utils(a_seq)

rand int no_as=1;
string s = "A_SEQ";

function new(string name = "a_seq");
  super.new(name);
endfunction

task body;
  a_seq_item item;

  item = a_seq_item::type_id::create("item");
  item.s = s;
  repeat(no_as) begin
    start_item(item);
    if(!item.randomize()) begin
      `uvm_error("body", "item randomization failure")
    end
    finish_item(item);
  end
endtask: body

endclass: a_seq

class b_seq extends a_seq;
`uvm_object_utils(b_seq)

function new(string name = "b_seq");
  super.new(name);
  s="B_SEQ";
endfunction

task body;
  super.body();
endtask: body

endclass: b_seq

class c_seq extends b_seq;
`uvm_object_utils(c_seq)

function new(string name = "c_seq");
  super.new(name);
  s="C_SEQ";
endfunction

task body;
  super.body();
endtask: body

endclass: c_seq

endpackage: a_agent_pkg
