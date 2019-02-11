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
class item_listener extends uvm_subscriber #( apb_slave_seq_item );

  `uvm_component_utils( item_listener );

  int transfers;

  function new( string name , uvm_component parent );
    super.new( name , parent );
  endfunction

  function void write( input apb_slave_seq_item t );
    transfers++;
  endfunction

  function void report_phase(uvm_phase phase);
    if(transfers == 60) begin
      `uvm_info("** UVM TEST PASSED **", "Correct number of transfers occured before timeout", UVM_LOW)
    end
    else begin
      `uvm_error("** UVM TEST FAILED **", "Too few transfers occured before the timeout")
    end
  endfunction: report_phase

endclass
