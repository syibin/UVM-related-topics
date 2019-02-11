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
package mbus_pipelined_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import mbus_types_pkg::*;

`include "mbus_seq_item.svh"
`include "mbus_pipelined_agent_config.svh"
`include "mbus_pipelined_driver.svh"
`include "mbus_pipelined_sequencer.svh"
`include "mbus_pipelined_agent.svh"

// Sequences:
`include "mbus_pipelined_seq.svh"

endpackage: mbus_pipelined_agent_pkg
