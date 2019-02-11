module ahbarb(
	// clocks and resets
	hclk,
	hresetn,
	// requests
	hbusreqs,
	// address and control signals
	haddr,
	htrans,
	hburst,
	hresp,
	hready,
	// grant outputs
	hgrants,
	// mux selects
	hmaster,
	hmaster_wd
);

`include "ahb_def.v"

// clocks and resets
input hclk;	// ahb clock input
input hresetn;       // ahb poweron reset (active low)

parameter num_msts = 4;
parameter tout_value = 8'b0001_1111;

// requests
input [num_msts-1:0] hbusreqs;    // bus requests

// address and control signals
input [31:0] haddr;	// address
input [1:0] htrans;	// transfer type
input [2:0] hburst;	// burst information
input [1:0] hresp;	// transfer response
input hready;		// slave ready response

// grant outputs
output [num_msts-1:0] hgrants;     // grant for master 0
output [num_msts-1:0] hmaster;       // current granted master
output [num_msts-1:0] hmaster_wd;    // delayed version of hmaster for write data mux

// output declarations
reg    [3:0]  hmaster;
reg    [3:0]  hmaster_wd;

// arb state assignments
parameter     BUS_PARK = 1'b0;
parameter     BUS_CYC  = 1'b1;

// local declarations
reg arb_state;   // state vector for arbitration s/m
wire [num_msts-1:0] hbusreq_in;		// request bus contains all hbusreq_in
wire [num_msts-1:0] hgrants;		// grant bus going out
reg [num_msts-1:0] hgrants_out;		// grant bus reg
reg [num_msts-1:0] hgrants_d;		// one clock delayed grant bus
reg [3:0] bsize;	// burst length counter
reg [1:0] htrans_d;	// latched version of htrans
reg [8:0] timeout;	// timeout counter

assign #IN_DLY hbusreq_in = hbusreqs;
assign #OUT_DLY hgrants = hgrants_out;

// generation of master output
always @(posedge hclk) begin
   if(~hresetn) begin
      hmaster    <= 4'h0;
      hmaster_wd <= 4'h0;
   end
   else begin
      // change hmaster only after the hready is asserted
      if(hready) begin
         hmaster_wd <= hmaster;
         case(hgrants_out)
            // master 0
            4'b0001 : hmaster   <= 4'h0;
            // master 1
            4'b0010 : hmaster   <= 4'h1;
            // master 2
            4'b0100 : hmaster   <= 4'h2;
            // master 3
            4'b1000 : hmaster   <= 4'h3;
         endcase
      end
   end
end

// generation of previous htrans
always @(posedge hclk) begin
   if(~hresetn) begin
      htrans_d <= IDLE;
      hgrants_d <= 4'b0001;
   end
   else begin
      // latch the htrans on hready high
      if(hready) htrans_d <= htrans;
      hgrants_d <= hgrants_out;
   end
end

// arbitration state machine
always @(posedge hclk) begin
   if(~hresetn) begin
      hgrants_out    <= 4'b0001;
      bsize     <= 4'b0000;
      timeout   <= 0;
      arb_state <= BUS_PARK;
   end
   else begin
      case(arb_state)
         // bus parking state
         BUS_PARK: begin
            // current master started the bus cycle and is a burst
            if (hgrants_out != 0 && htrans == NONSEQ && hburst != SINGLE &&
                (hburst != INCR || ((hbusreq_in & hgrants_out) != 0))) begin
               arb_state <= BUS_CYC;
               timeout   <= tout_value;
               case(hburst)  // synopsys full_case parallel_case
                  WRAP4, INCR4  : bsize <= 3;  // burst size is 4
                  WRAP8, INCR8  : bsize <= 7;  // burst size is 8
                  default       : bsize <= 15; // burst size is 16
               endcase
            end
            // if the bus is IDLE wait for another clock if we just asserted grant
            else if(htrans == IDLE && hgrants_out != hgrants_d) begin
               hgrants_out <= hgrants_out;
            end
            // next grant
            else if(htrans != SEQ) begin
               // highest priority request
               casex(hbusreq_in)
                  4'bxxx1: hgrants_out <= 4'b0001;
                  4'bxx10: hgrants_out <= 4'b0010;
                  4'bx100: hgrants_out <= 4'b0100;
                  4'b1000: hgrants_out <= 4'b1000;
                  default: hgrants_out <= 4'b0010;
               endcase
            end
         end

         BUS_CYC: begin
            // check for next hbusreq_in at end of
            // a) the penultimate transfer (not a INCR transfer)
            // b) master is terminating the transfer by driving IDLE
            // c) master has removed the request for INCR transfer
            // d) timeout has occured
            // e) slave is terminating the transfer
            //if((hready && htrans_d != busy && 
            if((hready && 
                ((bsize == 2 && hburst != INCR) || htrans == IDLE ||
                 ((hbusreq_in & hgrants_out) == 0 && hburst == INCR))) || 
               (hready && timeout == 0) ||
               (hresp != OKAY && htrans != NONSEQ)) begin

               // highest priority request
               // make sure that we don't give the grant to the current
               // granted master for fairness
               casex(hbusreq_in & ~hgrants_out)
                  4'bxxx1 : hgrants_out <= 4'b0001;
                  4'bxx10 : hgrants_out <= 4'b0010;
                  4'bx100 : hgrants_out <= 4'b0100;
                  4'b1000 : hgrants_out <= 4'b1000;
                  default : hgrants_out <= 4'b0001;  // highest priority master
               endcase
               arb_state <= BUS_PARK;
            end
            // decrement the burst size on every response from slave for non busy cycle
            else if(hready & htrans_d != BUSY & htrans != NONSEQ) begin
               bsize <= bsize - 1;
            end
            // decrement the timeout counter on every clock
            if (timeout != 0) timeout <= timeout - 1;
         end
      endcase
   end
end

endmodule
