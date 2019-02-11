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


//---------------------------------------------------------------------------
//
// CLASS: ABC_layering
//
// This ABC layering class assumes that the C_agent is external to the layering.
// It owns the two layering sequencers and the two layering monitors.
//
// In a virtual sequencer like way, it has a point to the C_agent. It also has
// an analysis export for the incoming C_items and an an analysis port for the
// outgoing A_items that the layered monitor recognises from the bus.
//
//---------------------------------------------------------------------------

class ABC_layering extends uvm_subscriber #( C_item );
  `uvm_component_utils( ABC_layering )

  uvm_analysis_port #( A_item ) ap;

  A_sequencer a_sequencer;
  B_sequencer b_sequencer;

  C2B_monitor c2b_mon;
  B2A_monitor b2a_mon;

  C_agent c_agent;

  function new(string name, uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    a_sequencer = A_sequencer::type_id::create("a_sequencer",this);
    b_sequencer = B_sequencer::type_id::create("b_sequencer",this);

   c2b_mon = C2B_monitor::type_id::create("c2b_mon",this);
   b2a_mon = B2A_monitor::type_id::create("b2a_mon",this);

   ap = new("ap" , this );
  endfunction

  function void connect_phase(uvm_phase phase);
    c2b_mon.ap.connect(b2a_mon.analysis_export);
    b2a_mon.ap.connect( ap );
  endfunction

  virtual task run_phase(uvm_phase phase);
     AtoB_seq a2b_seq;
     BtoC_seq b2c_seq;

     a2b_seq = AtoB_seq::type_id::create("a2b_seq");
     b2c_seq = BtoC_seq::type_id::create("b2c_seq");

    // connect translation sequences to their respective upstream sequencers
    a2b_seq.up_sequencer = a_sequencer;
    b2c_seq.up_sequencer = b_sequencer;

    // start the translation sequences
    fork
      a2b_seq.start(b_sequencer);
      b2c_seq.start(c_agent.c_sequencer);
    join_none
  endtask

  // this method connects the incoming C_items to the c2b monitor
  function void write( C_item t );
    c2b_mon.write( t );
  endfunction

  // a convenience method to connect active and passive datapaths in one method
  function void connect_to_C_agent( C_agent c );
    c_agent = c;
    c_agent.ap.connect( analysis_export );
  endfunction

endclass

