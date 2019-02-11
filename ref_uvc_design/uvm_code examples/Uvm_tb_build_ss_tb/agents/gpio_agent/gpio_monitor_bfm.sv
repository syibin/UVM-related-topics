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
//
// BFM Interface Description:
//
//
interface gpio_monitor_bfm (
  input        clk,
  input [31:0] gpio,
  input        ext_clk
);

  import gpio_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
gpio_monitor proxy;
  
//------------------------------------------
// Component Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------
  

task internal_monitor_loop();
  gpio_seq_item item;
  gpio_seq_item cloned_item;
  logic[31:0] last_gpio_sample;

  item = gpio_seq_item::type_id::create("item");

  // Initialisation:
  @(posedge clk);
  last_gpio_sample = gpio;

  forever begin
    @(posedge clk);
    if(gpio !== last_gpio_sample) begin
      item.gpio = gpio;
      last_gpio_sample = gpio;
      // Clone and publish the cloned item to the subscribers
      $cast(cloned_item, item.clone());
      proxy.notify_transaction(cloned_item);
//      `uvm_info("GPIO_MONITOR", cloned_item.convert2string(), UVM_LOW)
    end
  end // forever begin
endtask: internal_monitor_loop

task external_monitor_loop();
  gpio_seq_item item;
  gpio_seq_item cloned_item;
  logic[31:0] last_gpio_sample;

  item = gpio_seq_item::type_id::create("item");

  // Initialisation:
  @(posedge clk);
  last_gpio_sample = gpio;

  forever begin
    // Detect the protocol event on the virtual interface
    @(posedge ext_clk);
      @(posedge clk);
//    if(gpio != last_gpio_sample) begin
      item.gpio = gpio;
      last_gpio_sample = gpio;
      item.ext_clk = 1;
    repeat(4)
      @(posedge clk);
    @(negedge clk);
//    end
    // Clone and publish the cloned item to the subscribers
    $cast(cloned_item, item.clone());
    proxy.notify_transaction_ext_ap(cloned_item);
    @(negedge ext_clk);
    repeat(1)
      @(posedge clk);
//    if(gpio != last_gpio_sample) begin
      item.gpio = gpio;
      last_gpio_sample = gpio;
      item.ext_clk = 0;
    repeat(4)
      @(posedge clk);
    @(negedge clk);
//    end
    // Clone and publish the cloned item to the subscribers
    $cast(cloned_item, item.clone());
    proxy.notify_transaction_ext_ap(cloned_item);
  end
endtask: external_monitor_loop

endinterface: gpio_monitor_bfm
