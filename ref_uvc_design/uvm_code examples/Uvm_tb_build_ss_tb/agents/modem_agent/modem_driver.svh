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
class modem_driver extends uvm_driver #(modem_seq_item, modem_seq_item);

 `uvm_component_utils(modem_driver)

 local virtual modem_driver_bfm m_bfm;
 modem_config m_cfg;

 function new(string name = "modem_driver", uvm_component parent = null);
   super.new(name, parent);
 endfunction

 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   `get_config(modem_config, m_cfg, "modem_config")
   m_bfm = m_cfg.drv_bfm;
 endfunction: build_phase


 task run_phase(uvm_phase phase);

   forever
     begin
       seq_item_port.get_next_item(req);
       m_bfm.drive(req);
       seq_item_port.item_done();
     end

 endtask: run_phase

endclass: modem_driver
