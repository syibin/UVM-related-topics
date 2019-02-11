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

 // Simplistic Modem Driver
 //
 //
interface modem_driver_bfm (
  // modem signals
  input  logic rts_pad_o,
  output logic cts_pad_i,
  input  logic dtr_pad_o,
  output logic dsr_pad_i,
  output logic ri_pad_i,
  output logic dcd_pad_i
);

  import modem_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
  
//------------------------------------------
// Methods
//------------------------------------------

task drive(modem_seq_item req);
  cts_pad_i    = req.modem_bits[4];
  dsr_pad_i    = req.modem_bits[2];
  ri_pad_i     = req.modem_bits[1];
  dcd_pad_i    = req.modem_bits[0];
endtask : drive

endinterface: modem_driver_bfm
