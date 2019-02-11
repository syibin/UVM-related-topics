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


package alu_agent_pkg;

import uvm_pkg::*;

`include "uvm_macros.svh"

  // definitions for alu_txn
  typedef enum {ADD, SUB, MUL, DIV} op_type_t;
  op_type_t current_mode;
  bit [3:0] done;

 `include "alu_agent_config.svh"
 `include "alu_txn.svh" 
 `include "alu_seq.svh"
 `include "alu_driver.svh"
 `include "alu_monitor.svh"
 `include "alu_fc_monitor.svh"
 `include "alu_agent.svh"

endpackage
