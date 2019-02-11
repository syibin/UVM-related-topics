class u0_sequencer extends uvm_sequencer #(u0_xtn);
  
  function new(string name="u0_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction 

  `uvm_component_utils(u0_sequencer)

endclass 
