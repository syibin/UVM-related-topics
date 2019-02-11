class uart_dut_monitor extends uvm_monitor;
  
  `uvm_component_utils(uart_dut_monitor)

  virtual  u0if u0_if;

  u0_xtn   dut_data;   // To collect data coming from the DUT output pins.
  real falling_edge, rising_edge, baud_time, baud_rate;

  uvm_analysis_port  #(u0_xtn)  dut_mon_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dut_mon_port = new("dut_mon_port", this);
  endfunction 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("UART_DUT_MON", " Inside build phase" ,UVM_LOW)
    if(!uvm_config_db #(virtual u0if)::get(this,"","u0_if", u0_if)) begin 
       `uvm_fatal("UART_DUT_MON"," UART interface not found")
    end 
  endfunction 

  task run_phase(uvm_phase phase);
    dut_data = u0_xtn::type_id::create("dut_data", this);
    forever begin 
      // # baud_time;      // Collecting DUT data @baud_time 
      collect_data();
    end
  endtask 

  task collect_data();   // Data from DUT
    @(negedge u0_if.clk);
    if(!u0_if.rst) begin
      dut_data.txdata  = u0_if.txdata  ;   // Start bit. 
      dut_data.txir    = u0_if.txir    ;   // Transmitter interrupt request
      dut_data.txack   = u0_if.txack   ;   // Ack for txir from CPU
      dut_data.tcack   = u0_if.tcack   ;   // Ack for transmitter complete
      dut_data.tcir    = u0_if.tcir    ;   // Transmitter complete IR
      // if(u0_if.write) begin
        dut_mon_port.write(dut_data);
        // `uvm_info("DUT_MONITOR", $sformatf("SCBD DUT monitor transactions \n %s", dut_data.sprint()), UVM_LOW) 
      // end 
    end 
  endtask 

  // task baud_time_cal();
  //   wait (!u0_if.txdata);
  //   falling_edge = $time;
  //   $display(" falling time  %t", $time);
  //   wait(u0_if.txdata);
  //   rising_edge = $time;
  //   baud_time = rising_edge - falling_edge;
  //   $display(" TIME %t    baud_time %d ", $time, baud_time);
  //   baud_rate = (10**9)/(baud_time); 
  //   $display(" TIME %t    baud      %d ", $time, baud_rate);
  // endtask 

endclass 
