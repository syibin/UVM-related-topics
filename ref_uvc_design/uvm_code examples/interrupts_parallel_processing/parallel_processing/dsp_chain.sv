//
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------

// This module contains 4 blocks of memory
// and we emulate a DSP chain reading, processing and writing from
// one block to the next
//
// Interrupts are generated when a block is ready to process
//
module dsp_chain (interface intr[4],
                  interface control);

typedef enum {READY, TFER, DONE} fsm_e;

bit[31:0] mem_0 [31:0];
bit[31:0] mem_1 [31:0];
bit[31:0] mem_2 [31:0];
bit[31:0] mem_3 [31:0];
bit[31:0] mem_4 [31:0];

fsm_e state_0, state_1, state_2, state_3;

int i_0, i_1, i_2, i_3;
int delay_0, delay_1, delay_2, delay_3;

// Process mem_0
always @(posedge control.clk)
  begin
    if(control.rst) begin
      state_0 <= READY;
      intr[0].irq <= 0;
      for(int i = 0; i < 32; i++) begin
        mem_0[i] <= i;
      end
    end
    else begin
      case(state_0)
        READY: if(control.go_0) begin
                 state_0 <= TFER;
                 i_0 <= 0;
               end
        TFER:  if(i_0 < 32) begin
                 if(delay_0 < 4) begin
                   delay_0 <= delay_0 + 1;
                 end
                 else begin
                   mem_1[i_0] <= mem_0[i_0] + 1;
                   delay_0 <= 0;
                   i_0 <= i_0 + 1;
                 end
               end
               else begin
                 intr[0].irq <= 1;
                 state_0 <= DONE;
               end
        DONE: begin
                intr[0].irq <= 0;
                state_0 <= READY;
                for(int i = 0; i < 32; i++) begin
                  mem_0[i] <= mem_0[i] + 1;
                end
              end
     endcase
   end
 end

// Process mem_1
always @(posedge control.clk)
  begin
    if(control.rst) begin
      state_1 <= READY;
      intr[1].irq <= 0;
      for(int i = 0; i < 32; i++) begin
        mem_1[i] <= 0;
      end
    end
    else begin
      case(state_1)
        READY: if(control.go_1) begin
                 state_1 <= TFER;
                 i_1 <= 0;
               end
        TFER:  if(i_1 < 32) begin
                 if(delay_1 < 2) begin
                   delay_1 <= delay_1 + 1;
                 end
                 else begin
                   mem_2[i_1] <= mem_1[i_1] + 1;
                   delay_1 <= 0;
                   i_1 <= i_1 + 1;
                 end
               end
               else begin
                 intr[1].irq <= 1;
                 state_1 <= DONE;
               end
        DONE: begin
                intr[1].irq <= 0;
                state_1 <= READY;
                for(int i = 0; i < 32; i++) begin
                  mem_1[i] <= 0;
                end
              end
     endcase
   end
 end

// Process mem_2
always @(posedge control.clk)
  begin
    if(control.rst) begin
      state_2 <= READY;
      intr[2].irq <= 0;
      for(int i = 0; i < 32; i++) begin
        mem_2[i] <= 0;
      end
    end
    else begin
      case(state_2)
        READY: if(control.go_2) begin
                 state_2 <= TFER;
                 i_2 <= 0;
               end
        TFER:  if(i_2 < 32) begin
                 if(delay_2 < 5) begin
                   delay_2 <= delay_2 + 1;
                 end
                 else begin
                   mem_3[i_2] <= mem_2[i_2] + 3;
                   delay_2 <= 0;
                   i_2 <= i_2 + 1;
                 end
               end
               else begin
                 intr[2].irq <= 1;
                 state_2 <= DONE;
               end
        DONE: begin
                intr[2].irq <= 0;
                state_2 <= READY;
                for(int i = 0; i < 32; i++) begin
                  mem_2[i] <= 0;
                end
              end
     endcase
   end
 end

 // Process mem_3
 always @(posedge control.clk)
   begin
     if(control.rst) begin
       state_3 <= READY;
       intr[3].irq <= 0;
       for(int i = 0; i < 32; i++) begin
         mem_3[i] <= 0;
       end
     end
     else begin
       case(state_3)
         READY: if(control.go_3) begin
                  state_3 <= TFER;
                  i_3 <= 0;
                end
         TFER:  if(i_3 < 32) begin
                  if(delay_3 < 2) begin
                    delay_3 <= delay_3 + 1;
                  end
                  else begin
                    mem_4[i_3] <= mem_3[i_3] + 1;
                    delay_3 <= 0;
                    i_3 <= i_3 + 1;
                  end
                end
                else begin
                  intr[3].irq <= 1;
                  state_3 <= DONE;
                end
         DONE: begin
                 intr[3].irq <= 0;
                 state_3 <= READY;
                 for(int i = 0; i < 32; i++) begin
                   $display("Final content => location %0d value: %0h", i, mem_4[i]);
                 end
               end
      endcase
    end
 end


endmodule: dsp_chain
