`ifndef SPI_ENV
`define SPI_ENV
class spi_env extends uvm_env;

     `uvm_component_utils(spi_env)
     
     spi_agent m_agent;
     
     function new(string name = "spi_env", uvm_component parent = null);
        super.new(name, parent);
     endfunction
     
     function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        m_agent = spi_agent::type_id::create("m_agent", this);
        
        //scoreboard gelebilir
            
     endfunction     
endclass
`endif