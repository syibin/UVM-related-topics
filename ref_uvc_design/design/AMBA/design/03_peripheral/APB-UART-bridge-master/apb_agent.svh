`ifndef APB_AGENT_SVH
`define APB_AGENT_SVH
class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  apb_seqr seqr;
  apb_drvr drvr;

  function new(string name = "apb_agent",uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      seqr = apb_seqr::type_id::create("apb_seqr",this);
      drvr = apb_drvr::type_id::create("apb_drvr",this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      drvr.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass
`endif
