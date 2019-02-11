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
//
// This example illustrates how to implement a bidirectional driver-sequence use model.
// It uses get_next_item() and item_done() in the driver.
//
// It includes a bidirectional slave DUT, and the bus transactions are reported to
// the transcript.
//

module top_hdl;

bus_if  BUS();
gpio_if GPIO();

bidirect_bus_driver_bfm bidirect_bus_drv(
   .clk        (BUS.clk),
   .resetn     (BUS.resetn),
   .addr       (BUS.addr),
   .write_data (BUS.write_data),
   .rnw        (BUS.rnw),
   .valid      (BUS.valid),
   .ready      (BUS.ready),
   .read_data  (BUS.read_data),
   .error      (BUS.error)
);

bidirect_bus_slave DUT(.bus(BUS), .gpio(GPIO));

// Free running clock
initial begin
  BUS.clk = 0;
  forever begin
    #10 BUS.clk = ~BUS.clk;
  end
end

// Reset
initial begin
  BUS.resetn = 0;
  repeat (3) begin
    @(posedge BUS.clk);
  end
  BUS.resetn = 1;
end

initial begin
  uvm_pkg::uvm_config_db #(virtual bidirect_bus_driver_bfm)::
    set(null, "uvm_test_top", $psprintf("%m.bidirect_bus_drv") , bidirect_bus_drv);
end

endmodule: top_hdl


interface bus_if;

logic clk;
logic resetn;
logic[31:0] addr;
logic[31:0] write_data;
logic rnw;
logic valid;
logic ready;
logic[31:0] read_data;
logic error;

endinterface: bus_if


interface gpio_if;

logic[255:0] gp_op;
logic[255:0] gp_ip;
logic clk;

endinterface: gpio_if


interface bidirect_bus_driver_bfm (
   input  logic        clk,
   input  logic        resetn,
   output logic [31:0] addr,
   output logic [31:0] write_data,
   output logic        rnw,
   output logic        valid,
   input  logic        ready,
   input  logic [31:0] read_data,
   input  logic        error
);

import bidirect_bus_pkg::*;

initial begin
  valid <= 0;
  rnw <= 1;
end

task wait_for_reset();
  @(posedge resetn);
endtask: wait_for_reset

task drive(bus_seq_item req);
  repeat (req.delay) begin // Delay between bus transactions
    @(posedge clk);
  end

  valid <= 1;

  addr <= req.addr;
  rnw <= req.read_not_write;
  if (req.read_not_write == 0) begin
     write_data <= req.write_data;
  end

  while (ready != 1) begin
    @(posedge clk);
  end

  // At end of the pin level bus transaction
  // Copy response data into the req fields:
  if (req.read_not_write == 1) begin
    req.read_data = read_data; // Copy read data response
  end
  req.error = error; // Copy bus error response status

  valid <= 0; // End the pin level bus transaction
endtask: drive

endinterface: bidirect_bus_driver_bfm


// DUT - A semi-real GPIO interface with a scratch RAM
module bidirect_bus_slave(interface bus, interface gpio);

logic[1:0] delay;

always @(posedge bus.clk) begin
  if (bus.resetn == 0) begin
    delay <= 0;
    bus.ready <= 0;
    gpio.gp_op <= 0;
  end
  if (bus.valid == 1) begin // Valid cycle
    if (bus.rnw == 0) begin // Write
      if (delay == 2) begin
        bus.ready <= 1;
        delay <= 0;
        if (bus.addr inside{[32'h0100_0000:32'h0100_001C]}) begin // GPO range - 8 words or 255 bits
          case (bus.addr[7:0])
            8'h00: gpio.gp_op[31:0] <= bus.write_data;
            8'h04: gpio.gp_op[63:32] <= bus.write_data;
            8'h08: gpio.gp_op[95:64] <= bus.write_data;
            8'h0c: gpio.gp_op[127:96] <= bus.write_data;
            8'h10: gpio.gp_op[159:128] <= bus.write_data;
            8'h14: gpio.gp_op[191:160] <= bus.write_data;
            8'h18: gpio.gp_op[223:192] <= bus.write_data;
            8'h1c: gpio.gp_op[255:224] <= bus.write_data;
          endcase
          bus.error <= 0;
        end
        else begin
          bus.error <= 1; // Outside valid write address range
        end
      end
      else begin
        delay <= delay + 1;
        bus.ready <= 0;
      end
    end
    else begin // Read cycle
      if (delay == 3) begin
        bus.ready <= 1;
        delay <= 0;
        if (bus.addr inside{[32'h0100_0000:32'h0100_001C]}) begin // GPO range - 8 words or 255 bits
          case (bus.addr[7:0])
            8'h00: bus.read_data <= gpio.gp_op[31:0];
            8'h04: bus.read_data <= gpio.gp_op[63:32];
            8'h08: bus.read_data <= gpio.gp_op[95:64];
            8'h0c: bus.read_data <= gpio.gp_op[127:96];
            8'h10: bus.read_data <= gpio.gp_op[159:128];
            8'h14: bus.read_data <= gpio.gp_op[191:160];
            8'h18: bus.read_data <= gpio.gp_op[223:192];
            8'h1c: bus.read_data <= gpio.gp_op[255:224];
          endcase
          bus.error <= 0;
        end
        else if (bus.addr inside{[32'h0100_0020:32'h0100_003C]}) begin // GPI range - 8 words or 255 bits - read only
          case (bus.addr[7:0])
            8'h20: bus.read_data <= gpio.gp_ip[31:0];
            8'h24: bus.read_data <= gpio.gp_ip[63:32];
            8'h28: bus.read_data <= gpio.gp_ip[95:64];
            8'h2c: bus.read_data <= gpio.gp_ip[127:96];
            8'h30: bus.read_data <= gpio.gp_ip[159:128];
            8'h34: bus.read_data <= gpio.gp_ip[191:160];
            8'h38: bus.read_data <= gpio.gp_ip[223:192];
            8'h3c: bus.read_data <= gpio.gp_ip[255:224];
          endcase
          bus.error <= 0;
        end
        else begin
          bus.error <= 1;
        end
      end
      else begin
        delay <= delay + 1;
        bus.ready <= 0;
      end
    end
  end
  else begin
    bus.ready <= 0;
    bus.error <= 0;
    delay <= 0;
  end
end

endmodule: bidirect_bus_slave
