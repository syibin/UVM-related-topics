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
// Class: BtoC_seq
//
// 1-to-many : each B item results in N C items
//
//---------------------------------------------------------------------------

class BtoC_seq extends uvm_sequence #(C_item);
  `uvm_object_utils(BtoC_seq);

  function new(string name="");
    super.new(name);
  endfunction

  uvm_sequencer #(B_item) up_sequencer;

  virtual task body();
    B_item b;
    C_item c;
    int i;
    forever begin
      up_sequencer.get_next_item(b);
      foreach (b.fb[i]) begin
        c = C_item::type_id::create($psprintf("C_item%0d",i),,get_full_name());

        start_item(c);
        c.fc = b.fb[i];
       `uvm_info(get_name(),{"Executing ",c.convert2string()},UVM_MEDIUM)
        finish_item(c);

      end
      up_sequencer.item_done();
    end
  endtask
endclass


//---------------------------------------------------------------------------
//
// Class: C2B_monitor
//
// many-to-one : N C items results in one B item
//
//---------------------------------------------------------------------------

class C2B_monitor extends uvm_subscriber #(C_item);
  `uvm_component_utils(C2B_monitor)

  uvm_analysis_port#(B_item) ap;

  B_item b_out;
  int c_count   = 0;
  int b_count   = 0;
  int b_lencnt  = 0;
  uvm_phase run_phase = uvm_run_phase::get();

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap",this);
  endfunction

  function void write(C_item t);
    `uvm_info("Debug" , t.convert2string() , UVM_MEDIUM )

    if(c_count == 0) begin // beginning of a new b
      b_out = B_item::type_id::create($psprintf("B_item%0d ",++b_count),,
              get_full_name());
      c_count = t.fc;
      b_out.fb.push_back( t.fc );
      b_out.burst_len = t.fc;

    end

    else begin
      assert( b_out != null );
      b_out.fb.push_back( t.fc);

      `uvm_info("Debug" , b_out.convert2string() , UVM_MEDIUM )
      `uvm_info("Debug" , $psprintf("b_lencnt, c_count = %x,%x" , b_lencnt + 1 , c_count ) , UVM_MEDIUM )

      if(++b_lencnt == c_count) begin // end of existing b
        `uvm_info("Writing B Burst", b_out.convert2string(),UVM_MEDIUM)
        ap.write( b_out );

  c_count = 0;
  b_lencnt = 0;
      end
    end
  endfunction

endclass





