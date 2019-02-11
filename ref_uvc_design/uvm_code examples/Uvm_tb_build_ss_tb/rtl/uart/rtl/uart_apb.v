//------------------------------------------------------------
//   Copyright 2010 Mentor Graphics Corporation
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

// APB Interface - Fakes various WB signals
//
//

`include "timescale.v"

module uart_apb(input PCLK,
                input PRESETn,
                input PSEL,
                input PWRITE,
                input PENABLE,
                output logic PREADY,
                output logic we_o,
                output logic re_o);
                
typedef enum {IDLE, SETUP, ACCESS} APB_STATE;

APB_STATE fsm_state;

always @(posedge PCLK)
  begin
    if (PRESETn == 0)
      begin
        we_o = 0;
        re_o = 0;
        PREADY = 0;
        fsm_state = IDLE;
      end
    else
      case (fsm_state)
        IDLE: begin
                we_o <= 0;
                re_o <= 0;
                PREADY <= 0;
                if (PSEL)
                  fsm_state <= SETUP;
              end
        SETUP: if (PSEL && PENABLE)
                 begin
                   fsm_state <= ACCESS;
                   if (PWRITE)
                     we_o <= 1;
                   else
                     re_o <= 1;
                 end
               else
                 fsm_state <= IDLE;
        ACCESS: begin
                  PREADY <= 1;
                  we_o <= 0;
                  re_o <= 0;
                  fsm_state <= IDLE;
                end
        default: fsm_state <= IDLE;
      endcase
  end
  
endmodule: uart_apb  

                  