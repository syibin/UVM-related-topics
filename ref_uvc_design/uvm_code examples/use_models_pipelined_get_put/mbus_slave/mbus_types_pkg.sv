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

package mbus_types_pkg;

typedef enum {IDLE, SINGLE, BURST4, BURST8} mbus_opcode_e;
typedef enum logic[2:0] {NULL, READ_VALID, READ_ADDR_ERROR, READ_UNINIT, WRITE_COMPLETE, WRITE_ADDR_ERROR, ADDR_ERROR} mbus_resp_e;

// Mbus sequence item struct
typedef struct packed {
  // From the master to the slave
  logic[31:0] MADDR;
  logic[31:0] MWDATA;
  logic MREAD;
  mbus_opcode_e MOPCODE;

  // Driven by the slave to the master
  mbus_resp_e MRESP;
  logic[31:0] MRDATA;
} mbus_seq_item_s;

parameter int MBUS_SEQ_ITEM_NUM_BITS  = $bits(mbus_seq_item_s);
parameter int MBUS_SEQ_ITEM_NUM_BYTES = (MBUS_SEQ_ITEM_NUM_BITS+7)/8;

typedef bit [MBUS_SEQ_ITEM_NUM_BITS-1:0] mbus_seq_item_vector_t;

endpackage: mbus_types_pkg
