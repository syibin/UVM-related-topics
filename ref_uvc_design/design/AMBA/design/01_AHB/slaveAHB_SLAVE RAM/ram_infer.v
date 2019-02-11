module ram_infer(
                    q    ,
                    a    ,
                    d    ,
                    we   ,
                    clk
                 );
output    [31:0]    q    ;
input     [31:0]    d    ;
input     [17:0]     a    ;
input               we   ;
input               clk  ;
reg       [31:0]     mem  [262143:0]   ;

always @(posedge clk) begin
  if (we) begin
    mem[a] <= d;
  end
end

assign q = mem[a];

endmodule