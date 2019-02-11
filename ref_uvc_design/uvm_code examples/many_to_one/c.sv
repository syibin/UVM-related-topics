//----------------------------------------------------------------------
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
//----------------------------------------------------------------------

`include "uvm_macros.svh"

package c_pkg;

import uvm_pkg::*;


//---------------------------------------------------------------------------
//
// CLASS: C_item
//
//---------------------------------------------------------------------------

class C_item extends uvm_sequence_item;
  `uvm_object_utils(C_item)

  function new(string name="");
    super.new(name);
  endfunction

  rand byte fc;

  virtual function string convert2string();
    return $psprintf("fc=%2h",fc);
  endfunction
endclass



// Define the C agent: driver, sequencer, and monitor

//---------------------------------------------------------------------------
//
// CLASS: C_driver
//
//---------------------------------------------------------------------------

class C_driver extends uvm_driver #(C_item);

  `uvm_component_utils(C_driver)

  uvm_analysis_port #(C_item) ap; //Pretend to be a monitor

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction // new

   virtual function void build_phase(uvm_phase phase);
      ap = new("ap",this);
   endfunction

  virtual task run_phase(uvm_phase phase);
    C_item c;

    forever begin
      seq_item_port.get_next_item(c);
      `uvm_info("DRIVER RECEIVED ITEM",c.convert2string(),UVM_MEDIUM)
      #10;
      seq_item_port.item_done();
      #10;
      ap.write(c);
    end
  endtask

endclass


//---------------------------------------------------------------------------
//
// CLASS: C_sequencer
//
//---------------------------------------------------------------------------

typedef uvm_sequencer#(C_item) C_sequencer;


//---------------------------------------------------------------------------
//
// CLASS: C_agent
//
//---------------------------------------------------------------------------


class C_agent extends uvm_agent;

  `uvm_component_utils(C_agent)

  C_sequencer c_sequencer;
  C_driver    c_driver;
  //C_monitor c_mntr;
  uvm_analysis_port #(C_item) ap;

  function new(string name="", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    c_sequencer = C_sequencer::type_id::create("c_sequencer",this);
    c_driver = C_driver::type_id::create("c_driver",this);
    //c_mntr = C_monitor::type_id::create("c_mntr",this);
    ap = new("ap",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    c_driver.seq_item_port.connect(c_sequencer.seq_item_export);
    c_driver.ap.connect(ap);
  endfunction

endclass

endpackage

