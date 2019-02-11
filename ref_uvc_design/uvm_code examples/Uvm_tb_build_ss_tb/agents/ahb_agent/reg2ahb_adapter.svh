//
// -------------------------------------------------------------
//    Copyright 2004-2008 Synopsys, Inc.
//   Copyright 2010-2018 Mentor Graphics Corporation
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// reg2ahb_adapter
//----------------------------------------------------------------------
class reg2ahb_adapter extends uvm_reg_adapter;

  // factory registration macro
  `uvm_object_utils(reg2ahb_adapter)

  //--------------------------------------------------------------------
  // new
  //--------------------------------------------------------------------
  function new (string name = "reg2ahb_adapter" );
    super.new(name);

    // Does the protocol the Agent is modeling support byte enables?
    // 0 = NO
    // 1 = YES
    supports_byte_enable = 0;

    // Does the Agent's Driver provide separate response sequence items?
    // i.e. Does the driver call seq_item_port.put()
    // and do the sequences call get_response()?
    // 0 = NO
    // 1 = YES
    provides_responses = 0;

  endfunction: new

  //--------------------------------------------------------------------
  // reg2bus
  //--------------------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    ahb_seq_item trans_h = ahb_seq_item::type_id::create("trans_h");

    trans_h.HWRITE = (rw.kind == UVM_READ) ? AHB_READ : AHB_WRITE;
    trans_h.HADDR = rw.addr;
    trans_h.DATA = rw.data;
    return trans_h;

  endfunction: reg2bus

  //--------------------------------------------------------------------
  // bus2reg
  //--------------------------------------------------------------------
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    ahb_seq_item trans_h;
    if (!$cast(trans_h, bus_item)) begin
      `uvm_fatal("NOT_BUS_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = (trans_h.HWRITE == AHB_WRITE) ? UVM_WRITE : UVM_READ;
    rw.addr = trans_h.HADDR;
    rw.data = trans_h.DATA;
    rw.status = UVM_IS_OK;

  endfunction: bus2reg

endclass: reg2ahb_adapter

