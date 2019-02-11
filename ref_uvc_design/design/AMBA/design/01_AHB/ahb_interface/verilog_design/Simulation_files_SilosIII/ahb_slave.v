/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              ahb_slave.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/
// First Draft (5/12/2002 H. Kim)

`timescale 1ns/10ps

`define IDLE_ST  2'b00
`define RD_OP_ST 2'b01
`define WR_OP_ST 2'b10

module ahb_slave (
	hclk,
	hreset,
// AHB Slave Signals
	ahbs_hsel,
	ahbs_haddr,
	ahbs_htrans,
	ahbs_hwrite,
	ahbs_hsize,   // unused input
	ahbs_hburst,  // unused input
	ahbs_hprot,   // unused input
	ahb_hready_in,
	ahbs_hwdata,
	ahbs_hrdata,
	ahbs_hready_out,
	ahbs_hresp,
// DMA Registers
    rd_update,
    wr_update,
    src_addr,
    dst_addr,          
	block_count,
	block_size,

// Application
	start,
	int_en,
	dma_en,
	int_clr,
	LED8
	);

input  			hclk;
input  			hreset;

input  			ahbs_hsel;
input  	 [31:0] ahbs_haddr;
input  	 [1:0] 	ahbs_htrans;
input  			ahbs_hwrite;
input  	 [2:0] 	ahbs_hsize;
input  	 [2:0] 	ahbs_hburst;
input  	 [3:0] 	ahbs_hprot;
input  			ahb_hready_in;
input  	 [31:0] ahbs_hwdata;
output   [31:0] ahbs_hrdata;
output  		ahbs_hready_out;
output 	 [1:0] 	ahbs_hresp;

/***** Signals for User Application	*****/
// DMA Registers
input			rd_update;
input			wr_update;
output   [31:0] src_addr;
output   [31:0] dst_addr;          
output   [15:0]	block_count;
output   [4:0]	block_size;
output			start;
output			int_en;			// interrupt enable
output			dma_en;			// dma enable
output			int_clr;		// interrupt clear
output	[7:0]	LED8;
wire  	[7:0]	LED8;
/***** Signals for User Application	*****/

// QuickMIPS ESP Module interface ports
wire 			hclk;
wire 			hreset;

wire 			ahbs_hsel;
wire 	[31:0] 	ahbs_haddr;
wire 	[1:0] 	ahbs_htrans;
wire 			ahbs_hwrite;
wire 	[2:0] 	ahbs_hsize;
wire 	[2:0] 	ahbs_hburst;
wire 	[3:0] 	ahbs_hprot;
wire 	[31:0] 	ahbs_hwdata;
reg 	[31:0] 	ahbs_hrdata;
wire  			ahbs_hready_out;
wire 	[1:0] 	ahbs_hresp;

reg		 [31:0] src_addr;
reg		 [31:0] dst_addr;          
reg		 [15:0]	block_count;
reg		 [4:0]	block_size;

reg 			start;
reg 			int_en;
reg 			dma_en;
reg 			int_clr;

parameter C2Q_DLY = 1;

reg  	[1:0]       curr_state;	        // State Machine for Read and Write.
reg  	[1:0]       next_state;
reg  	[1:0]       prevsel;
reg  	[13:0]      ahbs_haddr_reg;

// read/write registers and latches
reg 				rd_enable;

// For this design ahbs_hready_out is always high.
assign 	ahbs_hready_out = ~hreset;
assign  ahbs_hresp = 2'b00;

wire				sel_ctrl;
wire				sel_output;

assign  sel_ctrl  = (ahbs_hsel && (ahbs_haddr[15] == 1'b0)  && ahbs_htrans[1]);
assign  sel_output = (ahbs_hsel && (ahbs_haddr[15] == 1'b1)  && ahbs_htrans[1]);

always @ (posedge hclk or posedge hreset)
   begin
      if (hreset == 1'b1)
	    begin 
      		prevsel <= #C2Q_DLY  2'b00;
			ahbs_haddr_reg <= #C2Q_DLY  14'h0000;
		end
   else
		begin
      		prevsel <= #C2Q_DLY {sel_ctrl, sel_output};
			ahbs_haddr_reg <= #C2Q_DLY  ahbs_haddr[13:0];
		end
   end

// FSM for Register R/W begins

always @ (posedge hclk or posedge hreset)
   begin
      if (hreset == 1'b1)
         curr_state <= #C2Q_DLY `IDLE_ST;
      else
         curr_state <= #C2Q_DLY next_state;
end

always @ (ahbs_hsel or ahb_hready_in or ahbs_hwrite or curr_state or ahbs_htrans)
   begin
      case(curr_state)
      `IDLE_ST : begin
         if (ahbs_hsel  == 1'b1 && 
             ahb_hready_in == 1'b1 && 
             ahbs_hwrite    == 1'b0 && 
             ahbs_htrans[1] == 1'b1)          // Read Operation starts in the next state.
         next_state = `RD_OP_ST;
         else if (ahbs_hsel  == 1'b1 && 
                  ahb_hready_in == 1'b1 && 
                  ahbs_hwrite    == 1'b1 && 
                  ahbs_htrans[1]  == 1'b1)    // Write Operation starts 
                                        // if not goes for Read.
	 next_state = `WR_OP_ST;
	 else 
	 //if (hsel     == 1'b0 || 
         //    htran[1] == 1'b0)
	 next_state = `IDLE_ST;
      end

      `RD_OP_ST : begin          
       	if (ahbs_hsel  == 1'b1 && 
            ahb_hready_in == 1'b1 && 
            ahbs_hwrite    == 1'b1 && 
            ahbs_htrans[1]  == 1'b1)         // Write Operation Starts
	    next_state = `WR_OP_ST;
       else if (ahbs_hsel  == 1'b1 && 
                ahb_hready_in == 1'b1 && 
                ahbs_hwrite    == 1'b0 && 
                ahbs_htrans[1]  == 1'b1)     // Back to Back Read
	    next_state = `RD_OP_ST;
	else 
	//if (hsel == 1'b0 || htran[1] == 1'b0)
            next_state = `IDLE_ST;
      end

      `WR_OP_ST : begin
	  if (ahbs_hsel    == 1'b1 && 
              ahb_hready_in  == 1'b1 && 
              ahbs_hwrite  == 1'b0 && 
              ahbs_htrans[1] == 1'b1)       // Read Opeartion Starts 
	     next_state = `RD_OP_ST;
          else if (ahbs_hsel == 1'b1 && 
                   ahb_hready_in  == 1'b1 && 
                   ahbs_hwrite  == 1'b1 && 
                   ahbs_htrans[1] == 1'b1)  // Back to Back Write
	     next_state = `WR_OP_ST;
          else 
	  //if (hsel == 1'b0 || htran[1] == 1'b0)
             next_state = `IDLE_ST;
      end

      default : begin
         next_state = `IDLE_ST;
      end

   endcase
end // FSM ends

always @ (posedge hclk or posedge hreset)
   begin
    if (hreset == 1'b1)
       rd_enable <= #C2Q_DLY 1'b0;
    else
       if (ahbs_hsel == 1'b1 && 
           ahb_hready_in == 1'b1 && 
           ahbs_hwrite == 1'b0)
          rd_enable <= #C2Q_DLY 1'b1;
       else
          rd_enable <= #C2Q_DLY 1'b0;
  end

always @ (rd_enable or prevsel[1] or ahbs_haddr_reg[3:2] or 
          int_clr or dma_en or int_en or start or 
          src_addr or dst_addr or block_count or block_size) 
   begin
   if ((rd_enable == 1'b1) &&  prevsel[1])
      begin
         case(ahbs_haddr_reg[3:2])		// Reading Data from internal memory
         	2'b00 : ahbs_hrdata <= #C2Q_DLY  {28'b0, int_clr, dma_en, int_en, start};
         	2'b01 : ahbs_hrdata <= #C2Q_DLY  src_addr;
         	2'b10 : ahbs_hrdata <= #C2Q_DLY  dst_addr;
         	2'b11 : ahbs_hrdata <= #C2Q_DLY  {11'b0, block_size, block_count};
            default  : ahbs_hrdata <= #C2Q_DLY  32'b0;
         endcase
      end
    else
         ahbs_hrdata <= #C2Q_DLY 32'b0;
   end

always @ (posedge hclk or posedge hreset)
begin
	if (hreset == 1'b1) begin
     	{int_clr, dma_en, int_en, start}  <= #C2Q_DLY 4'b0;
		src_addr  <= #C2Q_DLY 32'b0;
		dst_addr  <= #C2Q_DLY 32'b0;
		{block_size, block_count}  <= #C2Q_DLY 21'b0;
	end
	else if ((curr_state == `WR_OP_ST) && prevsel[1]) begin
        case(ahbs_haddr_reg[3:2])	// Writing Data to internal memory
            2'b00 : {int_clr, dma_en, int_en, start}  <= #C2Q_DLY ahbs_hwdata[3:0];
            2'b01 : src_addr  <= #C2Q_DLY ahbs_hwdata;
            2'b10 : dst_addr  <= #C2Q_DLY ahbs_hwdata;
            2'b11 : {block_size, block_count} <= #C2Q_DLY ahbs_hwdata[20:0];
            default : ;
		endcase
	end
	else begin
		if (rd_update) begin
			src_addr  <= #C2Q_DLY src_addr + {block_size, 2'b0};
			block_count <= #C2Q_DLY block_count - 1;
		end
		if (wr_update) begin
			dst_addr  <= #C2Q_DLY dst_addr + {block_size, 2'b0};
		end
	end
end

assign LED8 = ~{4'b0000, int_clr, dma_en, int_en, start};

endmodule
