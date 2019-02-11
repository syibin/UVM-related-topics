/*****************************************************************************
 *
//   Copyright 2007-2018 Mentor Graphics Corporation
 * All Rights Reserved.
 *
 * THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE PROPERTY OF 
 * MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
 *
 *****************************************************************************/
module apb3_wlm_host(pclk, presetn, paddr, psel, penable, 
                     pwrite, pwdata, prdata, pready, pslverr);

  parameter ADD_BUS_WIDTH  = 32;
  parameter DATA_BUS_WIDTH = 32;
  parameter SLAVE_COUNT    = 1; 

  input         bit pclk;
  input  bit presetn;
  output [ADD_BUS_WIDTH - 1 : 0] paddr;
  output [SLAVE_COUNT - 1 : 0] psel;
  output penable;
  output pwrite;
  output [DATA_BUS_WIDTH-1:0] pwdata;
  input bit [DATA_BUS_WIDTH-1:0] prdata;
  input bit                     pready;
  input bit                     pslverr;
  
  typedef enum {
    IDLE, SETUP, ACCESS
  } protocol_driver_state_e;

  protocol_driver_state_e m_state;     


  logic [ADD_BUS_WIDTH - 1 : 0] g_paddr;
  logic [SLAVE_COUNT - 1 : 0] g_psel;
  logic g_penable;
  logic g_pwrite;
  logic [DATA_BUS_WIDTH-1:0] g_pwdata;

  int slv_id;
 
  assign                      paddr   = g_paddr;
  assign                      psel    = g_psel;
  assign                      penable = g_penable;
  assign                      pwrite  = g_pwrite;
  assign                      pwdata  = g_pwdata;

  
  initial begin
    m_state = IDLE;
    g_paddr   = 0;
    g_pwdata  = 0;
    g_penable = 0;
    g_psel    = 0;
    g_pwrite  = 0;
  end
  
// Generate cycle accurate bus controls for protocol

  always @( posedge pclk or negedge presetn ) begin
    if( presetn == 0 ) 
    begin
      g_penable <= 0;
      g_psel    <= 0;
      
      m_state <= IDLE;
    end
    else begin   

// Conceptual state-machine to emulate bus protocol activity

      case( m_state )

        IDLE : begin
          
             g_penable <= 0;
             #0;  
             randcase
               // write operation
               2: begin
                 slv_id         = $urandom_range(0,SLAVE_COUNT-1);
                 g_psel         = 0;
                 g_psel[slv_id] <= 1'b1;
                 g_pwrite  <= 1;
                 g_paddr   <= $urandom_range(slv_id*100, (slv_id +1)*100 -1);
                 g_pwdata  <= $urandom;
                 m_state <= SETUP; 
               end
               // read operation
               2: begin
                 slv_id         = $urandom_range(0,SLAVE_COUNT-1);
                 g_psel         = 0;
                 g_psel[slv_id] <= 1'b1;
                 g_pwrite  <= 0;
                 g_paddr   <= $urandom_range(slv_id*100, (slv_id +1)*100 -1);
                 m_state <= SETUP;
               end
               // No operation
               5: begin
                 g_psel    <= 0;
                 m_state <= IDLE;
               end
              endcase
        end // IDLE
  
        SETUP : begin  
// Setup bus controls to transition to an ACCESS state

          g_penable <= 1;
 
          m_state <= ACCESS;
        end // SETUP

        ACCESS : begin 

          if(pready == 1) begin
            randcase
               // b2b write operation
               2: begin
                 slv_id         = $urandom_range(0,SLAVE_COUNT-1);
                 g_psel         = 0;
                 g_psel[slv_id] <= 1'b1;
                 g_pwrite  <= 1;
                 g_paddr   <= $urandom_range(slv_id*100, (slv_id +1)*100 -1);
                 g_pwdata  <= $urandom;
                 m_state <= SETUP; 
               end
               // b2b read operation
               2: begin
                 slv_id         = $urandom_range(0,SLAVE_COUNT-1);
                 g_psel         = 0;
                 g_psel[slv_id] <= 1'b1;
                 g_pwrite  <= 0;
                 g_paddr   <= $urandom_range(slv_id*100, (slv_id +1)*100 -1);
                 m_state <= SETUP;
               end
               // No operation
               5: begin
                 g_psel    <= 0;
                 m_state <= IDLE;
               end
            endcase 
            g_penable <= 0;
           end
        end
      endcase
    end  
  end  
endmodule
