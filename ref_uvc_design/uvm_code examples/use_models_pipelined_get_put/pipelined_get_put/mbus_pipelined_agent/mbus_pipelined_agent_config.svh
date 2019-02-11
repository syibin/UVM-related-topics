//
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
class mbus_pipelined_agent_config extends uvm_object;

// Virtual interface
virtual mbus_pipelined_driver_bfm driver_bfm;

// Active or passive
uvm_active_passive_enum is_active = UVM_ACTIVE;

`uvm_object_utils(mbus_pipelined_agent_config)

function new(string name = "mbus_pipelined_agent_config");
  super.new(name);
endfunction

endclass: mbus_pipelined_agent_config
