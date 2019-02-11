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
// This class implements a pipelined driver
//
class mbus_pipelined_driver extends uvm_driver #(mbus_seq_item);

`uvm_component_utils(mbus_pipelined_driver)

local virtual mbus_pipelined_driver_bfm m_bfm;

local mbus_seq_item pipeline [$];

function new(string name = "mbus_pipelined_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void set_bfm(virtual mbus_pipelined_driver_bfm bfm);
  m_bfm = bfm;
  m_bfm.proxy = this;
endfunction: set_bfm

//
// The run_phase(uvm_phase phase);
//
//
task run_phase(uvm_phase phase);
  m_bfm.wait_for_reset();

  do_pipelined_transfers();
endtask

task do_pipelined_transfers();
  mbus_seq_item req;

  forever begin
    seq_item_port.get(req);
    accept_tr(req, $time);
    void'(begin_tr(req, "pipelined_driver"));

    // This blocking call performs the cmd phase of the request and then returns
    // right away before completing the data phase, thus allowing the cmd phase of 
    // the subsequent request (next loop iteration) to occur in parallel with the 
    // data phase of the current request, and so implementing the pipeline
    m_bfm.begin_transfer(req);
    pipeline.push_back(req);
  end
endtask: do_pipelined_transfers

// Function to complete the sequence item - driver handshake back to the sequence 
// item, decoupled from the point of the originating request
function void end_transfer(mbus_seq_item req);
  mbus_seq_item rsp = pipeline.pop_front();
  rsp.copy(req);
  //seq_item_port.put(rsp); // End of req item
  //put_response is a function instead of task:
  seq_item_port.put_response(rsp); // End of req item
  end_tr(rsp);
endfunction: end_transfer

endclass: mbus_pipelined_driver
