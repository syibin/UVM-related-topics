`include "defines.vh"
module apb_uart_bridge (
  `include "ports.vh"
);

//APB Operation States
reg [1:0] state;
reg [1:0] next_state;
wire apb_setup;
wire apb_access;

// Decoder output
reg DEC_REG_State;
reg DEC_REG_Cntrl;
reg DEC_REG_BaudDiv;
reg DEC_Data;

//Registers
reg [`DATA_WIDTH-1:0] State;
reg [`DATA_WIDTH-1:0] Cntrl;
reg [`DATA_WIDTH-1:0] BaudDiv;

//FIFO1 APB -> UART
wire TxFifoFull;
wire TxFifoEmpty;
reg WriteEn;
//FIFO2 UART -> APB
wire RxFifoFull;
wire RxFifoEmpty;

reg READY;
reg [`DATA_WIDTH-1:0] RDATA;
wire ReadyRegWr;
wire ReadyDatWr;
wire ReadyRegRd;
wire ReadyDatRd;

assign apb_setup  = (state == `APB_FSM_SETUP);
assign apb_access = (state == `APB_FSM_ACCESS);

assign ReadyRegRd   = 1'b1;
assign ReadyRegWr   = 1'b1;
assign ReadyDatRd   = ~RxFifoEmpty;
assign ReadyDatWr   = ~TxFifoFull;
assign PREADY       = READY;
assign PRDATA[`DATA_WIDTH-1:0] = RDATA[`DATA_WIDTH-1:0];

always @(*) begin
  case (state[1:0])
    `APB_FSM_IDLE : begin
	  if (PSEL & ~PENABLE) begin
	    next_state[1:0] = `APB_FSM_SETUP;
	  end
	  else begin
	    next_state[1:0] = `APB_FSM_IDLE;
	  end
	end
	`APB_FSM_SETUP : begin
	  if (PSEL & PENABLE) begin
	    next_state[1:0] = `APB_FSM_ACCESS;
	  end
	  else  begin
	    next_state[1:0] = `APB_FSM_ERROR;
	  end
	end
	`APB_FSM_ACCESS : begin
	  if (~PREADY) begin
	    next_state[1:0] = `APB_FSM_ACCESS;
	  end
	  else if (PSEL)begin
	    next_state[1:0] = `APB_FSM_SETUP;
	  end
	  else begin
	    next_state[1:0] = `APB_FSM_IDLE;
	  end
	end
	`APB_FSM_ERROR : begin
	  if (~PSEL & ~PENABLE) begin
	    next_state[1:0] = `APB_FSM_IDLE;
	  end
	  else begin
	    next_state[1:0] = `APB_FSM_ERROR;
	  end
	end
  endcase
end

always @(posedge PCLK) begin
  if (~PRESETn) begin
    state[1:0] <= 2'b00;
  end
  else begin
    state[1:0] <= next_state[1:0];
  end
end

always @(*) begin
  DEC_REG_State   = 1'b0;
  DEC_REG_Cntrl   = 1'b0;
  DEC_REG_BaudDiv = 1'b0;
  DEC_Data        = 1'b0;
  case (PADDR[3:0])
    4'b0000 : begin
	  DEC_Data = 1'b1;
	end
	4'b0100 : begin
      DEC_REG_State = 1'b1;
	end
	4'b1000 : begin
	  DEC_REG_Cntrl = 1'b1;
	end
	4'b1100 : begin
	  DEC_REG_BaudDiv = 1'b1;
	end
	default : begin
	end
  endcase
end

always @(*) begin
  READY = 1'b1;
  if (apb_access || apb_setup) begin
    if (PWRITE) begin
	  if (DEC_Data)
	    READY = ReadyDatWr;
	  else
	    READY = ReadyRegWr;
    end	else begin
	  if (DEC_Data)
	    READY = ReadyDatRd;
	  else
	    READY = ReadyRegRd;
	end
  end
end

always @(posedge PCLK) begin
  if (~PRESETn) begin
	Cntrl[`DATA_WIDTH-1:0] <= 0;
	BaudDiv[`DATA_WIDTH-1:0] <= 0;
	RDATA[`DATA_WIDTH-1:0] <= 0;
  end
  else begin
    if (apb_access || apb_setup) begin
	  if (PWRITE & ReadyRegWr) begin
	    if (DEC_REG_Cntrl)
		  Cntrl[3:0] <= PWDATA[3:0];
		else if (DEC_REG_BaudDiv)
		  BaudDiv[19:0] <= PWDATA[19:0];
	  end
	  else if (~PWRITE & ReadyRegRd) begin
	    if (DEC_REG_State)
		  RDATA[1:0] <= State[1:0];
		else if (DEC_REG_Cntrl)
		  RDATA[3:0] <= Cntrl[3:0];
		else if (DEC_REG_BaudDiv)
		  RDATA[19:0] <= BaudDiv[19:0];
	  end
	end
  end
end

always @* begin
  WriteEn = 1'b0;
  if (apb_access || apb_setup) begin
    if (PWRITE & ReadyDatWr) begin
      WriteEn = 1'b1;
    end
  end
end

fifo #(
       .FIFO_DEPTH    (  4),
       .ADDRESS_WIDTH (  2),
      )
TXFIFO
(
 .reset(~PRESETn),
 .WClk(PCLK),
 .WData(PWDATA),
 .Wen(WriteEn),
 .Full(TxFifoFull),
 .RClk(UCLK),
 .RInc(ReadInc),
 .Empty(TxFifoEmpty),
 .RData(TxLoad)
);
endmodule

interface apb_uart_bridge_if(
  input PCLK,
  input PRESETn,
  input PSEL,
  input PENABLE,
  input [3:0] PADDR,
  input PWRITE,
  input PREADY,
  input [`DATA_WIDTH-1:0] PWDATA,
  input [`DATA_WIDTH-1:0] PRDATA,
  input PSLVERR,
  input TXD,
  input RXD);
  clocking apb_cb @(posedge PCLK);
  endclocking
endinterface

bind apb_uart_bridge apb_uart_bridge_if apb_uart_bridge_if0(.*);


