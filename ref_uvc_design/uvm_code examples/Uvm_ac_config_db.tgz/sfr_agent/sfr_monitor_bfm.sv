//
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
//------------------------------------------------------------------------------
//   Copyright 2018 Mentor Graphics Corporation
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
module sfr_monitor_bfm  #(ADDR_WIDTH = 8,
                          DATA_WIDTH = 8)
                        (input clk, 
                         input reset,
                         input [ADDR_WIDTH-1:0] address,
                         input [DATA_WIDTH-1:0] write_data,
                         input [DATA_WIDTH-1:0] read_data,
                         input we,
                         input re);

  import uvm_pkg::*;
  import sfr_agent_pkg::*;

class sfr_monitor_concrete extends sfr_monitor_abstract;
  task monitor(sfr_seq_item item);
    @(posedge clk);
    while(!((we == 1) || (re == 1))) begin
      @(posedge clk);
    end
    item.we = we;
    item.re = re;
    item.address = address;
    item.write_data = write_data;
    item.read_data = read_data;
  endtask: monitor
endclass

sfr_monitor_concrete SFR_MONITOR;

initial begin
  SFR_MONITOR = new();
  uvm_config_db #(sfr_monitor_abstract)::set(null, "uvm_test_top", "SFR_MONITOR", SFR_MONITOR);
end

endmodule: sfr_monitor_bfm
