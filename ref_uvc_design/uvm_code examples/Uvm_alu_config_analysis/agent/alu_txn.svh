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

//----------------------------------------------
class alu_txn extends uvm_sequence_item;

`uvm_object_utils(alu_txn);

 static int my_sid;

 rand op_type_t mode;
 bit [3:0] done;
 rand shortint unsigned val1;
 rand shortint unsigned val2;
 shortint  unsigned result;
 int       id;

 function new(string name = "alu_txn");
   super.new(name);
   id = my_sid++;
 endfunction
 
 constraint mode_con {
   done[ADD] == 1 -> mode != ADD;
   done[SUB] == 1 -> mode != SUB;
   done[MUL] == 1 -> mode != MUL;
   done[DIV] == 1 -> mode != DIV;
 }

 constraint small_vals {
   val1 inside {[0:500]};
   val2 inside {[0:500]};
 }

 virtual function string convert2string();
   string str1;
   str1 = {    "-------------------- Start ALU txn --------------------\n",
              "ALU txn \n",  
   $sformatf("  mode   : %s\n", mode.name()),
   $sformatf("  id     : ;h%h\n", id),
   $sformatf("  done   : 'b%b\n", done),
   $sformatf("  val1   : 'h%h\n", val1),
   $sformatf("  val2   : 'h%h\n", val2),
   $sformatf("  result : 'h%h\n", result),
              "-------------------- End ALU txn --------------------\n"};
   return (str1);
 endfunction
 
 function void do_copy(uvm_object rhs);
   alu_txn tmp;
   if(!$cast(tmp, rhs)) // cast so can access the fields
     uvm_report_fatal("TypeMismatch", "Type mismatch in copy");
   super.do_copy(tmp);
   mode   = tmp.mode;
   done   = tmp.done;
   val1   = tmp.val1;
   val2   = tmp.val2;
   result = tmp.result;
   id     = tmp.id;
   // if (obj == null)
   // obj = new(...); // for deep copy
   // obj.copy(rhs_.obj);
 endfunction
 
 function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   alu_txn tmp;
   $cast(tmp, rhs); // cast so can access the fields
   return (mode   == tmp.mode &&
           done   == tmp.done &&
           val1   == tmp.val1 &&
           val2   == tmp.val2 &&
           result == tmp.result);
 endfunction

 function void do_pack(uvm_packer packer);
   `uvm_pack_int(mode)
   `uvm_pack_int(done)
   `uvm_pack_int(val1)
   `uvm_pack_int(val2)
   `uvm_pack_int(result)
   `uvm_pack_int(id)
 endfunction

 function void do_unpack(uvm_packer packer);
   `uvm_unpack_enum(mode,op_type_t)
   `uvm_unpack_int(done)
   `uvm_unpack_int(val1)
   `uvm_unpack_int(val2)
   `uvm_unpack_int(result)
   `uvm_unpack_int(id)
 endfunction
 
 function void do_print(uvm_printer printer);
   $display(this.convert2string());
 endfunction
   
 function int index_id();
   return id;
 endfunction
 
 function void set_done(input bit [3:0] d);
   done = d;
 endfunction

 //This function is a bug work around in comparator scoreboard class
 function bit comp(input alu_txn rhs);
   return (this.compare(rhs));
 endfunction
  
endclass 

