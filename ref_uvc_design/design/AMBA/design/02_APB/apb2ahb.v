`timescale 1ns/10ps

module apb2ahb 	( input wire clk,
		  input wire reset_,
		  // apb input bus
		  input wire [31:0]  paddr,
		  input wire [31:0]  pwdata,
		  output reg [31:0] prdata,
		  input wire        penable,
		  output reg	pready,
		  input	wire	pwrite,
		  //apb output bus
		  output wire [31:0]  po_addr,
		  output wire [31:0]  po_wdata,
		  input wire [31:0] po_rdata,
		  output wire         po_enable,
		  input wire 		po_ready,
		  output wire	 	po_write,
		  output reg  		po_sel,
		  // for gpio and uart device
		  output reg  		gpio_sel,
		  output reg  		uart0_sel,
		  input wire [31:0] gpio_rdata,
		  input wire [7:0] uart0_rdata,
		  input wire 		gpio_ready,
		  input wire 		uart0_ready,

		  //ahb bus interface
		  output wire [31:0]		HADDR,
		  output wire 			HWRITE,
		  output wire [2:0]		HSIZE,
	  	  output wire  [31:0]		HWDATA,
		  output wire [2:0]		HBURST,
		  input wire  		HREADY0,
		  input wire  		HREADY1,
		  output reg		HSEL0,
		  output reg		HSEL1,
		  input  wire [31:0]		HRDATA0,
		  input  wire [31:0]		HRDATA1,
		  input  wire [1:0]		HRESP0,
		  input  wire [1:0]		HRESP1,
		  output wire [1:0]		HTRANS
	  );
	  // main state define
	  `define IDLE 2'b00
	  `define ADDR 2'b01
	  `define DATA 2'b10
	  `define WAIT 2'b11
	  //ahb HTRANS state
	  //current not support BUSY and SEQ state
	  `define H_IDLE 2'b00
	  `define H_NONSEQ 2'b10
	  //address map 
	  `define laddr_range1		32'h0	
	  `define haddr_range1		32'h0100_0000	
	  `define laddr_range0		32'h0100_0000
	  `define haddr_range0		32'h0200_0000	
	  `define laddr_range2		32'h0200_0000
	  `define haddr_range2		32'h0200_1000	
	  `define laddr_gpio		32'h0200_1000
	  `define haddr_gpio		32'h0200_2000	
	  `define laddr_uart0		32'h0200_2000
	  `define haddr_uart0		32'h0200_3000	

	  reg [1:0] state;
	  reg [1:0] state_nxt;
	  wire hit_range0 , hit_range1,hit_range2;
	  wire hit_gpio,hit_uart0;
	  wire HSEL0D,HSEL1D,po_selD;
	  wire gpio_selD,uart0_selD;
	  reg [31:0] prdataD;
	  wire device_ready;
	  

	  assign device_ready = (gpio_sel & gpio_ready | uart0_sel & uart0_ready | HSEL0 & HREADY0 | HSEL1 & HREADY1 | po_sel & po_ready);
	  assign HWDATA  = pwdata;
	  assign HADDR   = paddr;
	  assign HWRITE = pwrite;
	  assign po_wdata = pwdata;
	  assign po_addr = paddr;
	  assign po_write = pwrite;
	  assign po_enable = penable;
	  assign HSIZE  = 3'b010; // 000 byte 001 half word 010 word  we only support word 
	  assign HBURST = 3'b000; //burst always single transfer
	  assign HTRANS = (state== `ADDR) ? `H_NONSEQ : `H_IDLE;
	  assign HSEL0D		= HSEL0 ? ~(( state == `DATA ) & HREADY0 ) :  (state== `IDLE) & penable & hit_range0; 
	  assign HSEL1D 	= HSEL1 ? ~(( state == `DATA ) & HREADY1 ) :  (state== `IDLE) & penable & hit_range1; 
	  assign po_selD	= po_sel? ~(( state == `DATA ) & po_ready) :  (state== `IDLE) & penable & hit_range2; 
	  assign gpio_selD	= gpio_sel? ~(( state == `DATA ) & gpio_ready) :  (state== `IDLE) & penable & hit_gpio; 
	  assign uart0_selD	= uart0_sel? ~(( state == `DATA ) & uart0_ready) :  (state== `IDLE) & penable & hit_uart0; 

	  assign hit_range0 = (paddr >= `laddr_range0 & paddr < `haddr_range0); 
	  assign hit_range1 = (paddr >= `laddr_range1 & paddr < `haddr_range1); 
	  assign hit_range2 = (paddr >= `laddr_range2 & paddr < `haddr_range2); 
	  assign hit_gpio   = (paddr >= `laddr_gpio   & paddr < `haddr_gpio  ); 
	  assign hit_uart0   = (paddr >= `laddr_uart0   & paddr < `haddr_uart0  ); 

	  always @*
		  case(state)
		   `IDLE: if(penable)
			   state_nxt = `ADDR;
		   	  else
			   state_nxt = `IDLE;
		   `ADDR: begin
			   state_nxt  = `DATA;
			   //$display ($time, "ns send requst at addr = %h, read/write = %h",paddr, pwrite);
		   end
		   `DATA: if (device_ready )
			   state_nxt = `WAIT;
		   	  else
			   state_nxt = `DATA;
		   `WAIT: state_nxt = `IDLE;
		   default: state_nxt = `IDLE;
	   endcase

	  always @(posedge clk or negedge reset_)
		  if (~reset_)
		  begin
			  po_sel <= 1'b0;
			  HSEL0	 <= 1'b0;
			  HSEL1	 <= 1'b0;
			  gpio_sel <= 1'b0;
			  uart0_sel <= 1'b0;
			  state  <= `IDLE;
			  pready <= 1'b0;
			  prdata <= 32'b0;

		  end
		  else
		  begin
			  po_sel <= po_selD;
			  gpio_sel <= gpio_selD;
			  uart0_sel <= uart0_selD;
			  HSEL0	 <= HSEL0D;
			  HSEL1	 <= HSEL1D;
			  state  <= state_nxt;
			  pready <= (state == `DATA) & device_ready;
			  prdata <=  prdataD;
			  //prdata <= po_sel ? po_rdata : ( HSEL0 ? HRDATA0 : HRDATA1) ;
		  end

	always @*
		case ({po_sel,HSEL0,HSEL1,uart0_sel,gpio_sel}) 
		5'b10000:  prdataD = po_rdata;
		5'b01000:  prdataD = HRDATA0;
		5'b00100:  prdataD = HRDATA1;
		5'b00010:  prdataD = {24'h0,uart0_rdata};
		5'b00001:  prdataD = gpio_rdata;
		default:prdataD = po_rdata;
	endcase


	  endmodule



