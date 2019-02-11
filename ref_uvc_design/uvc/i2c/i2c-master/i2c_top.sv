
//-------------------------------------------
// Top level Test module
//  Includes all env component and sequences files 
//-------------------------------------------
`include "i2c_m.sv"
`include "i2c_s.sv"
`include "dff.sv"

//--------------------------------------------------------
//Top level module that instantiates  just a physical apb interface
//No real DUT or APB slave as of now
//--------------------------------------------------------
module test;

   logic clk;
   logic rst;
   logic en;
   logic [6:0] addr;
   logic rw;
   logic [7:0] data_wr;
   logic [7:0] data_r;
   logic ack_error;
   logic busy;
   wire scl;
   wire sda;

    //Generate a clock
   always begin
      forever #5 clk = ~clk;
   end

   i2c_m my_i2c (
     .clk(clk),
     .rst(rst),
     .en(en),
     .addr(addr),
     .rw(rw),
     .data_wr(data_wr),
     .data_r(data_r),
     .ack_error(ack_error),
     .busy(busy),
     .scl(scl),
     .sda(sda)
   );

  initial begin
    rst = 0;
    clk = 0;
    en = 0;
    #10;
    rst = 1;
    en = 1;
    addr = 7'b1001101;
    rw = 1'b1;
    #10000;
    $finish();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
  end  
  
endmodule

