module i2c_m(
	input logic clk,
	input logic rst,
	input logic en,
	input logic [6:0] addr,
	input logic rw,
	input logic [7:0] data_wr,
	output logic [7:0] data_r,
	output logic ack_error,
	output logic busy,
	inout logic scl,
	inout logic sda
);	

  //Define states
  localparam bgin = 0,
	     rdy = 1,
	     start = 2,
	     transaddr = 3,
	     r_ack1 = 4,
	     rd = 5,
	     wr = 6,
	     s_ack = 7,
	     r_ack2 = 8,
	     nxt = 9,
	     stop = 10,
		 wait_low = 11;

  logic float_scl, float_sda;
  logic out_scl, out_scl_in, out_sda;
  logic in_sda;
  logic slower_clk, new_clk;
  logic ack_rcvd, ack_rcvd2;
  logic mv_ack;

  logic [6:0] new_addr, curr_addr, addr_in;

  logic [1:0] sB;
  logic [4:0] time_wait;
  logic [4:0] scl_counter;    //This is 24, so it takes 12 cycles for low, 12 cycles for high

  assign sda = float_sda ? 1'bZ : out_sda;
  assign scl = float_scl ? 1'bZ : out_scl;

  //States
  logic [3:0] state, next_state;

  //Counter for the slower_clk
  logic [5:0] cnt_clk, cnt_negclk;

  logic [3:0] addr_cnt, rddata_cnt, wrdata_cnt;
 
  always_comb begin
    if (sB == 1) begin
      addr_in = addr;
    end
    else if (sB == 0) begin
      addr_in = 0;
    end
    else begin
      addr_in = curr_addr;
    end
  end

  dff #(7) dff_address (
          .d(addr_in),
          .clk(clk),
          .q(curr_addr),
          .rst(rst)
  );

  i2c_s slave1(
		  .SDA(sda),
		  .SCL(scl),	
		  .rst(rst)
  );
 
  always_ff @ (posedge clk) begin
    if (~rst) begin
      busy <= 0;
      float_sda <= 1;
      float_scl <= 1;
      time_wait <= 24;
      scl_counter <= 23;
	  addr_cnt <= 8;
    end
    else begin
      case (state)
      bgin: begin //0
	    //Set the out_scl to 1 initially as well
	    float_scl <= 0;
	    out_scl <= 1;

	    //Set the out_sda to 1 initially
	    float_sda <= 0;
	    out_sda <= 1;
	  end
	  rdy: begin //1
	    if (en == 1) begin
	      busy <= 1;
	      float_sda <= 0;
	      //Set to 0 so that in the next cycle the start is set
	      out_sda <= 0;
        end
	    else begin
          busy <= 0;
        end
	  end
      wait_low: begin  //11
        //Here, you tick off the time_wait. You want the SDA to be low for
        //a short period of time
        if (time_wait != 0) time_wait <= time_wait - 1;
        //If the time_wait is 0, then you set the out_scl to be 0 so that in the next cycle
        //it starts off as 0
        else begin 
		  out_scl <= ~out_scl;
		  out_sda <= curr_addr[addr_cnt-2];
		  addr_cnt <= addr_cnt - 1;
		end
      end
      //This starts by transmitting the address
	  start: begin  //2
        if (scl_counter == 0) begin
		  scl_counter <= 23;
          out_scl <= ~out_scl;
          //If your addr = 1, then the next thing on SDA needs to be a RW (0:write, 1:read) from master to slave
		  if (addr_cnt == 1) begin
            out_sda <= 0; //Say we are telling slave to read from master
		  end
		  else begin
		    out_sda <= curr_addr[addr_cnt-2];
          end
		  addr_cnt <= addr_cnt - 1;
		end
        else scl_counter <= scl_counter - 1;
        if (scl_counter == 12) begin
          out_scl <= ~out_scl;
        end
        if (addr_cnt == 0 && scl_counter == 0) begin
          //Now you have gone through the entire address, and you need a response from the slave
          addr_cnt <= 9;
		  float_sda <= 1;
        end
	  end
      r_ack1: begin //4
		//At this point, you still need to wait 1 cycle for scl (for the last sda_out)
        if (scl_counter == 12) begin
          out_scl <= ~out_scl;
        end
        if (scl_counter == 0) begin
          out_scl <= ~out_scl;
		  scl_counter <= 23;
        end 
		else scl_counter <= scl_counter - 1;
      end
      endcase
    end
  end

  //State transition at *
  always_comb begin
    unique case (state)
      bgin: begin  //0
        sB = 0;
        next_state = rdy;
      end
      rdy: begin //1
        if (en == 1) begin 
          sB = 1;
          next_state = wait_low;
        end
        else next_state = rdy;
      end	
	  wait_low: begin    //11
        //In this state, wait for a couple of clock ticks for SDA being low before 
        //toggling the scl
        if (time_wait == 0) begin 
          next_state = start;
          sB = 2;
        end
        else begin 
          next_state = wait_low;
		end
	  end
      start: begin  //2
        next_state = start;
        if (addr_cnt == 0 && scl_counter == 0) begin
          next_state = r_ack1;
        end
      end
	  r_ack1: begin //4
	    next_state = r_ack1;
	  end
    endcase
  end

  //Flip Flop for state
  always_ff @ (posedge clk) begin
    if (~rst) begin
      state <= bgin;
    end
    else begin
      state <= next_state;
    end
  end

endmodule:i2c_m
