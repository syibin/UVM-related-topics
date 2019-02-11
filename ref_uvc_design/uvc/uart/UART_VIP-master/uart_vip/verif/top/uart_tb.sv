class u0_tb extends uvm_env;

  // UVC components

  // Scoreboard instance. Connect scoreboard and monitor here. 
  u0_tx_scoreboard tx_scbd;

  // Virtual Sequencer instance 

  u0_vsequencer   u0_vseqr;

  // UART UVC
  u0_uvc uvc_h;

  `uvm_component_utils(u0_tb)

  function new(string name="u0_tb", uvm_component parent);
    super.new(name, parent);
  endfunction 

  // Build UVCs here
  extern virtual function void build_phase(uvm_phase phase);
  // Connect Monitors and SB here.
  // Connect Virtual sequencer with the sequencer
  extern virtual function void connect_phase(uvm_phase phase);
    
endclass 

function void u0_tb::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // u0_seqr is a sequencer handle in Vseqr
  u0_vseqr.u0_seqr = uvc_h.agnt_h.sqr_h;
  uvc_h.agnt_h.mon_h.tx_mon_port.connect(tx_scbd.tx_uart);
  uvc_h.dut_agnt_h.dut_mon_h.dut_mon_port.connect(tx_scbd.rx_uart);
endfunction 

function void u0_tb::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (uvc_h == null)
  uvc_h = u0_uvc::type_id::create("uvc_h",this);
  u0_vseqr = u0_vsequencer::type_id::create("u0_vseqr", this);
  tx_scbd = u0_tx_scoreboard::type_id::create("tx_scbd", this); 
  // Instantiate SB here
endfunction 



