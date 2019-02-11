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

interface uart_monitor_bfm (
  input logic sdata,
  input logic sclk
);

  import uart_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
logic[15:0] divisor;
logic [7:0] lcr;
  
bit sbe;
bit pe;
bit fe;
logic clk;
logic parity;

logic[7:0] rxData;
  
uart_monitor proxy;
  
uart_seq_item s_char;

//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

// BFM Methods:

function void set_config(logic[15:0] cfg_div, logic[7:0] cfg_lcr);
  divisor = cfg_div;
  lcr = cfg_lcr;
endfunction : set_config
  
task run();
  s_char = new("Serial_character");
  begin
    fork
      clock_gen;
      begin
        repeat(3)
        @(posedge clk);
        forever
          begin
            fork
              rxChar;
              startBitErrorDetect;
            join_any
            if (sbe == 1)
                disable fork;
            if (sbe == 0)
              begin
                s_char.data = rxData;
                s_char.pe = pe;
                s_char.fe = fe;
               // $display("serialCharSent: %h", rxData);
                proxy.notify_transaction(s_char);
                rxData = 0;
              end
                // Need to get back to the start
               // repeat(8)
               //   @(posedge clk);
          end
      end
    join
  end
endtask : run

task clock_gen;
// Generates clock using clockPeriod from include file
// and divisor variable - how do I set this?
  begin
    clk = 0;
    forever
      begin
        repeat(divisor)
          @(posedge sclk);
        clk = ~clk;
      end
  end
endtask

task startBitErrorDetect;
 automatic integer i;
 automatic int startbit = 0;
   begin
     sbe = 0;
     s_char.sbe = 0;
     i = 0;
     while((sdata == 1'b1) || (sdata == 1'bx))
       @(posedge clk);
       startbit = 1;
//     sdata.lcr = cfg.lcr;
     begin : startBitErrorDetect
       startbit = 99;
       while ((sbe != 1) && i<8)
         begin
           @(posedge clk);
           if(sdata == 1'b1)
             begin
               $display("False start bit detected");
               startbit = 88;
               sbe = 1;
               s_char.sbe = 1;
             end
             i++;
             startbit = i;
         end
       if (!sbe)
         forever
           @(posedge clk);
      end : startBitErrorDetect
   end
endtask

task rxChar;
  automatic int startbit= 0;
// Receives a character according to the appropriate word format
  begin
    // Wait for a falling edge on txd
    fe = 0;
     while((sdata == 1'b1) || (sdata == 1'bx))
       @(posedge clk);
     startbit = 1;
     begin : rxCharDetect
      repeat(23) // Sample on mid point of data field
        @(posedge clk);
      startbit = 0;
      rxData[0] = sdata;
      bitPeriod;
      rxData[1] = sdata;
      bitPeriod;
      rxData[2] = sdata;
      bitPeriod;
      rxData[3] = sdata;
      bitPeriod;
      rxData[4] = sdata;
      if (lcr[1:0] > 2'b00)
        begin
          bitPeriod;
          rxData[5] = sdata;
        end
      else if (lcr[3])
        begin
          bitPeriod;
          parity = sdata; // 5 bits with parity
        end
      if (lcr[1:0] > 2'b00)
        begin
          if (lcr[1:0] > 2'b01)
            begin
              bitPeriod;
              rxData[6] = sdata;
            end
          else if (lcr[3])
            begin
              bitPeriod;
              parity = sdata;
            end
        end
      if (lcr[1:0] > 2'b01)
        begin
          if (lcr[1:0] > 2'b10)
            begin
              bitPeriod;
              rxData[7] = sdata;
            end
          else if (lcr[3])
            begin
              bitPeriod;
              parity = sdata;
            end
        end
      if (lcr[3] && (lcr[1:0] > 2'b10) )
        begin
          bitPeriod;
          parity = sdata;
        end
      if (lcr[3])
        begin
          pe = logic'(calParity (lcr, rxData));
          if (pe != parity)
            pe = 1;
          else
            pe = 0;
        end
      // Check for framing error - get to bit boundary
      repeat(8)
        @(posedge clk);
      repeat(16)
        begin
          @(posedge clk);
          if (sdata == 1'b0)
            fe = 1;
        end
    end : rxCharDetect
  end
endtask

task bitPeriod;
  begin
    repeat(16)
      @(posedge clk);
  end
endtask

endinterface: uart_monitor_bfm
