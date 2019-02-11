// this is the AHB master model

module ahbmst (
	hclk,
	hresetn,
	haddr_o,
	htrans_o,
	hwrite_o,
	hburst_o,
	hsize_o,
	hwdata_o,
	hready_i,
	hresp_i,
	hrdata_i,
	hbusreq_o,
	hgrant_i
);

input hclk;
input hresetn;
output [31:0] haddr_o;
output [1:0] htrans_o;
output hwrite_o;
output [2:0] hburst_o;
output [2:0] hsize_o;
output [31:0] hwdata_o;
input hready_i;
input [1:0] hresp_i;
input [31:0] hrdata_i;
output hbusreq_o;
input hgrant_i;

`include "ahb_def.v"

reg [31:0] haddr_out;
reg [1:0] htrans_out;
reg hwrite_out;
reg [2:0] hburst_out;
reg [2:0] hsize_out;
reg [31:0] hwdata_out;
reg hbusreq_out;

assign #OUT_DLY haddr_o = haddr_out;
assign #OUT_DLY htrans_o = htrans_out;
assign #OUT_DLY hwrite_o = hwrite_out;
assign #OUT_DLY hburst_o = hburst_out;
assign #OUT_DLY hsize_o = hsize_out;
assign #OUT_DLY hwdata_o = hwdata_out;
assign #OUT_DLY hbusreq_o = hbusreq_out;
wire #IN_DLY hready_in = hready_i;
wire [1:0] #IN_DLY hresp_in = hresp_i;
wire [31:0] #IN_DLY hrdata_in = hrdata_i;
wire #IN_DLY hgrant_in = hgrant_i;


// this is the data buffer
// it is 8-bit wide to accomodate 8/16-bit transfers
reg [7:0] data_array [AHBMST_BUF_DEPTH-1:0];
// this is the wait states buffer
reg [MAXWS-1:0] wait_states [AHBMST_BUF_DEPTH-1:0];

reg [31:0] cur_count;
reg [2:0] burst_mod;
reg [31:0] cur_addr;
reg last_dphase;
reg error_rcvd;
reg retry_rcvd;
reg [31:0] old_addr;
reg latch_data;
reg next_last_dphase;
reg store_rdata_reg;
reg comp_rdata_reg;

// generate pointer into the data array based on size and cur_count
wire [31:0] cur_pointer = (hsize_out == BUS_8) ? cur_count :
			((hsize_out == BUS_16) ? cur_count<<1 : cur_count<<2);

initial begin
	haddr_out <= DEFAULT_ADDR;
	htrans_out <= IDLE;
	hwrite_out <= READ;
	hsize_out <= DEFAULT_SIZE;
	hburst_out <= SINGLE;
	hwdata_out <= DEFAULT_WDATA;
	hbusreq_out <= LOW;

	cur_addr = 32'h0;
	old_addr = 32'h0;
	last_dphase = 1'b0;
	next_last_dphase = 1'b0;
	error_rcvd = 1'b0;
	retry_rcvd = 1'b0;
	cur_count = 32'h0;
	burst_mod = SINGLE;
	latch_data = 1'b0;
	comp_rdata_reg = 1'b0;
	store_rdata_reg = 1'b0;
end

// ahb_transfer(addr,size,burst,rn_w,count,store_rdata,comp_rdata,pass_failn)
// addr is the AHB address
// size is the transfer size
// burst is the burst type
// rn_w is read (low) or write (high)
// count is the number of beats (data phases), not the # of bytes or words
// store_rdata is whether to store data read in data_array
// comp_rdata is whether to compare read data with data_array and report error when data compare fails
// normally if you want to store data then no compare, if you want to compare then no store,
// 	but you can also want no store and no compare (just to test the flow)
// pass_failn is the return value of whether data compare fails
// data is read from data_array during write and stored in data_array during read
// wait states are stored in wait_states array
task ahb_transfer;
input [31:0] addr;
input [2:0] size;
input [2:0] burst;
input rn_w;
input [AHBMST_BUF_SIZE-1:0] count;
input store_rdata;
input comp_rdata;
output pass_failn;

reg result_thistime;
begin

	// remember some of the attributes
	store_rdata_reg <= store_rdata;
	comp_rdata_reg <= comp_rdata;
	// assume data comparison passes until it fails
	pass_failn = 1'b1;
	burst_mod = burst;

	// make sure HRESETn is high
	if (~hresetn) begin
		$display("Warning: AHB transfer requested at %t when hresetn is active, delayed", $time);
		@(posedge hresetn);
		repeat (10) @(posedge hclk);
	end

	// sanity checks

	// size must be 8/16/32-bit
	if ((size != BUS_8) && (size != BUS_16) && (size != BUS_32)) begin
		$display("Time = %t", $time);
		$display("Error: Only 8/16/32-bit transfer sizes are allowed.");
		repeat (10) @(posedge hclk);
		$finish;
	end

	// check if address is aligned with the transfer size
	if ((size == BUS_16) && (addr[0] != 1'b0) ||
	    (size == BUS_32) && (addr[1:0] != 2'b00)) begin
		$display("Time = %t", $time);
		$display("Error: Address must be aligned with the transfer size.");
		$display("\tFor 16-bit transfers, lowest bit of address must be 1'b0.");
		$display("\tFor 32-bit transfers, lowest two bits of address must be 2'b00.");
		repeat (10) @(posedge hclk);
		$finish;
	end

	// count cannot be 0
	if (count == 0) begin
		$display("Time = %t", $time);
		$display("Error: Transfer count must not be 0.");
		repeat (10) @(posedge hclk);
		$finish;
	end

	// check if count matches the burst type
	if ((burst == SINGLE) && (count != 1)) begin
		$display("Time = %t", $time);
		$display("Warning: SINGLE transfer must have a count of 1.");
		$display("\tChange burst type to INCR");
		burst_mod = INCR;
	end
	if (((burst == INCR4) || (burst == WRAP4)) && (count != 4)) begin
		$display("Time = %t", $time);
		$display("Warning: INCR4/WRAP4 transfer must have a count of 4.");
		$display("\tChange burst type to INCR");
		burst_mod = INCR;
	end
	if (((burst == INCR8) || (burst == WRAP8)) && (count != 8)) begin
		$display("Time = %t", $time);
		$display("Warning: INCR8/WRAP8 transfer must have a count of 8.");
		$display("\tChange burst type to INCR");
		burst_mod = INCR;
	end
	if (((burst == INCR16) || (burst == WRAP16)) && (count != 16)) begin
		$display("Time = %t", $time);
		$display("Warning: INCR16/WRAP16 transfer must have a count of 16.");
		$display("\tChange burst type to INCR");
		burst_mod = INCR;
	end

	// if INCR4/8/16, must not cross 1KB boundary
	// WRAP8/16/32 transfers won't cross 1KB boundary
	if (burst_mod == INCR4) begin
		if (size == BUS_8) begin
			if ((addr[9:2] == 8'hFF) && (addr[1:0] != 2'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 8-bit INCR4 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else if (size == BUS_16) begin
			if ((addr[9:3] == 7'h7F) && (addr[2:0] != 3'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 16-bit INCR4 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else begin	// size is BUS_32
			if ((addr[9:4] == 6'h3F) && (addr[3:0] != 4'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 32-bit INCR4 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end
	end else if (burst_mod == INCR8) begin
		if (size == BUS_8) begin
			if ((addr[9:3] == 8'h7F) && (addr[2:0] != 3'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 8-bit INCR8 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else if (size == BUS_16) begin
			if ((addr[9:4] == 6'h3F) && (addr[3:0] != 4'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 16-bit INCR8 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else begin	// size is BUS_32
			if ((addr[9:5] == 5'h1F) && (addr[4:0] != 5'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 32-bit INCR8 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end
	end else if (burst_mod == INCR16) begin
		if (size == BUS_8) begin
			if ((addr[9:4] == 6'h3F) && (addr[3:0] != 4'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 8-bit INCR16 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else if (size == BUS_16) begin
			if ((addr[9:5] == 5'h1F) && (addr[4:0] != 5'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 16-bit INCR16 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end else begin	// size is BUS_32
			if ((addr[9:6] == 4'hF) && (addr[5:0] != 6'h0)) begin
				$display("Time = %t", $time);
				$display("Warning: 32-bit INCR16 transfer from address %h will cross 1KB boundary.", addr);
				$display("\tChange burst type to INCR");
				burst_mod = INCR;
			end
		end
	end


	// current and old address register
	cur_addr = addr;
	old_addr = cur_addr;
	// reset counter to count data beats transferred
	cur_count = 32'h0;
	// reset retry/error flags
	retry_rcvd = 1'b0;
	error_rcvd = 1'b0;
	// reset last data phase flags
	last_dphase = 1'b0;
	next_last_dphase = 1'b0;

	// outside loop over the entire data transfers until all data transferred
	// each round is an AHB transaction
	// either all data transferred or error received makes it quit
	while ((cur_count != count) && ~error_rcvd) begin
		last_dphase = 1'b0;
		next_last_dphase = 1'b0;
		// start requesting bus and driving out all signals
		hbusreq_out <= HIGH;
		haddr_out <= cur_addr;
		hwrite_out <= rn_w;
		hsize_out <= size;
		// the assignment of hburst_out needs more scrutiny
		// once a transfer is force to split at the 1Kbyte boundary or
		//	is split/retried by the slave, the subsequent hburst_out
		//	needs to be screened
		// if INCR then stop at 1Kb boundary
		if ((burst_mod == INCR) && (addr_boundary(cur_addr, size) == 1'b1)) begin
			// at the boundary, change to SINGLE
			hburst_out <= SINGLE;
		// if only one more data beat then change to SINGLE
		end else if (cur_count == count-1) begin
			hburst_out <= SINGLE;
		// if INCR4/8/16 but has partially transferred some data, change to INCR
		// the assumption is that INCR won't cross 1Kb boundary which has already been checked
		end else if (((burst_mod == INCR4) || (burst_mod == INCR8) || (burst_mod == INCR16))
				&& (cur_count != 0)) begin
			hburst_out <= INCR;
		// if WRAP4/8/16 but has partially transferred some data, change to INCR/SINGLE
		end else if (((burst_mod == WRAP4) || (burst_mod == WRAP8) || (burst_mod == WRAP16))
				&& (cur_count != 0)) begin
			// use original addr to calculate
			hburst_out <= SINGLE;
		end else
			hburst_out <= burst_mod;
		htrans_out <= NONSEQ;
		if (rn_w)
			// put data out to hwdata_out
			hwdata_out <= put_out_data(size);
		// wait until granted and hready_in high (wait at least one clock)
		@(posedge hclk);
		while (~hgrant_in | ~hready_in) @(posedge hclk);
		// first addr phase is out, might be extended by hready_in low (wait at least one clock)
		// decide if time to lower hbusreq_out
		if (hburst_out == SINGLE)
			// current is last addresss phase, remove request
			// SINGLE transfers are the only possibility to remove request
			//	in the first address phase
			hbusreq_out <= LOW;
		@(posedge hclk);
		while (~hready_in) @(posedge hclk);
		// first addr phase complete

		// inner loop over the data phases of the AHB transaction
		// each round is a data phase (and an address phases too except the last one)
		// detect end-of-transfer conditions
		// either lose grant, or last data phase completed (hready_i high)
		//while (hgrant_in && ~last_dphase) begin
		while (~last_dphase) begin
			// update address while saving the old one
			old_addr = cur_addr;
			cur_addr = update_addr(cur_addr, burst_mod, size);
			// update address phase signals
			// check if already in last data phase
			// hburst_out is checked in case the first addr is already at the boundary
			//	but there are more data to be transferred
			// if cur_count=count-1 then last data to be transferred
			// next_last_dphase means address was at the boundary
			//	in the previous addr phase and the current data phase
			if ((hburst_out == SINGLE) || (cur_count == count-1) || next_last_dphase || ~hgrant_in) begin
				// already in last data phase, end of current transfer
				last_dphase = 1'b1;
				hbusreq_out <= LOW;
				htrans_out <= IDLE;
			end else begin
				// more data phases to come
				haddr_out <= cur_addr;
				htrans_out <= SEQ;
				// hwdata_o updated after seeing hready_i high
				// decide whether to remove request
				if (cur_count == count-2)
					hbusreq_out <= LOW;
			end
			// mark the current address as the last one in the burst
			if (addr_boundary(cur_addr, size)) begin
				// next data phase is the last one
				next_last_dphase = 1'b1;
				// remove request since already in the last address phase
				hbusreq_out <= LOW;
			end
			// wait for target response
			@(posedge hclk);
			// skip wait states
			while (~hready_in && (hresp_in == OKAY)) @(posedge hclk);
			if (hresp_in != OKAY) begin
				// 2-cycle response, last data phase
				last_dphase = 1'b1;
				// reverse the address
				cur_addr = old_addr;
				// remove the current address phase
				htrans_out <= IDLE;
				hbusreq_out <= LOW;
				if (hresp_in == ERROR) begin
					// ERROR response, no retry
					error_rcvd = 1'b1;
					$display("Time = %t", $time);
					$display("Error: An error response has been received at address %h", cur_addr);
				end else
					retry_rcvd = 1'b1;
				// make sure target is following the spec
				if (hready_in)
					$display("Error: Target is not doing 2-cycle response properly.");
				@(posedge hclk);
				if (~hready_in)
					$display("Error: Target is not doing 2-cycle response properly.");
				// delay for some time before retrying
				if (hresp_in != ERROR)
					repeat (DLY_B4_RETRY) @(posedge hclk);
			end else begin
				// normal completion of current data phase
				// process read data if read
				if (~rn_w)
					process_read_data(size, old_addr[1:0], result_thistime);
				// collect pass/fail status, result low/fail makes pass_failn low/fail
				pass_failn = pass_failn & result_thistime;
				// increment current counter
				cur_count = cur_count + 32'h1;
				// update hwdata if not last data phase
				if (~last_dphase & rn_w)
					// put data out to hwdata_out
					hwdata_out <= put_out_data(size);
			end
		end	// while, inner loop
	end	// while, outer loop
end
endtask // ahb_transfer

// task to process read data
// this must be called after seeing hready_in high and hresp_in == OKAY
task process_read_data;
input [2:0] size;
input [1:0] addr;
// result is high for comparison pass and low for failure
output result;
reg result0, result1, result2, result3;
begin
	result0 = 1'b1;
	result1 = 1'b1;
	result2 = 1'b1;
	result3 = 1'b1;
	result = 1'b1;
	if (size == BUS_8) begin
		// only get one byte, decide which byte lane from addr
		if (addr[1:0] == 2'b00)
			comp_store8(2'b00, hrdata_in[7:0], result0);
		else if (addr[1:0] == 2'b01)
			comp_store8(2'b00, hrdata_in[15:8], result0);
		else if (addr[1:0] == 2'b10)
			comp_store8(2'b00, hrdata_in[23:16], result0);
		else //if (addr[1:0] == 2'b11)
			comp_store8(2'b00, hrdata_in[31:24], result0);
	end else if (size == BUS_16) begin
		// get two bytes
		if (addr[1] == 1'b0) begin
			comp_store8(2'b01, hrdata_in[15:8], result0);
			comp_store8(2'b00, hrdata_in[7:0], result1);
		end else begin //if (addr[1] == 1'b1) begin
			comp_store8(2'b01, hrdata_in[31:24], result0);
			comp_store8(2'b00, hrdata_in[23:16], result1);
		end
	end else begin //if (size == BUS_32) begin
		// get all bytes
		comp_store8(2'b11, hrdata_in[31:24], result0);
		comp_store8(2'b10, hrdata_in[23:16], result1);
		comp_store8(2'b01, hrdata_in[15:8], result2);
		comp_store8(2'b00, hrdata_in[7:0], result3);
	end
	if ((comp_rdata_reg) & (~result0 | ~result1 | ~result2 | ~result3)) begin
		result = 1'b0;
	end
end
endtask // process_read_data

// task to compare/store a byte
task comp_store8;
input [1:0] cur_pointer_offset;
input [7:0] hrdata_in_byte;
// result is high for comparison pass and low for failure
output result;
reg result;

begin
	result = 1'b1;
	// compare data
	if ((comp_rdata_reg) && (data_array[cur_pointer + cur_pointer_offset] != hrdata_in_byte)) begin
		// compare failure, report
		result = 1'b0;
		$display("Time = %t", $time);
		// need to refine this address
		$display("Error: Data does not match at addr %h. Expected %h and received %h.",
			old_addr, data_array[cur_pointer + cur_pointer_offset], hrdata_in_byte);
	end
	if (store_rdata_reg)
		// store data
		data_array[cur_pointer + cur_pointer_offset] = hrdata_in_byte;
end
endtask // comp_store8


function addr_boundary;
input [31:0] addr;
input [2:0] size;
begin
	if (((size == BUS_8) && (addr[9:0] == 10'h3FF)) ||
	    ((size == BUS_16) && (addr[9:1] == 9'h1FF)) ||
	    ((size == BUS_32) && (addr[9:2] == 8'hFF)))
    		addr_boundary = 1'b1;
	else
		addr_boundary = 1'b0;
end
endfunction

function [31:0] put_out_data;
input [2:0] size;
begin
	if (size == BUS_8) begin
		// put out the same 8-bit data on all 4 byte lanes
		put_out_data[31:24] = data_array[cur_count];
		put_out_data[23:16] = data_array[cur_count];
		put_out_data[15:8] = data_array[cur_count];
		put_out_data[7:0] = data_array[cur_count];
	end else if (size == BUS_16) begin
		// repeat 16-bit data
		put_out_data[31:24] = data_array[(cur_count<<1)+1];
		put_out_data[23:16] = data_array[(cur_count<<1)];
		put_out_data[15:8] = data_array[(cur_count<<1)+1];
		put_out_data[7:0] = data_array[(cur_count<<1)];
	end else begin		// size == BUS_32
		// put out all 4 bytes
		put_out_data[31:24] = data_array[(cur_count<<2)+3];
		put_out_data[23:16] = data_array[(cur_count<<2)+2];
		put_out_data[15:8] = data_array[(cur_count<<2)+1];
		put_out_data[7:0] = data_array[(cur_count<<2)];
	end
end
endfunction

function [31:0] update_addr;
input [31:0] addr;
input [2:0] burst;
input [2:0] size;

reg [5:0] addr_inc;

begin
	// if SINGLE or INCR* just increment address according to size
	if ((burst == SINGLE) || (burst == INCR) || (burst == INCR4) ||
	    (burst == INCR8) || (burst == INCR16)) begin
		if (size == BUS_8) update_addr = addr + 32'h1;
		if (size == BUS_16) update_addr = addr + 32'h2;
		if (size == BUS_32) update_addr = addr + 32'h4;
	end else if (burst == WRAP4) begin
		if (size == BUS_8) begin
			addr_inc = addr[5:0] + 6'h1;
			// only the lowest 2 bits will increment
			update_addr = {addr[31:2], addr_inc[1:0]};
		end else if (size == BUS_16) begin
			addr_inc = addr[5:0] + 6'h2;
			// only the lowest 3 bits will increment
			update_addr = {addr[31:3], addr_inc[2:0]};
		end else if (size == BUS_32) begin
			addr_inc = addr[5:0] + 6'h4;
			// only the lowest 4 bits will increment
			update_addr = {addr[31:4], addr_inc[3:0]};
		end
	end else if (burst == WRAP8) begin
		if (size == BUS_8) begin
			addr_inc = addr[5:0] + 6'h1;
			// only the lowest 3 bits will increment
			update_addr = {addr[31:3], addr_inc[2:0]};
		end else if (size == BUS_16) begin
			addr_inc = addr[5:0] + 6'h2;
			// only the lowest 4 bits will increment
			update_addr = {addr[31:4], addr_inc[3:0]};
		end else if (size == BUS_32) begin
			addr_inc = addr[5:0] + 6'h4;
			// only the lowest 5 bits will increment
			update_addr = {addr[31:5], addr_inc[4:0]};
		end
	end else begin		// burst == WRAP16
		if (size == BUS_8) begin
			addr_inc = addr[5:0] + 6'h1;
			// only the lowest 4 bits will increment
			update_addr = {addr[31:4], addr_inc[3:0]};
		end else if (size == BUS_16) begin
			addr_inc = addr[5:0] + 6'h2;
			// only the lowest 5 bits will increment
			update_addr = {addr[31:5], addr_inc[4:0]};
		end else if (size == BUS_32) begin
			addr_inc = addr[5:0] + 6'h4;
			// only the lowest 6 bits will increment
			update_addr = {addr[31:6], addr_inc[5:0]};
		end
	end
end
endfunction

endmodule
