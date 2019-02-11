// this is the AHB slave model

module ahbslv (
	hclk,
	hresetn,
	hsel_i,
	haddr_i,
	htrans_i,
	hwrite_i,
	hburst_i,
	hsize_i,
	hwdata_i,
	hready_o,
	hresp_o,
	hrdata_o,

	hready_i
);

input hclk;
input hresetn;
input hsel_i;
input [31:0] haddr_i;
input [1:0] htrans_i;
input hwrite_i;
input [2:0] hburst_i;
input [2:0] hsize_i;
input [31:0] hwdata_i;
output hready_o;
output [1:0] hresp_o;
output [31:0] hrdata_o;
input hready_i;

`include "ahb_def.v"

reg hready_out;
reg [1:0] hresp_out;
reg [31:0] hrdata_out;

assign #OUT_DLY hready_o = hready_out;
assign #OUT_DLY hresp_o = hresp_out;
assign #OUT_DLY hrdata_o = hrdata_out;
wire #IN_DLY hsel_in = hsel_i;
wire [31:0] #IN_DLY haddr_in = haddr_i;
wire [1:0] #IN_DLY htrans_in = htrans_i;
wire #IN_DLY hwrite_in = hwrite_i;
wire [2:0] #IN_DLY hburst_in = hburst_i;
wire [2:0] #IN_DLY hsize_in = hsize_i;
wire [31:0] #IN_DLY hwdata_in = hwdata_i;
wire #IN_DLY hready_in = hready_i;


// this is the memory mapped to AHB
// it is 8-bit wide for easy handling
reg [7:0] slave_mem [AHBSLV_BUF_DEPTH-1:0];

// these are the states of the slave state machine
parameter AHBSLV_IDLE = 3'h0;
//parameter AHBSLV_READ = 3'h1;
//parameter AHBSLV_WRITE = 3'h2;
parameter AHBSLV_RETRY = 3'h3;
parameter AHBSLV_ERROR = 3'h4;

reg [2:0] ahbslv_state;

// this buffer is to hold the # of wait states of each data phase
reg [MAXWS-1:0] Delaybuffer [AHBSLV_RESPBUF_DEPTH-1:0];
// this buffer is to hold the response for each data phase
reg [1:0] Respbuffer  [AHBSLV_RESPBUF_DEPTH-1:0];
// this buffer is to hold the # of times the Respbuffer response should be applied
// after the limit is reached the response is always OKAY
// a value of 0 means always apply Respbuffer response
reg [MAXWS-1:0] RespLimitbuffer  [AHBSLV_RESPBUF_DEPTH-1:0];
// this buffer counts the # of times the Respbuffer response has beena applied
reg [MAXWS-1:0] RespTimesbuffer  [AHBSLV_RESPBUF_DEPTH-1:0];

wire [AHBSLV_BUF_SIZE-1:0] haddr_in_os = haddr_in[AHBSLV_BUF_SIZE-1:0];
reg [AHBSLV_BUF_SIZE-1:0] haddr_os_save;
reg [2:0] hsize_save;
reg hwrite_save;

integer cur_dphase;
reg waited;
reg capture_wdata;

// generate correct byte enables
wire [3:0] be;
assign be[0] = ((hsize_save==3'b000) && (haddr_os_save[1:0]==2'b00)) ||	// byte
		((hsize_save==3'b001) && (haddr_os_save[1]==1'b0)) ||	// halfword
		(hsize_save==3'b010);					// word

assign be[1] = ((hsize_save==3'b000) && (haddr_os_save[1:0]==2'b01)) ||
		((hsize_save==3'b001) && (haddr_os_save[1]==1'b0)) ||
		(hsize_save==3'b010);

assign be[2] = ((hsize_save==3'b000) && (haddr_os_save[1:0]==2'b10)) ||
		((hsize_save==3'b001) && (haddr_os_save[1]==1'b1)) ||
		(hsize_save==3'b010);

assign be[3] = ((hsize_save==3'b000) && (haddr_os_save[1:0]==2'b11)) ||
		((hsize_save==3'b001) && (haddr_os_save[1]==1'b1)) ||
		(hsize_save==3'b010);

// write to memory in case of AHB write
always @(posedge hclk) begin
	// capture write data if told from previous clock cycle
	// always haddr_os_save
	if (capture_wdata) begin
		if (be[3]) slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2],2'b11}] <= hwdata_in[31:24];
		if (be[2]) slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2],2'b10}] <= hwdata_in[23:16];
		if (be[1]) slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2],2'b01}] <= hwdata_in[15:8];
		if (be[0]) slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2],2'b00}] <= hwdata_in[7:0];
	end
end

// main state machine
always @(negedge hresetn or posedge hclk) begin
	if (~hresetn) begin
		ahbslv_state <= AHBSLV_IDLE;
		cur_dphase <= 5'h0;
		hready_out <= 1'b1;
		hresp_out <= OKAY;
		hrdata_out <= DEFAULT_RDATA;
		haddr_os_save <= 0;
		hsize_save <= 3'h0;
		hwrite_save <= 1'b0;
		// this flag tells whether any wait state has been inserted
		waited <= 1'b0;
		// this flag tells to capture write data
		capture_wdata <= 1'b0;
	end else begin
		// clear capture write data flag
		capture_wdata <= 1'b0;

		case (ahbslv_state)
		AHBSLV_IDLE : begin

			// check for transactions
			if (hsel_in && hready_in && (htrans_in == NONSEQ)) begin
				// selected as target, beginning of a new transfer
				// record transaction info
				// don't care about hburst_in
				haddr_os_save <= haddr_in_os;
				hsize_save <= hsize_in;
				hwrite_save <= hwrite_in;
				// set default response
				hready_out <= 1'b1;
				hresp_out <= OKAY;
				hrdata_out <= DEFAULT_RDATA;
				// reset data phase counter
				cur_dphase <= 5'h0;
				// check to see if there should be wait states
				if (Delaybuffer[0]) begin
					// insert wait states
					hready_out <= 1'b0;
					// set waited flag
					waited <= 1'b1;
					repeat (Delaybuffer[0]) @(posedge hclk);
				end
				// check to see if it should issue retry
				// also if limit is 0 or limit has been reached
				if ((Respbuffer[0] == RETRY) &&
				   ((RespLimitbuffer[0] == 0) ||
				    (RespTimesbuffer[0] < RespLimitbuffer[0]))) begin
					// issue retry, 2-cycle response
					ahbslv_state <= AHBSLV_RETRY;
					hready_out <= 1'b0;
					hresp_out <= RETRY;
					if (RespLimitbuffer[0])
						RespTimesbuffer[0] <= RespTimesbuffer[0] + 1;
				end else if (Respbuffer[0] == ERROR) begin
					// issue error
					ahbslv_state <= AHBSLV_ERROR;
					hready_out <= 1'b0;
					hresp_out <= ERROR;
				end else begin
					// if not retry/error it is always okay
					hready_out <= 1'b1;
					hresp_out <= OKAY;
					// check if write or read
					if (waited ? hwrite_save : hwrite_in) begin
						// write, set flag to capture write data in the next cycle
						capture_wdata <= 1'b1;
					end else begin
						// read, provide the entire 32-bit, ignore the lowest two addr bits
						// waited selects between current address or saved address
						hrdata_out <= waited ?
							{ slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b11}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b10}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b01}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b00}] }
								:
							{ slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b11}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b10}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b01}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b00}] } ;
					end
					// increment the data phase counter (set to 1)
					cur_dphase <= 5'h1;
				end

			end else if (hsel_in && hready_in && (htrans_in == SEQ)
					&& (cur_dphase != 5'h0)) begin
				// selected as target, continuation of a previous transfer
				// record transaction info
				// don't care about hburst_in
				haddr_os_save <= haddr_in_os;
				hsize_save <= hsize_in;
				hwrite_save <= hwrite_in;
				// set default response
				hready_out <= 1'b1;
				hresp_out <= OKAY;
				hrdata_out <= DEFAULT_RDATA;
				// check to see if there should be wait states
				if (Delaybuffer[cur_dphase]) begin
					// insert wait states
					hready_out <= 1'b0;
					// set waited flag
					waited <= 1'b1;
					repeat (Delaybuffer[cur_dphase]) @(posedge hclk);
				end
				// check to see if it should issue retry
				// also if limit is 0 or limit has been reached
				if ((Respbuffer[cur_dphase] == RETRY) &&
				   ((RespLimitbuffer[cur_dphase] == 0) ||
				    (RespTimesbuffer[cur_dphase] < RespLimitbuffer[cur_dphase]))) begin
					// issue retry, 2-cycle response
					ahbslv_state <= AHBSLV_RETRY;
					hready_out <= 1'b0;
					hresp_out <= RETRY;
					if (RespLimitbuffer[cur_dphase])
						RespTimesbuffer[cur_dphase] <= RespTimesbuffer[cur_dphase] + 1;
				end else if (Respbuffer[cur_dphase] == ERROR) begin
					// issue error
					ahbslv_state <= AHBSLV_ERROR;
					hready_out <= 1'b0;
					hresp_out <= ERROR;
				end else begin
					// if not retry/error it is always okay
					hready_out <= 1'b1;
					hresp_out <= OKAY;
					// check if write or read
					if (waited ? hwrite_save : hwrite_in) begin
						// write, set flag to capture write data in the next cycle
						capture_wdata <= 1'b1;
					end else begin
						// read, provide the entire 32-bit, ignore the lowest two addr bits
						// waited selects between current address or saved address
						hrdata_out <= waited ?
							{ slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b11}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b10}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b01}],
							slave_mem[{haddr_os_save[AHBSLV_BUF_SIZE-1:2], 2'b00}] }
							:
							{ slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b11}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b10}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b01}],
							slave_mem[{haddr_in_os[AHBSLV_BUF_SIZE-1:2], 2'b00}] } ;
					end
					// increment the data phase counter
					// need to check if it is over the limit
					cur_dphase <= cur_dphase + 1;
				end

			end else if (hsel_in && hready_in && (htrans_in == BUSY)
					&& (cur_dphase != 5'h0)) begin
				// selected as target, not new transfer, master inserts wait states
				// keep current state, set default response
				// do not reset the data phase counter
				// stay in this state
				hready_out <= 1'b1;
				hresp_out <= OKAY;
				hrdata_out <= DEFAULT_RDATA;
			end else begin
				// not target or master wait state
				// stay in idle state
				hready_out <= 1'b1;
				hresp_out <= OKAY;
				hrdata_out <= DEFAULT_RDATA;
				// reset current phase
				cur_dphase <= 5'h0;
			end
		end

		AHBSLV_RETRY : begin
			// assert hready_out to signal end of data phase
			hready_out <= 1'b1;
			hresp_out <= RETRY;
			hrdata_out <= DEFAULT_RDATA;
			ahbslv_state <= AHBSLV_IDLE;
			// reset current phase
			cur_dphase <= 5'h0;
		end

		AHBSLV_ERROR : begin
			// assert hready_out to signal end of data phase
			hready_out <= 1'b1;
			hresp_out <= ERROR;
			hrdata_out <= DEFAULT_RDATA;
			ahbslv_state <= AHBSLV_IDLE;
			// reset current phase
			cur_dphase <= 5'h0;
		end

		endcase

		// reset waited flag
		waited <= 1'b0;
	end
end

integer i;

// initialize the buffers
initial begin
	for (i=0;i<AHBSLV_RESPBUF_DEPTH;i=i+1) begin
		// default is no wait state at all
		Delaybuffer[i] <= 0;
		// default is always OKAY
		Respbuffer[i] <= 0;
		// default is always use Respbuffer response (no timeout)
		RespLimitbuffer[i] <= 0;
		// reset counters
		RespTimesbuffer[i] <= 0;
	end
end

// task to set delay buffer
task set_delay;
input [MAXWS-1:0] dphase;
input [MAXWS-1:0] wait_states;
begin
	Delaybuffer[dphase] <= wait_states;
end
endtask

// task to set response buffer
task set_resp;
input [MAXWS-1:0] dphase;
input [1:0] response;
begin
	Respbuffer[dphase] <= response;
end
endtask

// task to set response limit buffer
// it also clears the response times buffer
task set_resp_limit;
input [MAXWS-1:0] dphase;
input [MAXWS-1:0] response_limit;
begin
	RespLimitbuffer[dphase] <= response_limit;
	RespTimesbuffer[dphase] <= 0;
end
endtask

endmodule
