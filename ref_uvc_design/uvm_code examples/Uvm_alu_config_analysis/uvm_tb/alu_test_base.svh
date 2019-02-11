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

`ifndef ALU_TEST_BASE
`define ALU_TEST_BASE

class alu_test_base extends uvm_test;
 `uvm_component_utils(alu_test_base)
  // base environment
  alu_env t_env;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  //Be sure to call super.build_phase(phase)
  function void build_phase(uvm_phase phase);
    t_env = alu_env::type_id::create("t_env", this);
  endfunction

endclass

`endif
