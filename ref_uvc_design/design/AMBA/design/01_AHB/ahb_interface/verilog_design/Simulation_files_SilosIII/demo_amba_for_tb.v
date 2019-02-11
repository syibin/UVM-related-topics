/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                          demo_amba_for_tb.v
*
*                          Copyright (c) 2002
*                           QuickLogic, Corp.
*																			   
*
************************************************************************/

`timescale 1ns/10ps

`include "macros.v"
`include "ahb_master.v"
`include "ahb_slave.v"
`include "appreq_sm.v"
`include "app_codec.v"
`include "busreq_sm.v"
`include "fifo128x32.v"

module demo_amba (

	hclk,
	hresetn,

    // shared AHB master/slave signals
    ahb_hready_in,

    // AHB master signals
    ahbm_hresp,
    ahbm_hgrant,

    ahbm_hbusreq,
    ahbm_htrans,
    ahbm_hwrite,
    ahbm_hsize,
    ahbm_hburst,

    ahbm_haddr,
    ahbm_hwdata,
	ahbm_hrdata,

    // AHB slave signals
	ahbs_hsel,
	ahbs_haddr,
	ahbs_htrans,
	ahbs_hwrite,
	ahbs_hsize,
	ahbs_hburst,
	ahbs_hwdata,
	ahbs_hrdata,
	ahbs_hready_out,
	ahbs_hresp,

    /**************/
    /* Fabric IOs */
    /**************/

    // LED output
    LED8

     );



// LED Output signals (Application I/O)
output	[7:0]	LED8;


// AHB & APB interface signals
input 			hclk; 
input 			hresetn;
output 	[31:0] 	ahbm_haddr;
output 	[1:0] 	ahbm_htrans;
output 			ahbm_hwrite;
output 	[2:0] 	ahbm_hsize;
output 	[2:0] 	ahbm_hburst;
output 	[31:0] 	ahbm_hwdata;
input 	[31:0] 	ahbm_hrdata;
input 			ahb_hready_in;
input 	[1:0] 	ahbm_hresp;
output 			ahbm_hbusreq;
input 			ahbm_hgrant;
input 			ahbs_hsel;
input 	[31:0] 	ahbs_haddr;
input 	[1:0] 	ahbs_htrans;
input 			ahbs_hwrite;
input 	[2:0] 	ahbs_hsize;
input 	[2:0] 	ahbs_hburst;
input 	[31:0] 	ahbs_hwdata;
output 	[31:0] 	ahbs_hrdata;
output 			ahbs_hready_out;
output 	[1:0] 	ahbs_hresp;

// AHB master
wire 	[3:0] 	ahbm_hprot;
wire 	[3:0] 	ahbs_hprot;


// Tied to Low (Unused Signals)
assign ahbm_hprot = 4'b0000;
assign ahbs_hprot = 4'b0000;


// put the fabric reset signal on a GCLK net
wire g_hreset;

gclkbuff_25um hreset_ghreset(.A(~hresetn), .Z(g_hreset));

//
//
// AMBA Bus Application Starts Here
//
//

wire 			start;
wire 			int_en;
wire 			dma_en;
wire 			int_clr;
wire 	[7:0]	LED8;
wire 			out_ready;

	// State Machine Interface (Bus Side)
wire			req_done;
wire	 		rd_req;
wire			wr_req;
wire			non_zero;

	// FIFO Interface
wire	[31:0]  dataout;			// Data Out to Read FIFO
wire	[31:0]	datain;				// Data In from Write FIFO
wire	 		ahb_push;
wire			ahb_pop;
wire	 		ahb_empty;
wire			ahb_full;
wire	 		app_push;
wire			app_pop;
wire	 		app_empty;
wire			app_full;
wire 			app_start;
wire	[31:0]  app_dataout;		// Data Out from Application
wire	[31:0]	app_datain;			// Data In to Application

    // From DMA Register          
wire	[31:0]  src_addr;
wire	[31:0]  dst_addr;          
wire	[15:0]	block_count;	   	// Number of blocks to move
wire	[4:0]	block_size;			// Number of words per block

assign non_zero = |block_count;

ahb_master ahb_master
   (
     // AHB Master Interface
	.hclk(hclk),
	.hreset(g_hreset),

    .hready_i(ahb_hready_in),
    .hresp_i(ahbm_hresp),
    .hgrant_i(ahbm_hgrant),

    .hbusreq_o(ahbm_hbusreq),
    .htrans_o(ahbm_htrans),
    .hwrite_o(ahbm_hwrite),
    .hsize_o(ahbm_hsize),
    .hburst_o(ahbm_hburst),

    .haddr_o(ahbm_haddr),
    .hwdata_o(ahbm_hwdata),
	.hrdata_i(ahbm_hrdata),

	// State Machine Interface
	.req_done(req_done),
	.rd_req(rd_req),
	.wr_req(wr_req),

	// FIFO Interface
    .dataout(dataout),
	.datain(datain),
	.push(ahb_push),
	.pop(ahb_pop),

    // From DMA Register          
    .src_addr(src_addr),
    .dst_addr(dst_addr),          
	.block_size(block_size)
  );

busreq_sm busreq_sm (
	.hclk(hclk),
	.hreset(g_hreset),
	.dma_en(dma_en),
	.req_done(req_done),
	.full(ahb_full),
	.empty(ahb_empty),
	.non_zero(non_zero),
	.rd_req(rd_req),
	.wr_req(wr_req),
	.rd_update(rd_update),
	.wr_update(wr_update)
);

fifo128x32 in_fifo (
	.clock(hclk),
	.reset(g_hreset),
	.push(ahb_push),
	.pop(app_pop),
	.full(ahb_full),
	.empty(app_empty),
	.din(dataout),
	.dout(app_datain)
);

fifo128x32 out_fifo (
	.clock(hclk),
	.reset(g_hreset),
	.push(app_push),
	.pop(ahb_pop),
	.full(app_full),
	.empty(ahb_empty),
	.din(app_dataout),
	.dout(datain)
);

appreq_sm appreq_sm (
	.clk(hclk), 
	.hreset(g_hreset),
	.full(app_full),
	.empty(app_empty),
	.done(app_done),
	.start(app_start)
	);

ahb_slave ahb_slave (
	.hclk(hclk),
	.hreset(g_hreset),
	.ahbs_hsel(ahbs_hsel),
	.ahbs_haddr(ahbs_haddr),
	.ahbs_htrans(ahbs_htrans),
	.ahbs_hwrite(ahbs_hwrite),
	.ahbs_hsize(ahbs_hsize),
	.ahbs_hburst(ahbs_hburst),
	.ahbs_hprot(ahbs_hprot),
	.ahb_hready_in(ahb_hready_in),
	.ahbs_hwdata(ahbs_hwdata),
	.ahbs_hrdata(ahbs_hrdata),
	.ahbs_hready_out(ahbs_hready_out),
	.ahbs_hresp(ahbs_hresp),

// DMA Registers
    .src_addr(src_addr),
    .dst_addr(dst_addr),          
	.block_count(block_count),
	.block_size(block_size),
	.rd_update(rd_update),
	.wr_update(wr_update),

// Application
	.start(start),
	.int_en(int_en),
	.dma_en(dma_en),
	.int_clr(int_clr),
	.LED8(LED8)
	);
	
app_codec app_inst (
	.hreset(g_hreset),
	.clk(hclk), 
	.app_start(app_start), 
	.block_size(block_size), 
	.datain(app_datain), 
	.dataout(app_dataout),
	.pop(app_pop),
	.push(app_push),
	.done(app_done)
	);

endmodule
