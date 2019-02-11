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
class apb_slave_sequence extends uvm_sequence #(uvm_sequence_item);

// UVM Factory Registration Macro
//
`uvm_object_utils(apb_slave_sequence)

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
bit [31:0] memory [int];

//------------------------------------------
// Constraints
//------------------------------------------



//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "apb_slave_sequence");
extern task body;

endclass:apb_slave_sequence

function apb_slave_sequence::new(string name = "apb_slave_sequence");
  super.new(name);
endfunction

task apb_slave_sequence::body;
  apb_slave_agent_config m_cfg = apb_slave_agent_config::get_config(m_sequencer);
  apb_slave_setup_item req;
  apb_slave_access_item rsp;

  m_cfg.wait_for_reset();
  // Limit to 60 iterations
  repeat(60) begin

    req = apb_slave_setup_item::type_id::create("req");
    rsp = apb_slave_access_item::type_id::create("rsp");

    // Get request:
    start_item(req);
    finish_item(req);

    // Prepare memory for response:
    if (req.rw) begin
      memory[req.addr] = req.wdata;
    end
    else begin
      if(!memory.exists(req.addr)) begin
        memory[req.addr] = 32'hdeadbeef;
      end
    end

    // Send response:
    start_item(rsp);
    assert (rsp.randomize() with {rsp.rw == req.rw;
                                  if(!rsp.rw) rsp.rdata == memory[req.addr];});
    finish_item(rsp);
  end

endtask:body
