//------------------------------------------------------------
//   Copyright 2007-2018 Mentor Graphics Corporation
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
  // CLASS: simple_seq
  //
  // Write random data to the first 100 memory locations
  // Read them back and check the data
  //
  class simple_seq extends uvm_sequence#(simple_item);
    `uvm_sequence_utils(simple_seq, simple_sequencer)
    simple_item write_item , read_item;

    function new(string name="simple_sequence");
      super.new(name);
    endfunction

    virtual task body();
      for (int i = 0; i < 100; i++) begin
        write_item = simple_item::type_id::create("write_item");
        read_item = simple_item::type_id::create("read_item");

        // Write ---------------------------------
        start_item(write_item);

        if(! write_item.randomize() with
                { write_item.op == BUS_W; write_item.addr == i; } ) begin
           `uvm_error("body", "write item randomization failed")
        end
        finish_item(write_item);

        // Read ----------------------------------
        start_item(read_item);

        read_item.addr = write_item.addr;
        read_item.op = BUS_R;

        finish_item(read_item);

        // Compare -------------------------------
        if (read_item.data != write_item.data) begin
          `uvm_error("simple_seq",
                      $sformatf("[%0x] Data mismatch. Wrote '%0x', Read '%0x'",
            write_item.addr,
            write_item.data , read_item.data))
        end
      end
    endtask
  endclass : simple_seq
