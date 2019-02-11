module ahbdec (
	hclk,
	hresetn,
	addr,
	ready,
	hsel0,
	hsel0_rd,
	hsel1,
	hsel1_rd,
	hsel2,
	hsel2_rd
);

input hclk;
input hresetn;
input [31:0] addr;
input ready;
output hsel0;
output hsel0_rd;
output hsel1;
output hsel1_rd;
output hsel2;
output hsel2_rd;

reg hsel0_rd;
reg hsel1_rd;
reg hsel2_rd;

// hsel0 range: 32'h00000000 - 32'h0FFFFFFF
assign hsel0 = (addr[31:28] == 4'h0) ? 1'b1 : 1'b0;
// hsel1 range: 32'h10000000 to 32'h3FFFFFFF
assign hsel1 = (addr[31:28] == 4'h1 || addr[31:28] == 4'h2 || addr[31:28] == 4'h3) ? 1'b1 : 1'b0;
// the rest is hsel2
assign hsel2 = ~(hsel0 | hsel1);

always @(posedge hclk) begin
	if (~hresetn) begin
		hsel0_rd <= 1'b0;
		hsel1_rd <= 1'b0;
		hsel2_rd <= 1'b0;
	end else begin
		if (ready) begin
			hsel0_rd <= hsel0;
			hsel1_rd <= hsel1;
			hsel2_rd <= hsel2;
		end
	end
end

endmodule
