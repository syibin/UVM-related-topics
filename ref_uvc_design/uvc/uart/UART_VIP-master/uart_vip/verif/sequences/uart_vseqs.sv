class u0_base_vseq extends uvm_sequence;
 
 function new(string name="u0_base_vseq");
   super.new(name);
 endfunction 

 `uvm_object_utils(u0_base_vseq)

 `uvm_declare_p_sequencer(u0_vsequencer)

 virtual task pre_body();
   if(starting_phase !=null)
       starting_phase.raise_objection(this, "Running Vseq");
 endtask 

 virtual task post_body();
   if(starting_phase !=null)
       starting_phase.drop_objection(this, "Dropping Vseq");
 endtask 

endclass 


class u0_init_vseq extends u0_base_vseq();

  `uvm_object_utils(u0_init_vseq)

  function new(string name="u0_init_vseq");
    super.new(name);
  endfunction
  
  u0_initialization init_h;
  u0_rd_seq         rd_h;
  u0_wr_seq         wr_h;

  virtual task body();
    `uvm_do_on(init_h, p_sequencer.u0_seqr);
    repeat(200) begin 
    `uvm_do_on(wr_h, p_sequencer.u0_seqr);
    `uvm_do_on(rd_h, p_sequencer.u0_seqr);
    end 
  endtask 

endclass 
