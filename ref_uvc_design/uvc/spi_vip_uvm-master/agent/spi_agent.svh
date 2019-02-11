class spi_agent extends uvm_component;

    `uvm_component_utils(spi_agent)

    spi_test_config agent_config;
    
    //uvm_analysis_port #(spi_item) ap;
    //spi_monitor m_monitor;
    spi_sequencer m_sequencer;
    spi_driver m_driver;
    
    function new(string name = "m_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase); //From the sample, active-passive agent config
    
    `uvm_info(get_full_name(), "Build phase started.", UVM_NONE)
        if (!uvm_config_db #(spi_test_config)::get(this, "", "test_config", agent_config) )
            `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration spi_test_config from uvm_config_db. Have you set() it?")
            //Monitor is always present
            //`uvm_info(get_full_name(), "Creating monitor.", UVM_NONE)
            //m_monitor = spi_monitor::type_id::create("m_monitor", this);
            //`uvm_info(get_full_name(), "Created monitor.", UVM_NONE)
            //Only build the driver and sequencer if active
            if(agent_config.active == UVM_ACTIVE) begin
                `uvm_info(get_full_name(), "Creating driver and sequencer.", UVM_NONE)
                m_driver = spi_driver::type_id::create("m_driver", this);
                m_sequencer = spi_sequencer::type_id::create("m_sequencer", this);
                `uvm_info(get_full_name(), "Created driver and sequencer.", UVM_NONE)
            end
    endfunction
    
    function void connect_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "Connect phase started", UVM_NONE)
        //m_monitor.spi_vif = agent_config.spi_vif;
        //ap = m_monitor.ap;
        //Only connect the driver and the sequencer if active
        if(agent_config.active == UVM_ACTIVE) begin
            m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
            m_driver.spi_vif = agent_config.spi_vif;
        end
        `uvm_info(get_full_name(), "Connect phase ended", UVM_NONE)
    endfunction
endclass