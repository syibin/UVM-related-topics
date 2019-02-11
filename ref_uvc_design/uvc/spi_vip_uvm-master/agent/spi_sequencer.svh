class spi_sequencer extends uvm_sequencer #(spi_item);
    
    //Registration Macro
    `uvm_component_utils(spi_sequencer)
    
    function new(string name = "spi_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
endclass