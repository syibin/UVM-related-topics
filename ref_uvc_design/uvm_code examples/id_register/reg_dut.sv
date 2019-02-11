// ----------------------------------------------------------
// Copyright 2018 Mentor Graphics Corporation
// All Rights Reserved Worldwide
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ----------------------------------------------------------
module reg_dut (input PCLK,
                input PRESETn,
                input[31:0] PADDR,
                input[31:0] PWDATA,
                input PWRITE,
                input PSEL,
                input PENABLE,
                output logic[31:0] PRDATA,
                output logic PREADY);

assign PREADY = PSEL & PENABLE;

`define ID 32'h0
`define R_W 32'h100

logic[31:0] R_reg = 32'h00FF0000;
logic[31:0] W_reg = 32'h00CCCAA0;

int id_register_pointer;
int id_register_pointer_max;
int id_register_value[] = '{'ha0, 'ha1, 'ha2, 'ha3, 'ha4,
                            'ha5, 'ha6, 'ha7, 'ha8, 'ha9};

int current_value;

always @(posedge PCLK) begin
  if(PRESETn == 0) begin
    id_register_pointer <= 0;
    id_register_value <= '{'ha0, 'ha1, 'ha2, 'ha3, 'ha4,
                           'ha5, 'ha6, 'ha7, 'ha8, 'ha9};
    current_value <= 32'ha0;
  end
  else begin
    if(PSEL & PENABLE) begin
      if(PWRITE) begin
        case(PADDR)
          `ID : begin
                  if(PWDATA < 10) begin
                    id_register_pointer <= PWDATA[3:0];
                  end
                  else begin
                    id_register_pointer <= 0;
                  end
                end
          `R_W : W_reg <= PWDATA;
        endcase
      end
      else begin
        if(PADDR == `ID)begin
          if(id_register_pointer == 9) begin
            id_register_pointer <= 0;
          end
          else begin
            id_register_pointer <= id_register_pointer + 1;
          end
        end
      end
    end
    if(~PENABLE) begin
      current_value <= id_register_value[id_register_pointer];
    end
  end
end

always @(*) begin
  if(PSEL) begin
    case(PADDR)
      `ID: PRDATA = current_value;
      `R_W: PRDATA = R_reg;
      default: PRDATA = 0;
    endcase
  end
  else begin
    PRDATA = 0;
  end
end

endmodule



