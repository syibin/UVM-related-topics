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

  // CLASS: simple_agent
  // The simple agent with a sequencer and a driver.
  class simple_agent extends uvm_component;
    `uvm_component_utils( simple_agent )

    simple_sequencer sequencer;
    simple_driver driver;
 
    function new(string name, uvm_component p);
      super.new(name, p);
    endfunction
    
    function void build_phase(uvm_phase phase);
      sequencer = simple_sequencer::type_id::create("sequencer", this);
      driver = simple_driver::type_id::create("driver", this);
    endfunction
  
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect( sequencer.seq_item_export );
    endfunction
  
  endclass
