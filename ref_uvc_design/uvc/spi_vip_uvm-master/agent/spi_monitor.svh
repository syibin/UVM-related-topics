class spi_monitor extends uvm_monitor;
 
    //Registration macro
    `uvm_component_utils(spi_monitor)

    //Virtual interface
    virtual spi_interface spi_vif;
    
    spi_test_config monitor_config;
    
    
    //Analysis port
    uvm_analysis_port #(spi_item) ap;
    
    //Constructor
    function new(string name = "spi_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
    `uvm_info(get_full_name(), "Build phase started", UVM_NONE)
        super.build_phase(phase);
        ap = new("ap", this);
        `uvm_info(get_full_name(), "Ap created", UVM_NONE)
        if(!uvm_config_db #(spi_test_config)::get(this, "", "test_config", monitor_config))
              `uvm_fatal("FATAL MSG", "Configuration Object Not Received Properly");
              
        `uvm_info(get_full_name(), "Build phase finished", UVM_NONE)
    endfunction
    
    function void report_phase(uvm_phase phase);
        //TODO: report phase
    endfunction
    
    function void connect_phase( uvm_phase phase );
    `uvm_info(get_full_name(), "Connect phase started", UVM_NONE)
        super.connect_phase( phase );
        spi_vif = monitor_config.spi_vif; // set local virtual if property
        `uvm_info(get_full_name(), "Connect phase finished", UVM_NONE)
    endfunction
    
    //Tasks
    task run_phase(uvm_phase phase);
    //`uvm_info(get_full_name(), "Run phase started", UVM_NONE)
                
        spi_item item;
        int p;
        int n;
        //`uvm_info(get_full_name(), "Creating sequence item", UVM_NONE)
        item = spi_item::type_id::create("m_item");
        //spi_item cloned_item;

        //`uvm_info(get_full_name(), "Seq item created", UVM_NONE)
        n = 0;
        p = 0;
        item.nedge_mosi = 0;
        item.pedge_mosi = 0;
        item.nedge_miso = 0;
        item.pedge_miso = 0;
        
        forever begin
        //add get result from rx_data regs
        
        begin
            while(spi_vif.cs_n == 0) begin //may be busy
                @(spi_vif.sclk);
                if(spi_vif.sclk == 1) begin
                    item.nedge_mosi[p] = spi_vif.mosi;
                    item.nedge_miso[p] = spi_vif.miso;
                    p++;
                end
                else begin
                    item.pedge_mosi[n] = spi_vif.mosi;
                    item.pedge_miso[n] = spi_vif.miso;
                    n++;
                end
            end
            
            //after cs_n high again
            
            item.rx_data = spi_vif.rx_data;
            
        end
            
        //$cast(cloned_item, item.clone());
        //ap.write(item);
        end
    endtask    
    
endclass