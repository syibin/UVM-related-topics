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
interface sfr_master_bfm  #(ADDR_WIDTH = 8,
                            DATA_WIDTH = 8)
                           (input clk, 
                            input reset,
                            output logic[ADDR_WIDTH-1:0] address,
                            output logic[DATA_WIDTH-1:0] write_data,
                            input logic[DATA_WIDTH-1:0] read_data,
                            output logic we,
                            output logic re);


  import sfr_agent_pkg::*;


  always @(reset or posedge clk) begin
    if(reset == 1) begin
      re <= 0;
      we <= 0;
      address <= 0;
      write_data <= 0;
    end
  end

  task execute(sfr_seq_item item);
    if(reset == 1) begin
      wait(reset == 0);
    end
    else begin
      @(posedge clk);
      address = item.address;
      we <= item.we;
      write_data <= item.write_data;
      re <= item.re;
      @(posedge clk);
      if(re == 1) begin
        item.read_data = read_data;
        re <= 0;
      end
      we <= 0;
    end
  endtask: execute

endinterface: sfr_master_bfm
