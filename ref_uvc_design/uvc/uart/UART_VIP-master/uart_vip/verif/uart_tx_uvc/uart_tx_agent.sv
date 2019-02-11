class u0_agent extends uvm_agent;
  
  `uvm_component_utils_begin(u0_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  u0_driver    drvr_h;
  u0_monitor   mon_h;
  u0_sequencer sqr_h;
 
  uvm_active_passive_enum is_active;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    is_active = UVM_ACTIVE;
    mon_h = u0_monitor::type_id::create("u0_monitor", this);
    if (is_active == UVM_ACTIVE) begin
      drvr_h = u0_driver::type_id::create("u0_driver", this);
      sqr_h  = u0_sequencer::type_id::create("u0_sequencer", this);
    end 
  endfunction 

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      drvr_h.seq_item_port.connect(sqr_h.seq_item_export);
  endfunction

endclass 
