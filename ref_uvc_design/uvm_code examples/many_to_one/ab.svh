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
// CLASS: AtoB_seq
//
// many-to-1 - it takes N A items to make one B item
//
//---------------------------------------------------------------------------

class AtoB_seq extends uvm_sequence #(B_item);
  `uvm_object_utils(AtoB_seq);

  function new(string name="");
    super.new(name);
  endfunction

  uvm_sequencer #(A_item) up_sequencer;

  virtual task do_item(B_item b);
    A_item a;
    start_item(b);
    void'(b.randomize());
     b.fb.push_back(b.burst_len);
    repeat(b.burst_len-1) begin
      up_sequencer.get_next_item(a);
       b.fb.push_back(a.fa);
       if(a.fa == 8'hFF) begin
    b.burst_len = b.fb.size - 1;
    b.fb[0] = b.burst_len;
    $display("%s",b.convert2string());

    break;
       end
       up_sequencer.item_done();
    end
     if(a.fa != 8'hFF) begin
  up_sequencer.get_next_item(a);
  b.fb.push_back(a.fa);
     end
    `uvm_info(get_name(),{"Executing Burst ",b.convert2string()},UVM_MEDIUM)
    finish_item(b);
    up_sequencer.item_done();
  endtask

  task body();
    A_item a;
    B_item b;

    byte buffer[$];
    int b_item_number = 0;
    int a_count = 0;

    forever begin
      up_sequencer.get_next_item( a );

      if( a.fa != 8'hff ) begin
        buffer.push_back( a.fa );
        a_count++;

        assert( buffer.size() == a_count );
      end
      else begin
        b = B_item::type_id::create($psprintf("B_item%0d ",++b_item_number),,get_full_name());

        start_item( b );
        b.fb = { a_count , buffer };
        b.burst_len = a_count;

        assert( b.fb.size() == a_count + 1 );

        `uvm_info("Executing" , b.convert2string() , UVM_MEDIUM );
        finish_item( b );

        buffer = {};
        a_count = 0;
      end

     up_sequencer.item_done();
    end
  endtask
endclass


//---------------------------------------------------------------------------
//
// Class: B2A_monitor
//
// one-to-many : one B item results in N A items
//
//---------------------------------------------------------------------------

class B2A_monitor extends uvm_subscriber #(B_item);
  `uvm_component_utils(B2A_monitor)

  A_item a_out;
  int c_count   = 0;
  int b_count   = 0;
  int b_lencnt  = 0;

  uvm_analysis_port#(A_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap",this);
  endfunction

  virtual function void write(B_item t);
    `uvm_info( "Recieved B_item", t.convert2string(),UVM_MEDIUM)
    for( int i = 1; i <= t.burst_len; i++ ) begin
      a_out = A_item::type_id::create($psprintf("A item %0d" , i ) );
      a_out.fa = t.fb[i];
      `uvm_info( "Writing A_item", a_out.convert2string(),UVM_MEDIUM)
      ap.write(a_out);
    end

    a_out = A_item::type_id::create("A Terminator");
    a_out.fa = 8'hff;
    `uvm_info( "Writing A_item", a_out.convert2string(),UVM_MEDIUM)
    ap.write(a_out);
  endfunction

endclass

