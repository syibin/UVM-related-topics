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
// The mbus_seq_item is designed to be used with a pipelined bus driver.
// It contains an event pool which is used to signal back to the
// sequence when the driver has completed different pipeline stages
//
class mbus_seq_item extends uvm_sequence_item;

// From the master to the slave
rand logic[31:0] MADDR;
rand logic[31:0] MWDATA;
rand logic MREAD;
rand mbus_opcode_e MOPCODE;

// Driven by the slave to the master
mbus_resp_e MRESP;
logic[31:0] MRDATA;

// Event pool:
uvm_event_pool events;

`uvm_object_utils(mbus_seq_item)

function new(string name = "mbus_seq_item");
  super.new(name);
  events = get_event_pool();
endfunction

constraint addr_is_32 {MADDR[1:0] == 0;}

// Wait for an event - called by sequence
task wait_trigger(string evnt);
  uvm_event e = events.get(evnt);
  e.wait_trigger();
endtask: wait_trigger

// Trigger an event - called by driver
function void trigger(string evnt);
  uvm_event e = events.get(evnt);
  e.trigger();
endfunction: trigger

function void do_copy(uvm_object rhs);
  mbus_seq_item rhs_;

  super.do_copy(rhs);
  if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "cast failed, check type compatability");
      return;
  end
  MADDR = rhs_.MADDR;
  MWDATA = rhs_.MWDATA;
  MREAD = rhs_.MREAD;
  MOPCODE = rhs_.MOPCODE;
  MRESP = rhs_.MRESP;
  MRDATA = rhs_.MRDATA;
endfunction: do_copy

function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  mbus_seq_item rhs_;

  if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_compare", "cast failed, check type compatability");
      return 0;
  end
  do_compare = super.do_compare(rhs, comparer) &&
               MADDR == rhs_.MADDR &&
               MWDATA == rhs_.MWDATA &&
               MREAD == rhs_.MREAD &&
               MOPCODE == rhs_.MOPCODE &&
               MRESP == rhs_.MRESP &&
               MRDATA == rhs_.MRDATA;
endfunction: do_compare

function string convert2string();
  string s;

  s = super.convert2string();
  $sformat(s, "%s\n MADDR\t%0h\n MREAD\t%0b\n MOPCODE\t%s\n Data Fields:\n",
              s, MADDR, MREAD, MOPCODE);
  $sformat(s, "%s\n MRDATA: %0h MWDATA: %0h MRESP: %s\n", s, MRDATA, MWDATA, MRESP.name());
  return s;
endfunction: convert2string

function void do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction: do_print

function void do_record(uvm_recorder recorder);
  super.do_record(recorder);

  `uvm_record_field("MADDR", MADDR)
  `uvm_record_field("MREAD", MREAD)
  `uvm_record_field("MOPCODE", MOPCODE.name())
  `uvm_record_field("MRDATA", MRDATA[0])
  `uvm_record_field("MWDATA", MWDATA[0])
  `uvm_record_field("MRESP", MRESP[0])
endfunction: do_record


endclass: mbus_seq_item
