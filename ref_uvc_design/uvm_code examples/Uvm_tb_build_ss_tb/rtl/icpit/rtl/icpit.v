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

module icpit (// APB Interface signals:
              input PCLK,
              input PRESETN,
              input[2:0] PADDR,
              input PSEL,
              input PENABLE,
              input PWRITE,
              input[31:0] PWDATA,
              output reg[31:0] PRDATA,
              output reg PREADY,
              // Interrupt signals:
              output reg IRQ,
              input[7:0] IREQ,
              // PIT Terminal Count
              output reg PIT_OUT,
              // Watchdog Terminal Count
              output reg WATCHDOG);


reg[9:0] inte;
reg[9:0] ints;
reg[9:0] ireq_in;
reg[9:0] ireq_sync;
reg[31:0] pit;
reg[31:0] pit_val;
reg pit_load;
reg[30:0] wdog;
reg wdog_load;
reg wr_inte;
reg wr_pit_val;
reg wr_pit_ctrl;
reg rd_ints;

integer i;

// Interrupt controller
always @(posedge PCLK)
  begin
    if(PRESETN == 0) begin
      inte <= 10'h200;
      IRQ <= 0;
      ints <= 0;
      ireq_in <= 0;
      ireq_sync <= 0;
    end
    else begin
      // Synchronise the interrupt inputs
      ireq_in <= {WATCHDOG, PIT_OUT, IREQ};
      ireq_sync <= ireq_in;
      // Trigger or clear the interrupts, else keep current value
      for(i = 0; i < 9; i = i + 1) begin
        ints[i] <= (ireq_in[i] & ~ireq_sync[i] & inte[i]) & (~(rd_ints & ints[i])) | ((~rd_ints & ints[i] & inte[i]));
      end
      // Watchdog is non-maskable:
      ints[9] <= (ireq_in[9] & ~ireq_sync[9]) & (~(rd_ints & ints[9])) | (~rd_ints & ints[9]);
      IRQ <= |ints;
      // Write to the interrupt enable
      if(wr_inte) begin
        inte <= {1'b1, PWDATA[8:0]};
      end
    end
  end

// PIT
always @(posedge PCLK)
  begin
    if(PRESETN == 0) begin
      pit <= 0;
      pit_val <= 0;
      pit_load <= 0;
      PIT_OUT <= 0;
    end
    else begin
      // Write to the pit_val register
      if(wr_pit_val) begin
        pit_val <= PWDATA;
      end
      if(wr_pit_ctrl) begin
        pit_load <= PWDATA[0];
      end
      if(pit_load == 1) begin
        pit_load <= 0;
        pit <= pit_val;
        PIT_OUT <= 0;
      end
      else if(pit == 0) begin
             PIT_OUT <= 1;
             pit <= pit_val;
           end
           else begin
            pit <= pit - 1;
            PIT_OUT <= 0;
           end
    end
  end

// Watchdog
always @(posedge PCLK)
  begin
    if(PRESETN == 0) begin
      wdog <= 31'h42_0000;
      wdog_load <= 0;
      WATCHDOG <= 0;
    end
    else begin
      // Write to the Watchdog bone register
      if(wr_pit_ctrl) begin
        wdog_load <= PWDATA[1];
      end
      if(wdog_load == 1) begin
        wdog_load <= 0;
        wdog <= 31'h42_00;
        WATCHDOG <= 0;
      end
      else if(wdog == 0) begin
             WATCHDOG <= 1;
             wdog <= 31'h42_0000;
           end
           else begin
            wdog <= wdog - 1;
            WATCHDOG <= 0;
           end
    end
  end

// APB Interface
always @(PSEL, PENABLE, PADDR, PWRITE)
begin
  wr_inte = 0;
  wr_pit_val = 0;
  wr_pit_ctrl = 0;
  rd_ints = 0;
  if((PSEL == 1) && (PENABLE == 1)) begin
    if(PWRITE == 1) begin
      case(PADDR)
        3'b000: wr_inte = 1;
        3'b010: wr_pit_val = 1;
        3'b100: wr_pit_ctrl = 1;
        default: wr_inte = 0;
      endcase
    end
    else begin
      case(PADDR)
        3'b000: PRDATA = {21'h0, inte};
        3'b001: begin
                  PRDATA = {21'h0, ints};
                  rd_ints = 1;
                end
        3'b010: PRDATA = pit_val;
        3'b011: PRDATA = pit;
        3'b100: PRDATA = {30'h0, wdog_load, pit_load};
        default: PRDATA = 0;
      endcase
    end
    PREADY = 1;
  end
  else begin
    PREADY = 0;
  end
end
  
endmodule  
    
      