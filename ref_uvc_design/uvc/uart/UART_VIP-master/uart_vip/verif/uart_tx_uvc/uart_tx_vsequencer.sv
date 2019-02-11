class u0_vsequencer extends uvm_sequencer;

  // Sequencer handle
  u0_sequencer    u0_seqr;

  function new(string name="u0_vsequencer", uvm_component parent);
    super.new(name, parent);
  endfunction 

  `uvm_component_utils(u0_vsequencer)

endclass 
