`ifndef APB_UART_ENV_SVH
`define APB_UART_ENV_SVH
class apb_uart_env extends uvm_env;
  `uvm_component_utils(apb_uart_env)
  apb_agent agent;

  function new(string name = "apb_uart_env", uvm_component parent= null);
    super.new(name,parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    agent = apb_agent::type_id::create("apb_agent",this);
  endfunction 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
endclass
`endif
