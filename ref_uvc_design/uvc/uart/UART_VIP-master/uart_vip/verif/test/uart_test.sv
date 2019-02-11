class u0_base_test extends uvm_test;
  
  u0_tb                tb_h;
  u0_vsequencer        u0_vseqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  `uvm_component_utils(u0_base_test)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tb_h = u0_tb::type_id::create("tb_h", this);
  endfunction 
 
  function void end_of_elaboration_phase(uvm_phase phase);
    u0_vseqr = tb_h.u0_vseqr;
    uvm_top.print_topology();
  endfunction 

endclass 

class u0_test extends u0_base_test;
  
  u0_init_vseq   init_vseq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  `uvm_component_utils(u0_test)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction 

  task run_phase(uvm_phase phase);
    begin 
    // factory.print();

    phase.raise_objection(this);
    init_vseq = u0_init_vseq::type_id::create("init_vseq");
    assert(init_vseq.randomize());
    init_vseq.start(u0_vseqr,null);
    #20000;
    phase.drop_objection(this);

    end
  endtask 
endclass
