//------------------------------------------------------------
//   Copyright 2013 Mentor Graphics Corporation
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
// This is a model of a biquad filter.
//
// It contains a 24 bit register interface for the biquad co-efficients
// and this is accessed via an APB interface.
//
// The implementation of the filter uses reals rather than fixed point
// for simplicity
//
module biquad (// APB Interface
               input PCLK,
               input PRESETn,
               input PSEL,
               input PENABLE,
               input[31:0] PADDR,
               input[31:0] PWDATA,
               output logic[31:0] PRDATA,
               input PWRITE,
               output logic PREADY,
               output logic PSLVERR,
               // Filter clock
               input FCLK,
               // Filter input and output
               input real x,
               output real yout);

// Fixed Point co-efficients:
logic[23:0] a11_fp;
logic[23:0] a12_fp;
logic[23:0] b10_fp;
logic[23:0] b11_fp;
logic[23:0] b12_fp;

// Filter variables:
real b10;
real b11;
real b12;
real a11;
real a12;

real z_1;
real z_2;
real s_1;


// APB register interface:
//
// Write path
always @(posedge PCLK or negedge PRESETn) begin
  if(PRESETn == 0) begin
    a11_fp <= 0;
    a12_fp <= 0;
    b10_fp <= 0;
    b11_fp <= 0;
    b12_fp <= 0;
  end
  else begin
    if((PWRITE == 1) && (PSEL == 1) && (PENABLE == 1)) begin
      case (PADDR[4:0])
        5'b00000: a11_fp <= PWDATA[23:0];
        5'b00100: a12_fp <= PWDATA[23:0];
        5'b01000: b10_fp <= PWDATA[23:0];
        5'b01100: b11_fp <= PWDATA[23:0];
        5'b10000: b12_fp <= PWDATA[23:0];
      endcase
    end
  end
end
// Read path - always active
always_comb
  if((PSEL == 1) && (PENABLE == 1)) begin
    PREADY = 1;
    PSLVERR = 0;
    case (PADDR[4:0])
      5'b00000: PRDATA = {8'h0, a11_fp};
      5'b00100: PRDATA = {8'h0, a12_fp};
      5'b01000: PRDATA = {8'h0, b10_fp};
      5'b01100: PRDATA = {8'h0, b11_fp};
      5'b10000: PRDATA = {8'h0, b12_fp};
      default: begin
                 PRDATA = 0;
                 PSLVERR = 1;
               end
    endcase
  end
  else begin
    PREADY = 0;
    PRDATA = 0;
  end

// Convert the co-efficients to reals
function real to_real(bit[23:0] fp);
  real x_ph;
  integer signed m;
  real n;

  begin
    x_ph = 0;
    m = 1;
    for(int p = 22; p >= 0; p--) begin
      m = m-1;
      if(fp[p] == 1) begin
        n = 2.00000;
        n = n**m;
        x_ph = x_ph + n;
      end
    end
    if(fp[23] == 1) begin
      x_ph = x_ph*-1;
    end
  end

  return x_ph;
endfunction: to_real

assign a11 = to_real(a11_fp);
assign a12 = to_real(a12_fp);
assign b10 = to_real(b10_fp);
assign b11 = to_real(b11_fp);
assign b12 = to_real(b12_fp);


always @(posedge FCLK or negedge PRESETn) begin
  if(PRESETn == 0) begin
    z_1 <= 0;
    z_2 <= 0;
  end
  else begin
    z_1 <= s_1;
    z_2 <= z_1;
  end
end

assign s_1 = x - (a11 * z_1) - (a12 * z_2);
assign yout = (s_1 * b10) + (z_1 * b11) + (z_2 * b12);

endmodule: biquad


