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

module ahb_apb_bridge
  #(int NO_OF_SLAVES = 8,
    int SLAVE_START_ADDR_0 = 0,
    int SLAVE_END_ADDR_0 = 32'hFF,
    int SLAVE_START_ADDR_1 = 32'h100,
    int SLAVE_END_ADDR_1 = 32'h1FF,
    int SLAVE_START_ADDR_2 = 32'h200,
    int SLAVE_END_ADDR_2 = 32'h2FF,
    int SLAVE_START_ADDR_3 = 32'h300,
    int SLAVE_END_ADDR_3 = 32'h3FF,
    int SLAVE_START_ADDR_4 = 32'h400,
    int SLAVE_END_ADDR_4 = 32'h4FF,
    int SLAVE_START_ADDR_5 = 32'h500,
    int SLAVE_END_ADDR_5 = 32'h5FF,
    int SLAVE_START_ADDR_6 = 32'h600,
    int SLAVE_END_ADDR_6 = 32'h6FF,
    int SLAVE_START_ADDR_7 = 32'h700,
    int SLAVE_END_ADDR_7 = 32'h7FF
    )
    (
     // AHB Host side signals:
     input HCLK,
     input HRESETn,
     input[31:0] HADDR,
     input[1:0] HTRANS,
     input HWRITE,
     input[2:0] HSIZE,
     input[2:0] HBURST,
     input[3:0] HPROT,
     input[31:0] HWDATA,
     input HSEL,
     output logic[31:0] HRDATA,
     output logic HREADY,
     output logic[1:0] HRESP,
     // APB Slave side signals:
     output logic[31:0] PADDR,
     output logic[31:0] PWDATA,
     output logic PENABLE,
     output logic PWRITE,
     output logic[NO_OF_SLAVES-1:0] PSEL,
     input [31:0] PRDATA[NO_OF_SLAVES-1:0],
     input [NO_OF_SLAVES-1:0] PREADY,
     input [NO_OF_SLAVES-1:0] PSLVERR);

typedef enum {IDLE, SETUP, ACCESS} apb_state_t;

apb_state_t fsm_state;

logic[31:0] ahb_addr;
logic[31:0] ahb_wdata;
logic ahb_write;
logic[NO_OF_SLAVES-1:0] slave_select;
logic addr_error;
logic apb_ready;
logic apb_error;


// Main state machine:
//
// Relies on the pipelined nature of the AHB bus
// Does not use the burst info or size, simply transfers
// the data written on the bus to the address on the APB bus
// selecting the right slave
//
// AHB response is throttled by the APB slave response on a
// one to one basis
//
always_ff @(posedge HCLK) begin
  if(HRESETn == 0) begin
    fsm_state <= IDLE;
    PENABLE <= 0;
    PWRITE <= 0;
    PADDR <= 0;
    PSEL <= 0;
    HREADY <= 0;
    HRESP <= 0;
//    PWDATA <= 0;
  end
  else begin
    case(fsm_state)
      IDLE: begin
             PENABLE <= 0;
             PSEL <= 0;
             if(HTRANS[1] == 1) begin // Responding to a control cycle after bus idle
                HREADY <= 1;
                ahb_addr <= HADDR;
                ahb_write <= HWRITE;
                ahb_wdata <= HWDATA;
                HRESP <= 0;
                fsm_state <= SETUP;
              end
              else begin
                HREADY <= 0;
              end
            end
      SETUP: begin
               if(addr_error == 1) begin
                 HREADY <= 1;
                 HRESP <= 1;
                 fsm_state <= IDLE;
               end
               else begin
                 PADDR <= ahb_addr;
                 PWRITE <= ahb_write;
      //           PWDATA <= HWDATA;
                 PSEL <= slave_select;
                 PENABLE <= 0;
                 fsm_state <= ACCESS;
                 HREADY <= 0;
               end
             end
      ACCESS: begin
                PENABLE <= 1;
                if(apb_ready == 1) begin
                  HREADY <= 1;
                  if(apb_error == 0) begin
                    HRESP <= 0;
                  end
                  else begin
                    HRESP <= 1;
                  end
                  if(HTRANS[1] == 1) begin
                    fsm_state <= SETUP;
                    ahb_addr <= HADDR;
                    ahb_write <= HWRITE;
                    ahb_wdata <= HWDATA;
                  end
                  else begin
                    fsm_state <= IDLE;
                  end
                end
                else begin
                  HREADY <= 0;
                end
              end
    endcase
  end
end

assign PWDATA = HWDATA;

//
// Address decode for slave select:
//
always_comb
  begin
    slave_select = 0;
    addr_error = 0;
    if((ahb_addr >= SLAVE_START_ADDR_0) && (ahb_addr <= SLAVE_END_ADDR_0)) begin
      slave_select[0] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_1) && (ahb_addr <= SLAVE_END_ADDR_1) && (NO_OF_SLAVES >= 2)) begin
           slave_select[1] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_2) && (ahb_addr <= SLAVE_END_ADDR_2) && (NO_OF_SLAVES >= 3)) begin
           slave_select[2] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_3) && (ahb_addr <= SLAVE_END_ADDR_3) && (NO_OF_SLAVES >= 4)) begin
           slave_select[3] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_4) && (ahb_addr <= SLAVE_END_ADDR_4) && (NO_OF_SLAVES >= 5)) begin
           slave_select[4] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_5) && (ahb_addr <= SLAVE_END_ADDR_5) && (NO_OF_SLAVES >= 6)) begin
           slave_select[5] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_6) && (ahb_addr <= SLAVE_END_ADDR_6) && (NO_OF_SLAVES >= 7)) begin
           slave_select[6] = 1;
    end
    if((ahb_addr >= SLAVE_START_ADDR_7) && (ahb_addr <= SLAVE_END_ADDR_7) && (NO_OF_SLAVES == 8)) begin
           slave_select[7] = 1;
    end
    if(slave_select == 0) begin
      addr_error = 1;
    end
  end

// Ready only returned if the PREADY is coming back from the Selected APB slave
always_comb
  begin
    apb_ready = |(PREADY & PSEL);
  end

// Return of error bits
always_comb
  begin
    apb_error = |(PSLVERR & PSEL);
  end

// Return of read data
always @(posedge HCLK)
  begin
    HRDATA = 0;
    foreach(PRDATA[i]) begin
      if(PSEL[i] == 1) begin
        HRDATA <= PRDATA[i];
      end
    end
  end

endmodule: ahb_apb_bridge

