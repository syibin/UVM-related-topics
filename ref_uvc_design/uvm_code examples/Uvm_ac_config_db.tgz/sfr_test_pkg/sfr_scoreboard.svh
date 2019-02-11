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
class sfr_scoreboard extends uvm_subscriber #(sfr_seq_item);

`uvm_component_utils(sfr_scoreboard)

int errors;
int reads;

function new(string name = "sfr_scoreboard", uvm_component parent = null);
  super.new(name, parent);
  errors = 0;
  reads = 0;
endfunction

bit[31:0] mem[bit[31:0]]; // Associative array for memory

extern function void write(sfr_seq_item t);
extern function void report_phase(uvm_phase phase);

endclass: sfr_scoreboard

function void sfr_scoreboard::write(sfr_seq_item t);
  if(t.re == 1) begin
    if(mem.exists(t.address)) begin
      reads++;
      if(mem[t.address] != t.read_data) begin
        errors++;
      end
    end
  end
  if(t.we == 1) begin
    mem[t.address] = t.write_data;
  end
endfunction: write

function void sfr_scoreboard::report_phase(uvm_phase phase);
  if(errors == 0) begin
    `uvm_info("** UVM TEST PASSED **", $sformatf("SFR agent test passed with no errors in %0d valid read scenarios", reads), UVM_LOW)
  end
  else begin
    `uvm_error("!! UVM TEST FAILED !!", $sformatf("SFR agent test failed with %0d errors in %0d valid read scenarios", errors, reads))
  end
endfunction: report_phase
