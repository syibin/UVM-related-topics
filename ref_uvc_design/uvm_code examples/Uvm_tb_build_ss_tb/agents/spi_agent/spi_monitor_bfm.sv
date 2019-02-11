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
interface spi_monitor_bfm (
  input logic       clk,
  input logic [7:0] cs,
  input logic       miso,
  input logic       mosi
);

import spi_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------
spi_monitor proxy;
  spi_seq_item item;
  integer unsigned n;
  integer unsigned p;
//------------------------------------------
// Methods
//------------------------------------------

task run();
//  spi_seq_item item;
  spi_seq_item cloned_item;
//  int n;
//  int p;

  item = spi_seq_item::type_id::create("item");

  while(cs === 8'hxx) begin
    #1;
  end

  forever begin

    while(cs === 8'hff) begin
      @(cs);
    end

    n = 0;
    p = 0;
    item.nedge_mosi = 0;
    item.pedge_mosi = 0;
    item.nedge_miso = 0;
    item.pedge_miso = 0;
    item.cs = cs;

    fork
      begin
        while(cs != 8'hff) begin
          @(clk);
          if(clk == 1) begin
            item.nedge_mosi[p] = mosi;
            item.nedge_miso[p] = miso;
            p++;
          end
          else begin
            item.pedge_mosi[n] = mosi;

            item.pedge_miso[n] = miso;
            n++;
          end
        end
      end
      begin
        @(clk);
        @(cs);
      end
    join_any
    disable fork;

    // Clone and publish the cloned item to the subscribers
    $cast(cloned_item, item.clone());
    proxy.notify_transaction(cloned_item);
  end
endtask: run
  
endinterface: spi_monitor_bfm
