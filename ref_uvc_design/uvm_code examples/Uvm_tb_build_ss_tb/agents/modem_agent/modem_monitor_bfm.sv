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
 //
interface modem_monitor_bfm (
  // modem signals
  input logic rts_pad_o,
  input logic cts_pad_i,
  input logic dtr_pad_o,
  input logic dsr_pad_i,
  input logic ri_pad_i,
  input logic dcd_pad_i
);

  import modem_agent_pkg::*;
  //------------------------------------------
  // Data Members
  //------------------------------------------
  modem_monitor proxy;
  
  //------------------------------------------
  // Component Members
  //------------------------------------------

  //------------------------------------------
  // Methods
  //------------------------------------------

  // BFM Methods:

  task run();
  modem_seq_item t;

  t = new("Modem analysis transaction");
  forever
    begin
      @ (rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i)
      t.modem_bits[5] = rts_pad_o;
      t.modem_bits[4] = cts_pad_i;
      t.modem_bits[3] = dtr_pad_o;
      t.modem_bits[2] = dsr_pad_i;
      t.modem_bits[1] = ri_pad_i;
      t.modem_bits[0] = dcd_pad_i;
      proxy.notify_transaction(t);
    end
  endtask : run

endinterface: modem_monitor_bfm



