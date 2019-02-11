`ifndef APB_SEQR_SVH
`define APB_SEQR_SVH
class apb_seqr extends uvm_sequencer#(apb_seq_item);
  
  `uvm_component_utils(apb_seqr)
  
  virtual apb_uart_bridge_if apb_if;
  bit end_stimulus = 0;
  
  function new (string name = "apb_seqr", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_uart_bridge_if)::get(this,"","dut_vif",apb_if))
      `uvm_error ("Build Phase","Interface Retrieval failed")    
  endfunction
  
  task wait_clocks(int clocks);
    repeat(clocks) @(apb_if.PCLK);
  endtask
  
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
	wait_clocks(10000);
	end_stimulus = 1;
  endtask
  
endclass
`endif