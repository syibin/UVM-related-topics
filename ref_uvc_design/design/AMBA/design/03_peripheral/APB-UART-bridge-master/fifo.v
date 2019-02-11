////////////////////////////////////
// Based on Cummings's FIFO design//
////////////////////////////////////
`include "defines.vh"
module fifo #(parameter
FIFO_DEPTH = 8,
ADDRESS_WIDTH = 3,
COUNTER_WIDTH = ADDRESS_WIDTH + 1
)
(
  input reset,
  
  input WClk,
  input [`DATA_WIDTH-1:0] WData,
  input WEn,
  output Full,

  input RClk,
  input RInc,
  output Empty,
  output reg [`DATA_WIDTH-1:0] RData
);

reg [`DATA_WIDTH-1:0] FifoMem [FIFO_DEPTH-1];
reg [COUNTER_WIDTH-1:0] RGryCnt;
reg [COUNTER_WIDTH-1:0] WGryCnt;
reg [COUNTER_WIDTH-1:0] RBinCnt;
reg [COUNTER_WIDTH-1:0] WBinCnt;
wire [ADDRESS_WIDTH-1:0] RAddr;
wire [ADDRESS_WIDTH-1:0] WAddr;


//Metastablity :3
reg RPtr_d1;
reg RPtr_d2;
reg RPtr_d3;

reg WPtr_d1;
reg WPtr_d2;
reg WPtr_d3;

integer i;

assign RAddr[ADDRESS_WIDTH-1:0] = RBinCnt[ADDRESS_WIDTH-1:0];
assign WAddr[ADDRESS_WIDTH-1:0] = WBinCnt[ADDRESS_WIDTH-1:0];

always @(posedge WClk) begin
  if (reset) begin
    WBinCnt <= COUNTER_WIDTH'd0;
  end
  else if (WEn & ~Full)begin
    WBinCnt <= WBinCnt + 1'b1;
  end
end

always @(posedge RClk) begin
  if (reset) begin
    RBinCnt <= COUNTER_WIDTH'd0;
  end
  else if (RInc & ~Empty)begin
    RBinCnt <= RBinCnt + 1'b1;
  end
end


always @* begin
  WGryCnt[COUNTER_WIDTH-1] = WBinCnt[COUNTER_WIDTH-1];
  for (i = COUNTER_WIDTH-2; i >= 0; i=i-1) begin
    WGryCnt[i] = WBinCnt[i] ^ WBinCnt[i+1];
  end
end

always @* begin
  RGryCnt[COUNTER_WIDTH-1] = RBinCnt[COUNTER_WIDTH-1];
  for (i = COUNTER_WIDTH-2; i >= 0; i=i-1) begin
    RGryCnt[i] = RBinCnt[i] ^ RBinCnt[i+1];
  end
end

always @(posedge WClk) begin
  if (reset) begin
    RPtr_d1 <= COUNTER_WIDTH'd0; 
    RPtr_d2 <= COUNTER_WIDTH'd0;
    RPtr_d3 <= COUNTER_WIDTH'd0;
  end 
  else begin
    RPtr_d1 <= RGryCnt;
    RPtr_d2 <= RPtr_d1;
    RPtr_d3 <= RPtr_d2;
  end
end

always @(posedge RClk) begin
  if (reset) begin
    WPtr_d1 <= COUNTER_WIDTH'd0; 
    WPtr_d2 <= COUNTER_WIDTH'd0;
    WPtr_d3 <= COUNTER_WIDTH'd0;
  end 
  else begin
    WPtr_d1 <= WGryCnt;
    WPtr_d2 <= WPtr_d1;
    WPtr_d3 <= WPtr_d2;
  end
end

assign Empty = (WPtr_d3 == RGryCnt);
assign Full  = (RPtr_d3[COUNTER_WIDTH-1] ~= WGryCnt[COUNTER_WIDTH-1] &&
                RPtr_d3[COUNTER_WIDTH-2] ~= WGryCnt[COUNTER_WIDTH-2] &&
                RPtr_d3[COUNTER_WIDTH-3:0] ~= WGryCnt[COUNTER_WIDTH-3:0] &&
               );

always @(posedge WClk) begin
  if (WEn & ~Full) begin
    FifoMem[WAddr][`DATA_WIDTH-1:0] <= WData[`DATA_WIDTH-1:0];
  end
end

always @(posedge RClk) begin
  RData[`DATA_WIDTH-1:0] <= FifoMem[RAddr][`DATA_WIDTH-1:0]; 
end



endmodule
