//------------------------------------------------------------
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
//------------------------------------------------------------

class alu_fc_monitor extends uvm_subscriber#(alu_txn);
`uvm_component_utils(alu_fc_monitor)

 alu_txn result_txn;
 int txn_cnt;
    
 covergroup p_cg_add;
  add_vals: coverpoint result_txn.result
   iff (result_txn.mode == ADD) {
   option.at_least = 2;
   bins l_res_bin = {[0:50]};
   bins h_res_bin = {[450:510]};
   bins rest = {[51:449]} ;
   bins others = default;
  }
 endgroup
 
 covergroup p_cg_sub;
  sub_vals: coverpoint result_txn.result 
  iff (result_txn.mode == SUB){
   option.at_least = 2;
   bins l_res_bin = {[0:15]};
   bins h_res_bin = {[150:510]};
   bins rest = {[16:149]} ;
   bins others = default;
  }
 endgroup

 covergroup p_cg_mul;
  mul_vals: coverpoint result_txn.result
  iff (result_txn.mode == MUL) {
   option.at_least = 2;
   bins l_res_bin = {[0:50]};
   bins h_res_bin = {[450:510]};
   bins rest = {[51:449]} ;
   bins others = default;
  }
 endgroup
 
 covergroup p_cg_div;
  div_vals: coverpoint result_txn.result
  iff (result_txn.mode == DIV){
   option.at_least = 2;
   bins l_res_bin = {[0:25]};
   bins h_res_bin = {[100:510]};
   bins rest = {[26:99]} ;
   bins others = default;
  }
 endgroup

 function new( string name = "alu_fc_monitor", uvm_component parent = null) ;
   super.new( name , parent );
   p_cg_add = new();
   p_cg_sub = new();
   p_cg_mul = new();
   p_cg_div = new();
 endfunction

  virtual function void write(alu_txn t);
   real  cov_result;
   txn_cnt++;
    result_txn = t;
   case(t.mode)
    ADD:  begin
      p_cg_add.sample();
      cov_result = p_cg_add.get_coverage();
      chk_cov(t.mode,cov_result);
     end
    SUB:  begin
      p_cg_sub.sample();
      cov_result = p_cg_sub.get_coverage();
      chk_cov(t.mode,cov_result);
     end
    MUL:  begin
      p_cg_mul.sample();
      cov_result = p_cg_mul.get_coverage();
      chk_cov(t.mode,cov_result);
     end
    DIV:  begin
      p_cg_div.sample();
      cov_result = p_cg_div.get_coverage();
      chk_cov(t.mode,cov_result);
     end
    endcase

 endfunction

 virtual function void chk_cov(input op_type_t mode, real cov_result);
  string s1,s2;
  $sformat(s1,"%0d alu_txns,\n     Current coverage %s = %f%%",txn_cnt, mode.name(), cov_result);
  if(cov_result == 100) begin
   done[mode] = 1; //set current mode as done
   $display("Mode = %b",done);
   $sformat(s1,"\n*********************************************");
   $sformat(s2,"\n  100%% coverage of %0s acheived", mode.name());
   `uvm_info("cov_msg", {s1,s2,s1}, UVM_LOW)                  
  end
  else 
   `uvm_info("cov_msg", s1, UVM_LOW);
 endfunction
endclass


