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
//
// Package Description:
//
package pss_test_lib_pkg;

  // Standard UVM import & include:
  import uvm_pkg::*;
`include "uvm_macros.svh"

  // Any further package imports:
  import spi_env_pkg::*;
  import apb_agent_pkg::*;
  import ahb_agent_pkg::*;
  import spi_agent_pkg::*;
  import spi_test_seq_lib_pkg::*;
  import gpio_agent_pkg::*;
  import gpio_env_pkg::*;
  import gpio_test_sequence_lib_pkg::*;
  import pss_reg_pkg::*;
  import pss_env_pkg::*;
  import pss_test_seq_lib_pkg::*;
  import intr_pkg::*;

  // Includes:
`include "pss_test_base.svh"
`include "pss_test.svh"
`include "pss_gpio_outputs_test.svh"
`include "pss_spi_polling_test.svh"
`include "pss_spi_interrupt_test.svh"

endpackage: pss_test_lib_pkg
