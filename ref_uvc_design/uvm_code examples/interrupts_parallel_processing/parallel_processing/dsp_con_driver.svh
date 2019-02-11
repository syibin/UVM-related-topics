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

class dsp_con_driver extends uvm_driver #(dsp_con_seq_item);

`uvm_component_utils(dsp_con_driver)

virtual dsp_con_driver_bfm bfm;

function new(string name = "dsp_con_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

task run_phase(uvm_phase phase);
  dsp_con_seq_item req;

  // Wait for reset to complete
  bfm.wait_for_reset();

  forever begin
    // Get the next item and sync to posedge of clock
    seq_item_port.get_next_item(req);
    bfm.drive(req);
    seq_item_port.item_done();
  end
endtask: run_phase

endclass: dsp_con_driver
