class u0_uvc extends uvm_env;
  
  function new (string name="u0_uvc", uvm_component parent);
    super.new(name, parent);
  endfunction 

  `uvm_component_utils(u0_uvc)

  // u0_tx_scoreboard tx_scbd;

  u0_agent agnt_h;
  uart_dut_agent  dut_agnt_h;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt_h  = u0_agent::type_id::create("agnt_h", this);    
    dut_agnt_h  = uart_dut_agent::type_id::create("dut_agnt_h", this);    
    // tx_scbd = u0_tx_scoreboard::type_id::create("tx_scbd", this);    
  endfunction 

  function void connect_phase(uvm_phase phase);
    // agnt_h.mon_h.tx_mon_port.connect(tx_scbd.tx_uart);
  endfunction 

endclass 
