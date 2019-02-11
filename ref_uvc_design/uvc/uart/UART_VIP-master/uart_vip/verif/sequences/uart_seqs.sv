class u0_base_seq extends uvm_sequence #(u0_xtn);
  
  `uvm_declare_p_sequencer (u0_sequencer)

  u0_tb  tb_cfg;

  function new(string name= "u0_base_seq");
    super.new(name);
  endfunction 

  `uvm_object_utils(u0_base_seq)

  virtual task pre_body();
    starting_phase.raise_objection(this);
  endtask 

  virtual task post_body();
    starting_phase.drop_objection(this);
  endtask 

endclass 

class u0_initialization extends u0_base_seq ;

  `uvm_object_utils(u0_initialization)

  u0_xtn          xtn_h;
  bit             enable;
  logic [7:0]     din ;  


  function new(string name = "u0_initialization");
    super.new(name);
  endfunction 

  virtual task body();                // Was calling start_item and finish_item here. bad style. Spent lot of hours in debugging this. Solution: Put start and finish where txns are driven.
    u0_initialize(2'b00 , 0)   ; // , 0);
    u0_initialize(2'b01 , 'hc5); // , 0);             // BRR0H
    u0_initialize(2'b01 , 'hc4); // , 'h09);          // BRR0L. Baud rate set
    u0_initialize(2'b01 , 'hc1); // , 'h08);          // CSR0B. CSR0B. Txen, Rxen
    u0_initialize(2'b01 , 'hc2); // , 'h06);          // CSR0C. Async UART, Parity, Stop bits, Frame size.
    u0_initialize(2'b01 , 'hc0); // , 'h02);          // CSR0A. Data Empty register, Parity Error, Transmission speed.
    u0_read (2'b10 , 'hc0);
    // u0_initialize(2'b01 , 'hc6, 'h24);
  endtask 

  // Task to drive a uart initialization block
  // task u0_initialize( logic [1:0] cmd, logic [7:0] addr, logic [7:0] data);
  task u0_initialize( logic [1:0] cmd, logic [7:0] addr);
    bit [3:0]   ubrrh;
    bit [7:0]   ubrrl;
    bit [0:0]   stop_bit;
    bit [2:0]   char_size;
    bit [1:0]   par_mode ;
    bit [0:0]   trans_speed;    // U2Xn
    xtn_h = u0_xtn::type_id::create("xtn_h");
    start_item(xtn_h);
    // this.din                       <= data;
    if (cmd == 1) begin 
      {xtn_h.read, xtn_h.write}    <= 2'b01;
      xtn_h.addr                   <= addr;
      if (addr == 'h00) begin
        xtn_h.din                    <= 'h0 ;
      end 
      if (addr == 'hc5) begin
        xtn_h.din                    <= 'h0;
      end 
      if (addr == 'hc4) begin
        xtn_h.din                    <= 'h09;
      end 
      if (addr == 'hc1) begin
        char_size[2]  = $urandom_range(0,1);
        xtn_h.din                    <= 'h08;
      end 
      if (addr == 'hc2) begin
        par_mode  = $urandom_range(2,3);
        stop_bit  = $urandom_range(0,1);
        char_size = $urandom_range(3,3);
        xtn_h.din                    <= { 2'b00, par_mode, stop_bit, char_size[1:0], 1'b0 };
      end 
      if (addr == 'hc0) begin
        trans_speed = $urandom; 
        xtn_h.din                    <= {6'b00_0000,trans_speed,1'b0} ;
      end 
    end 
    // if(addr == 'hc0)   write_UCRSnA(din );
    finish_item(xtn_h);
  endtask 

  // task write_UCRSnA(input logic [7:0] data);
  //   xtn_h.RXCn    <= din[7] ;
  //   xtn_h.TXCn    <= din[6] ; 
  //   xtn_h.UDREn   <= din[5] ;
  //   xtn_h.FEn     <= din[4] ; 
  //   xtn_h.DORn    <= din[3] ; 
  //   xtn_h.UPEn    <= din[2] ; 
  //   xtn_h.U2Xn    <= din[1] ; 
  //   xtn_h.MPCMn   <= din[0] ;
  //   $display("xtn_h.U2Xn  %m",xtn_h.U2Xn ); // This doesnt work here.
  //   Better place would be a monitor. 
  // endtask 

  task u0_read(logic [1:0] cmd, logic [7:0] addr);
    xtn_h = u0_xtn::type_id::create("xtn_h");
    start_item(xtn_h);
    if (cmd == 2) begin 
      {xtn_h.read, xtn_h.write}    <= 2'b10;
      xtn_h.addr                   <= addr ;
    end 
    finish_item(xtn_h);
  endtask 

endclass 

class u0_wr_seq extends u0_base_seq;

  function new(string name = "u0_wr_seq");
    super.new(name);
  endfunction 

  `uvm_object_utils(u0_wr_seq)

  virtual task body();
   // write_dut; 
    `uvm_do_with(req, { write == 1; addr == 8'hc6; din inside {[00:99]}; read == 0;
                         })
  endtask 

  task write_dut(); //( logic [1:0] cmd, logic [7:0] addr, logic [7:0] data);
    xtn_h = u0_xtn::type_id::create("xtn_h");
    start_item(xtn_h);
      {xtn_h.read, xtn_h.write}    <= 2'b01;
      xtn_h.addr                   <= 8'hc6; 
      xtn_h.din                    <= $urandom;
    finish_item(xtn_h);
  endtask 

endclass

class u0_rd_seq extends u0_base_seq;

  function new(string name = "u0_rd_seq");
    super.new(name);
  endfunction 

  `uvm_object_utils(u0_rd_seq)

  virtual task body();
    // read_dut(); 
    `uvm_do_with(req, { write == 0; addr == 8'hc0; read == 1;
                        })
  endtask 

  task read_dut(); // (logic [1:0] cmd, logic [7:0] addr);
    xtn_h = u0_xtn::type_id::create("xtn_h");
    start_item(xtn_h);
      {xtn_h.read, xtn_h.write}    <= 2'b10;
      xtn_h.addr                   <= 8'hc0; //addr ;
    finish_item(xtn_h);
  endtask 



endclass 

// class u0_rand_seq extends u0_base_seq;
// 
//   function new(string name = "u0_rand_seq");
//     super.new(name);
//   endfunction 
// 
//   `uvm_object_utils(u0_rand_seq)
// 
//   u0_wr_seq wr_h;
//   u0_rd_seq rd_h;
// 
// 
//   virtual task body();
//     `uvm_create(wr_h)
//     assert(wr_h.randomize());
//     // `uvm_do_with(req, { write == 1; addr == 'hc6; din inside {[00:90]}; read == 0;
//     //                     })
//   endtask 
// 
// endclass 
