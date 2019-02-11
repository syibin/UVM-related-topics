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
package gpio_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "config_macro.svh"

`include "gpio_seq_item.svh"
`include "gpio_agent_config.svh"
`include "gpio_driver.svh"
`include "gpio_monitor.svh"
typedef uvm_sequencer#(gpio_seq_item) gpio_sequencer;
`include "gpio_agent.svh"

// Utility Sequences
`include "gpio_seq.svh"

endpackage: gpio_agent_pkg
