`ifndef SPI_TEST
`define SPI_TEST
class spi_test extends uvm_test;

    `uvm_component_utils(spi_test)

    spi_sequence m_sequence;
    spi_env m_env;
    
    spi_test_config test_config;
    
    function new(string name = "spi_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        test_config = new();
        
        if(!uvm_config_db #(virtual spi_interface)::get(this, "", "spi_vif", test_config.spi_vif))            
        `uvm_fatal("FATAL MSG", "Virtual Interface Not Set Properly");
        
        uvm_config_db #(spi_test_config)::set(this, "*", "test_config", test_config);
        
        m_env = spi_env::type_id::create("m_env", this);
    
        m_sequence = spi_sequence::type_id::create("m_sequence", this);
    
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        phase.raise_objection(this);
        m_sequence.start(m_env.m_agent.m_sequencer);
        
        phase.drop_objection(this);
    
    endtask
    
    
endclass

`endif