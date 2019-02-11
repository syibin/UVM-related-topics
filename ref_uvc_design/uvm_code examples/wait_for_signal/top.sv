//
//------------------------------------------------------------------------------
//   Copyright 2007-2018 Mentor Graphics Corporation
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
// This example illustrates how a sequence can wait for interface clocks using
// a method implemented in a configuration object.
//
// The configuration object class (bus_agent_config) contains a virtual interface
// handle and two methods which can be called from a sequence:
//
// wait_for_clock(int n) - Waits for n positive clock edges
//
// The sequence bus_seq shows how to call these two methods. It uses the wait_for_clock
// method to increase the interval between bus accesses as the simulation progresses.
//


// DUT is a GPIO
interface gpio_if;

logic[255:0] gp_op;
logic[255:0] gp_ip;
logic clk;

endinterface: gpio_if

// The DUT - A GPIO with a bidrectional bus interface
module bidirect_bus_slave(interface bus, interface gpio);

logic[1:0] delay;

always @(posedge bus.clk)
  begin
    if(bus.resetn == 0) begin
      delay <= 0;
      bus.ready <= 0;
      gpio.gp_op <= 0;
    end
    if(bus.valid == 1) begin // Valid cycle
      if(bus.rnw == 0) begin // Write
        if(delay == 2) begin
          bus.ready <= 1;
          delay <= 0;
          if(bus.addr inside{[32'h0100_0000:32'h0100_001C]}) begin // GPO range - 8 words or 255 bits
            case(bus.addr[7:0])
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
        if(delay == 3) begin
          bus.ready <= 1;
          delay <= 0;
          if(bus.addr inside{[32'h0100_0000:32'h0100_001C]}) begin // GPO range - 8 words or 255 bits
            case(bus.addr[7:0])
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
          else if(bus.addr inside{[32'h0100_0020:32'h0100_003C]}) begin // GPI range - 8 words or 255 bits - read only
            case(bus.addr[7:0])
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

// Top level test bench module
module hdl_top;

// Declare the interfaces
bus_if BUS();
gpio_if GPIO();

// Instantiate the BFM(s)
bidirect_bus_driver_bfm bus_driver_bfm(
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

// Instantiate and hook up the DUT:
bidirect_bus_slave DUT(.bus(BUS), .gpio(GPIO));

// Free running clock
initial
  begin
    BUS.clk = 0;
    forever begin
      #10 BUS.clk = ~BUS.clk;
    end
  end

// Reset
initial
  begin
    BUS.resetn = 0;
    repeat(3) begin
      @(posedge BUS.clk);
    end
    BUS.resetn = 1;
  end

// UVM start up:
initial
  begin
    import uvm_pkg::uvm_config_db;
    uvm_config_db #(virtual bidirect_bus_driver_bfm)::set(null, "uvm_test_top", "bus_drv_bfm" , bus_driver_bfm);
  end

endmodule: hdl_top

module hvl_top();

import uvm_pkg::*;
import bidirect_bus_pkg::*;

// UVM start up:
initial begin
  run_test("bidirect_bus_test");
end

endmodule : hvl_top
