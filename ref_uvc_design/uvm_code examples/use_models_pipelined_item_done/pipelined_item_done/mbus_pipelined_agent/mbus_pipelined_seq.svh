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
class mbus_unpipelined_seq extends uvm_sequence #(mbus_seq_item);

`uvm_object_utils(mbus_unpipelined_seq)

logic[31:0] addr[10]; // To save addresses
logic[31:0] data[10]; // To save data

int error_count;

function new(string name = "mbus_unpipelined_seq");
  super.new(name);
endfunction

task body;

  mbus_seq_item req = mbus_seq_item::type_id::create("req");
  error_count = 0;

  for(int i=0; i<10; i++) begin
    start_item(req);
    assert(req.randomize() with {MREAD == 0; MOPCODE == SINGLE; MADDR inside {[32'h0010_0000:32'h001F_FFFC]};});
    addr[i] = req.MADDR;
    data[i] = req.MWDATA;
    finish_item(req);
    req.wait_trigger("DATA_DONE");
  end

  foreach(addr[i]) begin
    start_item(req);
    req.MADDR = addr[i];
    req.MREAD = 1;
    finish_item(req);
    req.wait_trigger("DATA_DONE");
    if(req.MRDATA != data[i]) begin
      error_count++;
      `uvm_error("body", $sformatf("@%0h Expected data:%0h Actual data:%0h", addr[i], data[i], req.MRDATA))
    end
  end
endtask: body

endclass: mbus_unpipelined_seq

class mbus_pipelined_seq extends uvm_sequence #(mbus_seq_item);

`uvm_object_utils(mbus_pipelined_seq)

logic[31:0] addr[10]; // To save addresses

function new(string name = "mbus_pipelined_seq");
  super.new(name);
endfunction

task body;

  mbus_seq_item req = mbus_seq_item::type_id::create("req");

  for(int i=0; i<10; i++) begin
    start_item(req);
    assert(req.randomize() with {MREAD == 0; MOPCODE == SINGLE; MADDR inside {[32'h0010_0000:32'h001F_FFFC]};});
    addr[i] = req.MADDR;
    finish_item(req);
  end

  foreach (addr[i]) begin
    start_item(req);
    req.MADDR = addr[i];
    req.MREAD = 1;
    finish_item(req);
  end
endtask: body

endclass: mbus_pipelined_seq

class mbus_pipelined_check_seq extends uvm_sequence #(mbus_seq_item);

`uvm_object_utils(mbus_pipelined_check_seq)

logic[31:0] base_address;

int read_count;
int error_count;

function new(string name = "mbus_pipelined_check_seq");
  super.new(name);
endfunction

task body;

  mbus_seq_item req = mbus_seq_item::type_id::create("req");
  mbus_seq_item req_c[10];

  error_count = 0;

  // Fill up some memory
  for(int i=0; i<10; i++) begin
    assert($cast(req_c[i], req.clone()));
    start_item(req_c[i]);
    assert(req_c[i].randomize() with {MREAD == 0; MOPCODE == SINGLE; MADDR inside {[base_address:(base_address+32'h1000)]};});
    finish_item(req_c[i]);
  end

  // If any of the addresses are repeated, the last write wins:
  for(int i=0; i<10; i++) begin
    for(int j=0; j<i; j++) begin
      if(req_c[i].MADDR == req_c[j].MADDR) begin
        req_c[j].MWDATA = req_c[i].MWDATA;
      end
    end
  end

  // Check the memory content
  read_count = 10;
  for(int i=0; i<10; i++) begin
    start_item(req_c[i]);
    req_c[i].MREAD = 1;
    fork
      check_data(req_c[i], i); // Spawned data check
    join_none
    finish_item(req_c[i]);
    req_c[i].wait_trigger("CMD_DONE");
  end
  wait(read_count == 0);

endtask: body

task check_data(mbus_seq_item req, int i);
  // Wait for the data phase to complete
  req.wait_trigger("DATA_DONE");
  if(req.MWDATA != req.MRDATA) begin
    `uvm_error("check_data", $sformatf("Data read error @%0h Data written: %0h, Data read back: %0h", req.MADDR, req.MWDATA, req.MRDATA))
    error_count++;
  end
  read_count--;
endtask: check_data

endclass: mbus_pipelined_check_seq
