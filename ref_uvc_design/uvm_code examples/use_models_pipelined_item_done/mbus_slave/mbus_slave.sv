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

// MBUS related material
//
// The MBUS is a pipelined bus that has a fixed
// Address and Data width. Transfers are always 32 bits
//
// This version has a pipeline depth of 1
//
// Transfers are single reads or writes or bursts of size 4 or 8
//
//
// Any similarity between the MBUS protocol and any other bus is purely
// co-incidental
//
// All signals on the bus are unidirectional, and are changed and
// sampled on the rising edge of clock
//

interface mbus_if;

import mbus_types_pkg::*;

// To both master and slave
logic MCLK;
logic MRESETN;

// Driven by the master to the slave
logic[31:0] MADDR;
logic[31:0] MWDATA;
logic MREAD;
mbus_opcode_e MOPCODE;

// Driven by the slave to the master
logic MRDY;
mbus_resp_e MRESP;
logic[31:0] MRDATA;

endinterface: mbus_if

interface gpio_if;

logic[255:0] gp_op;
logic[255:0] gp_ip;
logic clk;

endinterface: gpio_if

// This design contains a psuedo RTL slave for the mbus protocol
// Its behaviour can be changed by parameters:
//
// pipeline_depth controls the number of outstanding commands it
// can stackup
//
// out_of_order controls whether the responses returned are in order
// or out_of_order
//
//
// The design contains two slaves:
//
// GPIO with R/W GPO at address range 32'h0100_0000:32'h0100_001C
//           RO  GPI at address range 32'h0100_0020:32'h0100_003C
//
// Memory with address range 32'h0010_0000:32'h001F_FFFC
//

module mbus_slave (interface bus, interface gpio);

import mbus_types_pkg::*;

// Internal memory, sparse of course
//
logic[31:0] memory [logic[31:0]];

// Request state machine state enumeration
//
typedef enum bit[1:0] {WAIT, ONE_BEAT, BURST} req_state_t;

req_state_t req_state;

// Storage for state machine:
logic req_rnw;
logic[31:0] req_addr;
logic[31:0] req_data;
logic req_rdy;
logic[3:0] req_beats;
logic rsp_rdy;


always @(negedge bus.MCLK)
  begin: REQ_FSM
    if(bus.MRESETN == 0) begin
      req_state <= WAIT;
      req_rdy <= 0;
    end
    else begin
      case(req_state)
        WAIT: begin
                if(bus.MOPCODE != IDLE) begin
                  req_addr <= bus.MADDR;
                  req_rnw <= bus.MREAD;
                  req_rdy <= 1;
                  req_data <= bus.MWDATA;
                  case(bus.MOPCODE)
                    SINGLE: req_state <= ONE_BEAT;
                    BURST4: begin
                              req_state <= BURST;
                              req_beats <= 4;
                            end
                    BURST8: begin
                              req_state <= BURST;
                              req_beats <= 8;
                            end
                  endcase
                end
                else begin
                  req_rdy <= 0;
                end
              end
        ONE_BEAT: begin
                    if(bus.MOPCODE != IDLE) begin
                      req_addr <= bus.MADDR;
                      req_rnw <= bus.MREAD;
                      req_rdy <= 1;
                      req_data <= bus.MWDATA;
                      case(bus.MOPCODE)
                        SINGLE: req_state <= ONE_BEAT;
                        BURST4: begin
                                  req_state <= BURST;
                                  req_beats <= 4;
                                end
                        BURST8: begin
                                  req_state <= BURST;
                                  req_beats <= 8;
                                end
                      endcase
                    end
                    else begin
                      req_rdy <= 0;
                      req_state <= WAIT;
                    end
                  end
        BURST: begin
                 if(req_beats == 1) begin // i.e. last beat of the burst
                   if(bus.MOPCODE != IDLE) begin
                     req_addr <= bus.MADDR;
                     req_rnw <= bus.MREAD;
                     req_data <= bus.MWDATA;
                     req_rdy <= 1;
                   end
                   case(bus.MOPCODE)
                     IDLE: req_state <= WAIT;
                     SINGLE: req_state <= ONE_BEAT;
                     BURST4: begin
                               req_state <= BURST;
                               req_beats <= 4;
                             end
                     BURST8: begin
                               req_state <= BURST;
                               req_beats <= 8;
                             end
                   endcase
                 end
                 else begin // Still in burst
                   req_data <= bus.MWDATA;
                   req_addr <= req_addr + 4;
                   req_beats <= req_beats - 1;
                   req_rdy <= 0;
                 end
               end
      endcase
    end
  end: REQ_FSM

// Response handling FSM:
always @(negedge bus.MCLK)
  begin: RSP_FSM
    if(bus.MRESETN == 0) begin // Process reset
      rsp_rdy <= 0;
      bus.MRDATA <= 0;
      bus.MRESP <= NULL;
      gpio.gp_op <= 0;
    end
    else begin // Process current state of pipeline
      if(req_state != WAIT) begin
        if(req_addr inside {[32'h0010_0000:32'h001F_FFFC]}) begin// Memory range
          if(req_rnw == 0) begin // Write
            memory[req_addr] = bus.MWDATA;
            rsp_rdy <= 1;
            bus.MRESP <= WRITE_COMPLETE;
          end
          else begin // Read cycle
            if(memory.exists(req_addr)) begin
              bus.MRDATA = memory[req_addr];
              bus.MRESP <= READ_VALID;
              rsp_rdy <= 1;
            end
            else begin // Read from uninitialised address
              bus.MRDATA <= 32'hxxxx_xxxx;
              bus.MRESP <= READ_UNINIT;
              rsp_rdy <= 1;
            end
          end
        end
        else if(req_addr inside{[32'h0100_0000:32'h0100_001C]}) begin // GPO range - 8 words or 255 bits
          if(req_rnw == 0) begin // write
            case(req_addr[7:0])
              8'h00: gpio.gp_op[31:0] <= bus.MWDATA;
              8'h04: gpio.gp_op[63:32] <= bus.MWDATA;
              8'h08: gpio.gp_op[95:64] <= bus.MWDATA;
              8'h0c: gpio.gp_op[127:96] <= bus.MWDATA;
              8'h10: gpio.gp_op[159:128] <= bus.MWDATA;
              8'h14: gpio.gp_op[191:160] <= bus.MWDATA;
              8'h18: gpio.gp_op[223:192] <= bus.MWDATA;
              8'h1c: gpio.gp_op[255:224] <= bus.MWDATA;
            endcase
            bus.MRESP <= WRITE_COMPLETE;
          end
          else begin
            case(req_addr[7:0])
              8'h00: bus.MRDATA <= gpio.gp_op[31:0];
              8'h04: bus.MRDATA <= gpio.gp_op[63:32];
              8'h08: bus.MRDATA <= gpio.gp_op[95:64];
              8'h0c: bus.MRDATA <= gpio.gp_op[127:96];
              8'h10: bus.MRDATA <= gpio.gp_op[159:128];
              8'h14: bus.MRDATA <= gpio.gp_op[191:160];
              8'h18: bus.MRDATA <= gpio.gp_op[223:192];
              8'h1c: bus.MRDATA <= gpio.gp_op[255:224];
            endcase
            bus.MRESP <= READ_VALID;
          end
          rsp_rdy <= 1;
        end
        else if(req_addr inside{[32'h0100_0020:32'h0100_003C]}) begin // GPI range - 8 words or 255 bits - read only
          if(req_rnw == 1) begin // read operation
            case(req_addr[7:0])
              8'h20: bus.MRDATA <= gpio.gp_ip[31:0];
              8'h24: bus.MRDATA <= gpio.gp_ip[63:32];
              8'h28: bus.MRDATA <= gpio.gp_ip[95:64];
              8'h2c: bus.MRDATA <= gpio.gp_ip[127:96];
              8'h30: bus.MRDATA <= gpio.gp_ip[159:128];
              8'h34: bus.MRDATA <= gpio.gp_ip[191:160];
              8'h38: bus.MRDATA <= gpio.gp_ip[223:192];
              8'h3c: bus.MRDATA <= gpio.gp_ip[255:224];
            endcase
            bus.MRESP <= READ_VALID;
          end
          else begin
            bus.MRESP <= WRITE_ADDR_ERROR; // Attempt to write to invalid location
          end
          rsp_rdy <= 1;
        end
        else begin // Default response
          rsp_rdy <= 1;
          bus.MRESP <= ADDR_ERROR;
        end
      end
    end
  end: RSP_FSM

always @(negedge bus.MCLK)
  begin
    if(bus.MRESETN == 0) begin
      bus.MRDY <= 0;
    end
    else if((req_state == WAIT) && (bus.MOPCODE != IDLE)) begin
      bus.MRDY <= 1;
    end
    else if(req_state != WAIT) begin
      bus.MRDY <= 1;
    end
    else begin
      bus.MRDY <= 0;
    end
  end

endmodule: mbus_slave
