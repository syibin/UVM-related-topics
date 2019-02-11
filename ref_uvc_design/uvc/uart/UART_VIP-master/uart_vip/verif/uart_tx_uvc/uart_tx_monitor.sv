class u0_monitor extends uvm_monitor;
  
  `uvm_component_utils(u0_monitor)

  virtual u0if u0_if;
  
  real t_pos;
  real clk_period; 
  real fosc ; 
  real baud_rate ; 
  int  fosc_int;
  int  UBBRn; 

  u0_xtn       tx_mon_data;  // To collect transmitted data

  uvm_analysis_port #(u0_xtn) tx_mon_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    tx_mon_port = new("tx_mon_port",this);
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("U0_MONITOR", " THIS IS A BUILD PHASE", UVM_LOW)
    if(!uvm_config_db #(virtual u0if)::get(this,"","u0_if", u0_if)) begin
        `uvm_fatal("U0_MONITOR", "UART interface not found")
    end
  endfunction

  task run_phase(uvm_phase phase);
    tx_mon_data  = u0_xtn::type_id::create("tx_mon_data", this);
    forever  begin                            // Careful here
      fork 
      collect_data();
      join
    end 
  endtask 

  task collect_data();
    @(negedge u0_if.clk); // Collect data @ WR or RD
    tx_mon_data.write = u0_if.write;
    tx_mon_data.din   = u0_if.din  ;
    tx_mon_data.read  = u0_if.read ;
    tx_mon_data.addr  = u0_if.addr ;
    tx_mon_data.dout  = u0_if.dout ;
    // `uvm_info(get_type_name(), $sformatf("  write monitor transactions \n %s", tx_mon_data.sprint()), UVM_LOW)
    if(u0_if.addr == 'hc0)   write_UCRSnA();
    if(u0_if.addr == 'hc1)   write_UCRSnB();
    if(u0_if.addr == 'hc2)   write_UCRSnC();
    if(u0_if.addr == 'hc4)   write_UBBR0H();
    if(u0_if.addr == 'hc5)   write_UBBR0L();
    tx_mon_port.write(tx_mon_data);
  endtask 

  task write_UCRSnA();
    tx_mon_data.RXCn    <= u0_if.din[7] ;
    tx_mon_data.TXCn    <= u0_if.din[6] ; 
    tx_mon_data.UDREn   <= u0_if.din[5] ;
    tx_mon_data.FEn     <= u0_if.din[4] ; 
    tx_mon_data.DORn    <= u0_if.din[3] ; 
    tx_mon_data.UPEn    <= u0_if.din[2] ; 
    tx_mon_data.U2Xn    <= u0_if.din[1] ; 
    tx_mon_data.MPCMn   <= u0_if.din[0] ;
  endtask 

  task write_UCRSnB();
    tx_mon_data.RXCIEn   <= u0_if.din[7] ;
    tx_mon_data.TXCIEn   <= u0_if.din[6] ; 
    tx_mon_data.UDRIEn   <= u0_if.din[5] ;
    tx_mon_data.RXENn    <= u0_if.din[4] ; 
    tx_mon_data.TXEn     <= u0_if.din[3] ; 
    tx_mon_data.UCSZ2n   <= u0_if.din[2] ; 
    tx_mon_data.RXB8n    <= u0_if.din[1] ; 
    tx_mon_data.TXB8n    <= u0_if.din[0] ;
  endtask 

  task write_UCRSnC();
    tx_mon_data.UMSELn   <= u0_if.din[7:6] ;
    tx_mon_data.UPMn     <= u0_if.din[5:4] ; 
    tx_mon_data.USBSn    <= u0_if.din[3]   ;
    tx_mon_data.UCSZn    <= u0_if.din[2:1] ; 
    tx_mon_data.UCPOLn   <= u0_if.din[0]   ; 
  endtask 

  task write_UBBR0H();
    tx_mon_data.UBBRn[11:8]   <= u0_if.din[3:0] ;
  endtask 

  task write_UBBR0L();
    tx_mon_data.UBBRn[7:0]   <= u0_if.din[7:0] ;
  endtask 

  // task baud_rate_cal();
  //   @(posedge clk) t_pos = $time;
  //   @(posedge clk) clk_period = ($time - t_pos);
  //   fosc = (1000000000/clk_period);
  //   $cast(fosc_int, fosc);        // This is required, as real/real is not allowed. 
  //   $cast(UBBRn, tx_mon_data.UBBRn);
  //   wait(u0_if.addr == 'hc0)
  //   baud_rate = u0_if.din[1] ? (2*(fosc_int/(16*(UBBRn + 1)))):(fosc_int/(16*(UBBRn + 1)));
  //   // $display("Fosc  %f , baud %f  %t", fosc, baud, $time);
  // endtask 

endclass 
