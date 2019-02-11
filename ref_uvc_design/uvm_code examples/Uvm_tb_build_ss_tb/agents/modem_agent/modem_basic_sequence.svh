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

class modem_basic_sequence extends uvm_sequence #(modem_seq_item, modem_seq_item);

  `uvm_object_utils(modem_basic_sequence)

  modem_seq_item req, rsp;

  function new(string name = "modem_basic_sequence_name");
    super.new(name);
  endfunction



  task body;
    forever
    begin
      req = modem_seq_item::type_id::create();
      start_item(req);
      assert(req.randomize());
      finish_item(req);
      #1us; // Delay to avoid an infinite loop
    end

  endtask

endclass: modem_basic_sequence
