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
class sfr_driver extends uvm_driver #(sfr_seq_item);

`uvm_component_utils(sfr_driver)

function new(string name = "sfr_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

virtual sfr_if SFR;

extern task run_phase(uvm_phase phase);

endclass: sfr_driver

task sfr_driver::run_phase(uvm_phase phase);
  sfr_seq_item item;

  forever begin
    seq_item_port.get_next_item(item);
    if(SFR.reset == 1) begin
      SFR.re <= 0;
      SFR.we <= 0;
      SFR.address <= 0;
      SFR.write_data <= 0;
      wait(SFR.reset == 0);
    end
    else begin
      @(posedge SFR.clk);
      SFR.address = item.address;
      SFR.we <= item.we;
      SFR.write_data <= item.write_data;
      SFR.re <= item.re;
      @(posedge SFR.clk);
      if(SFR.re == 1) begin
        item.read_data = SFR.read_data;
        SFR.re <= 0;
      end
      SFR.we <= 0;
    end
    seq_item_port.item_done();
  end

endtask: run_phase
