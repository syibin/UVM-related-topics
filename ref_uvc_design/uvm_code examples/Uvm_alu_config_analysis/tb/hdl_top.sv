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

// hdl_top level module for rtl alu
module hdl_top();

import alu_agent_pkg::*;

wire [15:0] val1;
wire[15:0] val2;
wire valid_i;
wire valid_o;
op_type_t mode;
shortint unsigned result;
wire[31:0] txn_id;


  // generate the clock
  bit clk = 0;
  initial
   forever #50 clk = !clk;


  // alu_if pin instance
//  alu_if a_if(.clk(clk));

  //BFM Interfaces
  alu_monitor_bfm alu_mon_bfm(
                              .val1(val1),
                              .val2(val2),
                              .mode(mode),
                              .txn_id(txn_id),
                              .clk(clk),
                              .valid_i(valid_i),
                              .valid_o(valid_o),
                              .result(result)
                             );
                             
  alu_driver_bfm  alu_drv_bfm(
                              .val1(val1),
                              .val2(val2),
                              .mode(mode),
                              .txn_id(txn_id),
                              .clk(clk),
                              .valid_i(valid_i),
                              .valid_o(valid_o),
                              .result(result)
                              );

  // DUT instance
  alu_rtl alu (
               .val1(val1),
               .val2(val2),
               .mode(mode),
               .txn_id(txn_id),
               .clk(clk),
               .valid_i(valid_i),
               .valid_o(valid_o),
               .result(result)
               );

 initial begin //tbx vif_binding_block
  import uvm_pkg::uvm_config_db;
     // set virtual interfaces
   uvm_config_db #(virtual alu_monitor_bfm)::set(null, "uvm_test_top", "alu_mon_bfm", alu_mon_bfm);
   uvm_config_db #(virtual alu_driver_bfm) ::set(null, "uvm_test_top", "alu_drv_bfm", alu_drv_bfm);
 end
  
endmodule : hdl_top
