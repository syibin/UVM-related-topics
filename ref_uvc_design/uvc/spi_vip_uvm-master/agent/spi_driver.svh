`ifndef SPI_DRIVER
`define SPI_DRIVER
    class spi_driver extends uvm_driver#(spi_item);
    
        //Registration macro
        `uvm_component_utils(spi_driver)    
        
        //Virtual interface
        virtual spi_interface spi_vif;
        
        spi_test_config driver_config;
            
        //Constructor
        function new(string name = "spi_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction
        
        //// Build Function
        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            
            if(!uvm_config_db #(spi_test_config)::get(this, "", "test_config", driver_config))
              `uvm_fatal("FATAL MSG", "Configuration Object Not Received Properly");
            
        endfunction

        //// Connect Function
        function void connect_phase (uvm_phase phase);
            super.connect_phase(phase);
            spi_vif = driver_config.spi_vif;
            `uvm_info(get_full_name(), "Trying to set the interface.", UVM_NONE)
        endfunction
              
        //Tasks
        task run_phase(uvm_phase phase);
        
            //`uvm_info(get_full_name(), "Run phase started.", UVM_NONE
            spi_item item;
            int no_bits;
            
            no_bits = 16;      
            
            //get to the ready state
            spi_vif.reset_n <= 1'b0;
            #30;
            spi_vif.reset_n <= 1'b1;
            
            while(spi_vif.busy == 1) begin //wait until ip is ready
                #1;
            end
            
            //begin transactions            
            
            forever begin   //get the next item and configure ip
                seq_item_port.get_next_item(item);
                spi_vif.tx_data <= item.tx_data;
                spi_vif.cpol <= item.cpol;
                spi_vif.cpha <= item.cpha;
                spi_vif.clk_div <= item.clk_div;
                #1;
                //enable <= 1, start sending
                spi_vif.enable <= 1'b1;
                `uvm_info("SPI_DRIVER_RUN:", $sformatf("Starting transmission: %0b Sending, %b Response.", item.tx_data, item.miso_data), UVM_LOW)
                
                while(spi_vif.busy == 0) begin //wait until ip starts sending
                    #1;
                end
                
                spi_vif.enable <= 1'b0; //spi started, not continuous running
                
                for(int i = 0; i < no_bits; i++) begin
                
                spi_vif.miso <= item.miso_data[no_bits-1-i];
                
                    if(item.cpol == 0) begin
                        @(posedge spi_vif.sclk);
                    end
                    else begin
                        @(negedge spi_vif.sclk);
                    end
                    
                    if(spi_vif.busy == 1'b0) begin
                        break;
                    end
                end
                
                while(spi_vif.busy == 1) begin //wait
                    #1;
                end
                
                seq_item_port.item_done();
            end
            
            
        endtask
    endclass 
`endif