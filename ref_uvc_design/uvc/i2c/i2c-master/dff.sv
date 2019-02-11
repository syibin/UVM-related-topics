module dff 
	#(parameter bW=1)
(
	input logic [bW-1:0] d,
	input logic clk,
	input logic rst,
	output logic [bW-1:0] q
);

	always_ff @(posedge clk) begin
		if (~rst) begin
			q <= 0;
		end
		else begin
			q <= d;
		end
	end

endmodule: dff
