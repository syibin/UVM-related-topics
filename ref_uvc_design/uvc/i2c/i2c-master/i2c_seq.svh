//------------------------------------
// Basic APB  Read/Write Transaction class definition
//  This transaction will be used by Sequences, Drivers and Monitors
//------------------------------------
`ifndef APB_RW_SV
`define APB_RW_SV



//apb_rw sequence item derived from base uvm_sequence_item
class seqMult_seq extends uvm_sequence_item;
 
  rand logic   [15:0] a;      //Address
  rand logic   [15:0] b;     //Data - For write or read response
  rand logic 		   ab_valid;
   
  logic ab_ready;

  logic clk;
  logic rst;
    
  logic [32:0] z;
  logic z_valid;
  
  logic [15:0] a_real;
  logic [15:0] b_real;

    //Register with factory for dynamic creation
  `uvm_object_utils(seqMult_seq)
  
   function new (string name = "seqMult_seq");
      super.new(name);
   endfunction

   function bit do_compare (uvm_object rhs, uvm_comparer comparer);
     seqMult_seq seq1;
     bit eq;

     if(!$cast(seq1, rhs)) `uvm_fatal("seq1ans1", "ILLEGAL do_compare() cast")
     eq = super.do_compare(rhs, comparer);
     eq &= (z === seq1.z);
     return(eq);
   endfunction

   //function string convert2string();
   //  string s;
   //  s = super.convert2string();
   //  $sformat(s, "%s\n Type \t%0h\n Addr \t%0h\n Data \t%0h\n Rand \t%0h\n", s, addr, data, apb_cmd);
   //  return s;
   //endfunction
  

endclass: seqMult_seq

`endif
