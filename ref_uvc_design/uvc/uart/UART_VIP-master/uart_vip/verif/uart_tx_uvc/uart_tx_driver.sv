class u0_driver extends uvm_driver #(u0_xtn);

  virtual u0if u0_if;

  function new(string name="u0_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  `uvm_component_utils(u0_driver)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("U0_DRIVER", " THIS IS A BUILD PHASE", UVM_LOW)
    if(!uvm_config_db #(virtual u0if)::get(this,"","u0_if", u0_if)) begin
        `uvm_error("build_phase", "UART interface not found")
    end
  endfunction 

  task run_phase(uvm_phase phase);
    forever begin 
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask 

  task send_to_dut(u0_xtn xtn_h);  
    reset_dut();
    wait (!u0_if.rst); 
    if(!u0_if.rst) begin
      @(posedge u0_if.clk);          
      if (req.write == 1'b1) begin 
        u0_if.write  <= #1 1'b1; 
        u0_if.din    <= #1 req.din ;
        u0_if.addr   <= #1 req.addr;
        @(posedge u0_if.clk) begin           
        u0_if.write  <= #1 1'b0;
        end 
      end 
      else if (req.read == 1'b1) begin 
        u0_if.read   <= #1 1'b1; 
        u0_if.addr   <= #1 req.addr;
        wait (u0_if.dout[5]==1) begin        // Checking for DRE bit. 
        @(posedge u0_if.clk);          
          u0_if.read   <= 1'b0; 
        end 
      end 
      else begin
      end 
    end 
  endtask 

  task reset_dut();
    if(u0_if.rst) begin
      u0_if.din    <= #1 'h0 ;
      u0_if.read   <= #1 'h0 ;
      u0_if.write  <= #1 'h0 ;
      u0_if.addr   <= #1 'h0 ;
      u0_if.txack  <= #1 'h0 ;
      u0_if.rxack  <= #1 'h0 ;
      u0_if.tcack  <= #1 'h0 ;
      u0_if.rxdata <= #1 'h0 ;
    end 
  endtask 

endclass
