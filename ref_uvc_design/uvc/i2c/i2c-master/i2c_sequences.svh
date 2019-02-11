
//A few flavours of apb sequences

`ifndef APB_SEQUENCES_SV
`define APB_SEQUENCES_SV

//------------------------
//Base APB sequence derived from uvm_sequence and parameterized with sequence item of type apb_rw
//------------------------
class apb_base_seq extends uvm_sequence#(seqMult_seq);

  `uvm_object_utils(apb_base_seq)

  function new(string name ="");
    super.new(name);
  endfunction


  //Main Body method that gets executed once sequence is started
  task body();
    seqMult_seq seq_item;
    forever begin
      seq_item = seqMult_seq::type_id::create("seqMult_seq");
      start_item(seq_item);
      assert ( seq_item.randomize() );
      finish_item(seq_item);
    end
  endtask
  
endclass



`endif
