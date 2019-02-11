//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
class sfr_test_seq extends uvm_sequence #(sfr_seq_item);

`uvm_object_utils(sfr_test_seq)

function new(string name = "sfr_test_seq");
  super.new(name);
endfunction

task body;
  sfr_seq_item item = sfr_seq_item::type_id::create("item");

  repeat(2048) begin
    start_item(item);
    assert(item.randomize() with {address inside {[0:32'h1000]};});
    finish_item(item);
  end

endtask: body

endclass: sfr_test_seq


