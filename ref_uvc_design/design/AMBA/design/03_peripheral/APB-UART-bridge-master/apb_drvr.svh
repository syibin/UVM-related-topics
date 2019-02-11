`ifndef APB_DRIVER_SVH
`define APB_DRIVER_SVH
class apb_drvr extends uvm_driver#(apb_seq_item);
  `uvm_component_utils(apb_drvr)
  
  virtual apb_uart_bridge_if apb_if;
  
  function new (string name = "apb_drvr", uvm_component parent);
    super.new(name,parent);
  endfunction 

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_uart_bridge_if)::get(this,"","dut_vif",apb_if))
      `uvm_error ("Build Phase","Interface Retrieval failed")    
  endfunction

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    apb_if.PRESETn <= 0;
    repeat ($urandom_range(50,10)) @(apb_if.apb_cb);
    apb_if.PRESETn <= 1;

    forever begin
      @(m_if.mux_cb)
      apb_if.PENABLE <= 1'b0;      
      apb_if.PSEL <= 1'b0;
      seq_item_port.get_next_item(req);      
      apb_if.PADDR <= req.addr;
      apb_if.PWRITE <= req.write;
      apb_if.PSEL <= 1'b1;
      if (req.write) begin
        apb_if.PWDATA <= req.data;
      end
      @(m_if.mux_cb)
      apb_if.PENABLE <= 1'b1;
      wait(apb_if.PREADY);
      seq_item_port.item_done();
    end
  endtask  
  
endclass
`endif
