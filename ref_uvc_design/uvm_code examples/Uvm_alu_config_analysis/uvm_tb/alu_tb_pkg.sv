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
package alu_tb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import alu_agent_pkg::*;

`include "alu_tlm.svh"
`include "comparator_ooo_imps.svh"
`include "analysis_group_base.svh"
`include "scoreboard_ooo_imps.svh"
`include "alu_env.svh"

`include "main_stim_seq.svh"
`include "init_seq.svh"
`include "cleanup_seq.svh"
`include "main_seq.svh"

`include "alu_test_base.svh"
`include "alu_seq_test_base.svh"
`include "test_all_parallel.svh"

endpackage
