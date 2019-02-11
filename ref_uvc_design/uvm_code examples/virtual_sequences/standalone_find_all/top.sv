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
// This example illustrates a virtual sequence that runs stand alone
// and assigns handles to the virtual sequencers which it uses
// using the top.find_all() method. It does not run on a virtual_sequencer
//

import uvm_pkg::*;
import simple_pkg::*;

`include "uvm_macros.svh"

////
// Class: sum_seq
//
// This sequence performs an arithmetic operation on the memory between
// start_address and end_adress. At the end of the sequence, the result of
// the calculation is put into the sum variable. In effect, this sequence is
// a functor for the operation sum = f( start_address , end_address ).
//
class sum_seq extends uvm_sequence #( simple_item );
 `uvm_object_utils( sum_seq );

  //
  // Variable: start_address
  //
  // This is the start address for the calculation. It is rand because it is an
  // input to the function represented by this class.
  //
  rand int unsigned start_address;
  //
  // Variable: end_address
  //
  // This is the end address for the calculation. It is rand because it is an
  // input to the function represented by this class.
  //
  rand int unsigned end_address;

  //
  // Variable: sum
  //
  // This is the result of the calculation [ the sum of all memory values in
  // [start_address,end_address) mod 100 ]. It is NOT rand because it is an
  // output from the function represented by this class.
  //
  int unsigned sum;

  constraint order { start_address < end_address; }

  //
  // Function: new
  //
  // The usual UVM constructor
  //
  function new( string name = "" );
    super.new( name );
  endfunction

  //
  // Task: body
  //
  // This task takes the inputs to the function represented by this class ( ie,
  // start_address and end_address ) and calculates its output ( in this case,
  // the single value, sum ).
  //
  task body();
    simple_item read_item;

    sum = 0;
    for( int unsigned i = start_address; i < end_address; i++ ) begin
      read_item = simple_item::type_id::create("read_item");

      start_item( read_item );
      read_item.op = BUS_R;
      read_item.addr = i;
      finish_item( read_item );

      sum = sum + read_item.data;
    end

    `uvm_info("sum report" ,
               $sformatf("sum from %0d to %0d is %0d -> %0d" ,
                         start_address , end_address , sum , sum % 100 ) ,
               UVM_MEDIUM )

    sum = sum % 100;
  endtask

endclass

//
// Class: virtual_sequence
//
// This base class gets the sequencers needed for the writer of the testbench to be able
// to easily write virtual sequences in a base class. These virtual sequences must
// call super.body() before doing anything else
//
// The names of the sequencers should reflect the terms used in the specification of the DUT.
// Since we don't actually have a DUT in this example we have chosen some fairly arbitrary names.
// The point is that that these names may diverge significantly from the ones used in the testbench's
// component hierarchy.
//
class virtual_sequence extends uvm_sequence #( uvm_sequence_item );
  `uvm_object_utils( virtual_sequence );

  //
  // Variable: control_port
  //
  // This name reflects the name of this bus interface in the specification of the DUT.
  //
  // Since we don't actually have a DUT, we have chosen an arbitrary name.
  //
  simple_sequencer control_port;

  //
  // Variable: data_in_port
  //
  // This name reflects the name of this bus interface in the specification of the DUT.
  //
  // Since we don't actually have a DUT, we have chosen an arbitrary name.
  //
  simple_sequencer data_in_port;

  //
  // Variable: data_out_port
  //
  // This name reflects the name of this bus interface in the specification of the DUT.
  //
  // Since we don't actually have a DUT, we have chosen an arbitrary name.
  //
  simple_sequencer data_out_port;

 int found_sequence = 0;
  //
  // Function: new
  //
  // The usual UVM constructor
  //
  function new( string name = "" );
    super.new( name );
  endfunction

  //
  // Task: body
  //
  // This task extract_phase(uvm_phase phase);
  //
  // It is expected that the test writer calls super.body() before doing anything else. Provided this is
  // done, the test writer has a view of the DUT consistent with the specification of that part of the DUT
  // being verified.
  //
  task body();
    uvm_component tmp[$];
    string report_id = "Virtual_sequence_base::body";

    //Find the simple sequencers in the testbench
    tmp.delete(); //Make sure the queue is empty
    uvm_top.find_all("**agent1.sequencer", tmp);
    if (tmp.size() == 0)
      `uvm_fatal(report_id, "Failed to find simple sequencer")
    else if (tmp.size() > 1)
      `uvm_fatal(report_id, "Matched too many components when looking for mem sequencer")
    else
      $cast(control_port, tmp[0]);
	  found_sequence++;
    tmp.delete(); //Make sure the queue is empty
    uvm_top.find_all("*agent2.sequencer", tmp);
    if (tmp.size() == 0)
      `uvm_fatal(report_id, "Failed to find simple sequencer")
    else if (tmp.size() > 1)
      `uvm_fatal(report_id, "Matched too many components when looking for mem sequencer")
    else
      $cast(data_in_port, tmp[0]);
	  found_sequence++;
    tmp.delete(); //Make sure the queue is empty
    uvm_top.find_all("*agent3.sequencer", tmp);
    if (tmp.size() == 0)
      `uvm_fatal(report_id, "Failed to find simple sequencer")
    else if (tmp.size() > 1)
      `uvm_fatal(report_id, "Matched too many components when looking for mem sequencer")
    else
      $cast(data_out_port, tmp[0]);
	  found_sequence++;
   endtask:body
endclass

//
// Class: chained_seq
//
// This class uses the sum_sequence three times. The outputs of the first two
// sequences are used as inputs to the third.
//
class chained_seq extends virtual_sequence;
  `uvm_object_utils( chained_seq )

  //
  // Function: new
  //
  // The usual UVM constructor
  //
  function new( string name = "" );
    super.new( name );
  endfunction

  //
  // Task: body
  //
  // The very first thing this task does is is to call super.body(). This hides the
  // retrieval of the sequence handles from the virtual sequencer.
  //
  // Then this method initializes the address range [0,100) of all three buses with
  // some random values using simple_seq.
  //
  // It then calculates one sum in the range [50,100) and another in the range [0,50) using
  // constrained randomization on the rand inputs to the sum_seq sequence. These two
  // sequences are executed in parallel in a fork / join block on different sequencers.
  //
  // After some simple min/max calculations, the results of these two sum_seqs are used as
  // the inputs to the final sum_seq calculation on a third sequencer.
  //
  task body();
    simple_seq init1 , init2 , init3;
    sum_seq sum1 , sum2 , sum3;

    super.body();


    // Initialize the three portions on the DUT in sequence

    init1 = simple_seq::type_id::create("initialization");
    init1.start( control_port , this );

    init2 = simple_seq::type_id::create("initialization");
    init2.start( data_in_port , this );

    init3 = simple_seq::type_id::create("initialization");
    init3.start( data_out_port , this );

    // kick off two sequences in parallel on different ports

    fork
      begin
        sum1 = sum_seq::type_id::create("sum1");
        if(! sum1.randomize() with { start_address >= 50; end_address < 100; } ) begin
          `uvm_error("body", "sum1 randomization failure")
        end
        sum1.start( control_port , this );
      end

      begin
        sum2 = sum_seq::type_id::create("sum2");
        if(! sum2.randomize() with { end_address < 50; } ) begin
          `uvm_error("body", "sum2 randomization failure")
        end
        sum2.start( data_in_port , this );
      end

    join

    // when both sequences have finished, kick off the third sequence on the output port.

    sum3 = sum_seq::type_id::create("sum2");

    if( sum2.sum > sum1.sum ) begin
      sum3.start_address = sum1.sum;
      sum3.end_address = sum2.sum;
    end
    else begin
      sum3.start_address = sum2.sum;
      sum3.end_address = sum1.sum;
    end

    sum3.start( data_out_port , this );
  endtask
endclass

//
// Class: env
//
// This class models an environment which has three bus agents and one virtual
// sequencer. The three agents have structural names ( agent1, agent2 and agent3 ),
// but are mapped to a spec based view of the world in the connect method.
//
// A virtual sequence written by the test writer is executed on this virtual
// sequence.
//
class env extends uvm_env;
  `uvm_component_utils( env );

  //
  // Variable: agent1
  //
  // The first simple agent
  //
  simple_agent agent1;
  //
  // Variable: agent2
  //
  // The second simple agent
  //
  simple_agent agent2;
  //
  // Variable: agent3
  //
  // The third simple agent
  //
  simple_agent agent3;


 int found_sequence ;  //
  // Function: new
  //
  // The usual UVM constructor
  //
  function new( string name , uvm_component parent = null );
    super.new( name , parent );
  endfunction

  //
  // Function: build
  //
  // Creates the three bus agents and the virtual sequencer
  //
  function void build_phase(uvm_phase phase);
    agent1 = simple_agent::type_id::create("agent1" , this );
    agent2 = simple_agent::type_id::create("agent2" , this );
    agent3 = simple_agent::type_id::create("agent3" , this );
  endfunction

  //
  // Task: run
  //
  // This task run_phase(uvm_phase phase);
  // Note the use of a null argument for the sequencer
  //
  task run_phase(uvm_phase phase);
    chained_seq vseq = chained_seq::type_id::create("virtual_sequence");

    phase.raise_objection(this, "Starting virtual sequence");
    vseq.start( null ); // null pointer, means sequence runs stand-alone

    phase.drop_objection(this, "Virtual sequence finishing");
	found_sequence = vseq.found_sequence;
  endtask

function void report_phase(uvm_phase phase);
 if(found_sequence == 3)
     `uvm_info("** UVM TEST PASSED **", "All sequences found correctly", UVM_NONE)
  else begin
     `uvm_error("** UVM TEST FAILED **", "All sequences could not be found")
  end
endfunction: report_phase
endclass

module top();
  initial
    run_test("env");
endmodule
