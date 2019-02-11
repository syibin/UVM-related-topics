class uart_dut_agent extends uvm_agent;
  
  `uvm_component_utils(uart_dut_agent)   // Not using uvm_active_passive_enum

  uart_dut_monitor  dut_mon_h;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dut_mon_h = uart_dut_monitor::type_id::create("uart_dut_monitor", this);
  endfunction 


endclass 
