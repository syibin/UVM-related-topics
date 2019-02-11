module ram_ahbif(
               hclk                ,
               hresetn             ,

               //ahb slave
               hsel_s              ,
               haddr_s             ,
               hburst_s            ,
               htrans_s            ,
               hrdata_s            ,
               hwdata_s            ,
               hwrite_s            ,
               hready_s            ,
               hresp_s             ,

               //ram interface
               ram_rdata           ,
               ram_addr            ,
               ram_wdata           ,
               ram_write
                 );

///////////////////////////////////////
//declaration of input & output
///////////////////////////////////////
input               hclk           ;
input               hresetn        ;
//ahb slave interface
input               hsel_s         ;
input     [19:0]    haddr_s        ;
input     [2:0]     hburst_s       ;
input     [1:0]     htrans_s       ;
input     [31:0]    hwdata_s       ;
input               hwrite_s       ;

output    [1:0]     hresp_s        ;
output    [31:0]    hrdata_s       ;
output              hready_s       ;
//ram interface
input     [31:0]    ram_rdata      ;
output    [17:0]     ram_addr       ;
output    [31:0]    ram_wdata      ;
output              ram_write      ;

///////////////////////////////////////
//declaration of registers & wires
///////////////////////////////////////
wire      [1:0]     hresp_s        ;
wire      [31:0]    hrdata_s       ;
reg                 hready_s       ;

wire      [31:0]    ram_wdata      ;
reg       [17:0]     ram_addr       ;
reg                 ram_write      ;

wire                wr_en          ;
wire                rd_en          ;
wire                ready_en       ;
///////////////////////////////////////
//program & function
///////////////////////////////////////
assign hresp_s = 2'b00;

always@(posedge hclk or negedge hresetn)
begin  //hsize = 3'b010--32bits
  if(!hresetn) begin
    ram_addr <= 18'b000000000000000000;
  end else if (hsel_s == 1'b1) begin
    ram_addr <= haddr_s[19:2];
  end
end

assign wr_en = hsel_s & htrans_s[1] & hwrite_s;
//assign rd_en = hsel_s & htrans_s[1] & !hwrite_s;

always@(posedge hclk or negedge hresetn)
begin
  if(!hresetn) begin
    ram_write <= 1'b0;
  end else if(wr_en) begin
    ram_write <= 1'b1;
  end else begin
    ram_write <= 1'b0;
  end
end

assign ram_wdata = hwdata_s;

assign hrdata_s = ram_rdata;

assign ready_en = hsel_s & htrans_s[1];

always@(posedge hclk or negedge hresetn)
begin
  if(!hresetn) begin
    hready_s <= 1'b0;
  end else if(ready_en) begin
    hready_s <= 1'b1;
  end else begin
    hready_s <= 1'b0;
  end
end

endmodule