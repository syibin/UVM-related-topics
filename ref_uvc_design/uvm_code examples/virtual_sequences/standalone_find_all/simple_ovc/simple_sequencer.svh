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

  // CLASS: simple_sequencer
  // A simple sequencer.
  class simple_sequencer extends uvm_sequencer #(simple_item);
    `uvm_sequencer_utils(simple_sequencer)

    function new (string name, uvm_component parent);
      super.new(name, parent);
      count = 0;
    endfunction : new

  endclass : simple_sequencer

