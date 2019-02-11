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

import alu_agent_pkg::*;

module alu_rtl(
  input  shortint unsigned val1, val2,
  input  bit clk,
  input  bit valid_i,
  input  op_type_t mode,
  ref logic[31:0] txn_id,
  output bit valid_o,
  output shortint unsigned result
  );
                  
 always @ (posedge clk)
  if(valid_i) begin
   case(mode)
    ADD: result <= #5 val1 + val2;
    SUB: result <= #5 val1 - val2;
    MUL: result <= #5 val1 * val2;
    DIV: result <= #5 val1 / val2;
   endcase
   valid_o <= #5 1; // valid output
  end
  else 
    valid_o <= #5 0; //not valid output
endmodule

