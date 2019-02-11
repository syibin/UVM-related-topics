/***********************************************************************
*
*               High Speed AMBA Bus (AHB) Interface Example
*                   for "QuickMIPS" QL901M-680 Device
*                              demo_amba.v
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
`include "qmipsesp.v"
`include "busreq_sm.v"
`include "fifo128x32.v"

module demo_amba (

             /**************/
             /*   ESP IOs  */
             /**************/

             // MC Pad signals off-chip

             CS_n,
             WEN_n,
             BLS_n,
             OEN_n,
             BOOT,
             ADDR,
             DATA,
             SD_DQM,
             SD_CS_n,
             SD_CKE,
             SD_RAS_n,
             SD_CAS_n,
             SD_WE_n,
             SD_CLKOUT,
             SD_CLKIN,

             // U1 Pad signals off-chip

             U1_TXD_SIROUT_n,
             U1_RXD_SIRIN,
             U1_CTS_n,
             U1_DCD_n,
             U1_DSR_n,
             U1_RI_n,
             U1_DTR_n,
             U1_RTS_n,

             // U2 Pad signals off-chip

             U2_RXD_SIRIN,
             U2_TXD_SIROUT_n,
             
             // PL Pad signals off-chip
             
             PL_CLOCKIN,
             PL_RESET_n, 
             PL_WARMRESET_n,
             PL_ENABLE,
             PL_CLKOUT,
             PL_BYPASS,
             PL_LOCK,
             
             // GL Pad signals off-chip
             
             CPU_BIGENDIAN,
             CPU_EXTINT_n,
             
             // JD Pad signals off-chip
             
             EJTAG_DEBUGM,
             EJTAG_DINT,
             EJTAG_TCK,
             EJTAG_TDI,
             EJTAG_TDO,
             EJTAG_TMS,
             EJTAG_TRST,
             
             // PC Pad signals off-chip
             
             PCI_AD,
             PCI_C_BE_n,
             PCI_PAR,
             PCI_FRAME_n,
             PCI_IRDY_n,
             PCI_TRDY_n,
             PCI_STOP_n,
             PCI_DEVSEL_n,
             PCI_IDSEL,
             PCI_SERR_n,
             PCI_PERR_n,
             PCI_REQ_n,
             PCI_GNT_n,
             PCI_LOCK_n,
             PCI_INTA_n,
             PCI_CLK,
             PCI_RST_n,
             
             // TM Pad signals off-chip
             
             TM_OVERFLOW,
             TM_ENABLE,
             
             // M1 Pad signals off-chip
             
             M1_CRS,
             M1_COL,
             M1_RXCLK,
             M1_RXD,
             M1_RXDV,
             M1_RXER,
             M1_TXCLK,
             M1_MDC,
             M1_TXD,
             M1_TXEN,
             M1_MDIO,

             // M2 Pad signals off-chip
             
             M2_CRS,
             M2_COL,
             M2_RXCLK,
             M2_RXD,
             M2_RXDV,
             M2_RXER,
             M2_TXCLK,
             M2_MDC,
             M2_TXD,
             M2_TXEN,
             M2_MDIO,

             /**************/
             /* Fabric IOs */
             /**************/

             // LED output

             LED8

     );


// SM Pad signals off-chip

output [7:0]   CS_n;
output         WEN_n;
output [3:0]   BLS_n;
output         OEN_n;
input  [1:0]   BOOT;
output [23:0]  ADDR;
inout  [31:0]  DATA;
output [3:0]   SD_DQM;
output [3:0]   SD_CS_n;
output [3:0]   SD_CKE;
output         SD_RAS_n;
output         SD_CAS_n;
output         SD_WE_n;
output         SD_CLKOUT;
input          SD_CLKIN;

// U1 Pad signals off-chip

output         U1_TXD_SIROUT_n;
input          U1_RXD_SIRIN;
input          U1_CTS_n;
input          U1_DCD_n;
input          U1_DSR_n;
input          U1_RI_n;
output         U1_DTR_n;
output         U1_RTS_n;

// U2 Pad signals off-chip

input          U2_RXD_SIRIN;
output         U2_TXD_SIROUT_n;

// PL Pad signals off-chip

input          PL_CLOCKIN;
input          PL_RESET_n;
input          PL_WARMRESET_n;
input          PL_ENABLE;
input          PL_BYPASS;
output         PL_CLKOUT;
output         PL_LOCK  ;

// GL Pad signals off-chip

input  [6:0]   CPU_EXTINT_n;
input          CPU_BIGENDIAN;

// JD Pad signals off-chip

input          EJTAG_DINT;
output         EJTAG_DEBUGM;
input          EJTAG_TCK;
input          EJTAG_TDI;
output         EJTAG_TDO;
input          EJTAG_TMS;
input          EJTAG_TRST;

// PC Pad signals off-chip

inout  [31:0]  PCI_AD;
inout  [3:0]   PCI_C_BE_n;
inout          PCI_PAR;
inout          PCI_FRAME_n;
inout          PCI_IRDY_n;
inout          PCI_TRDY_n;
inout          PCI_STOP_n;
inout          PCI_DEVSEL_n;
input          PCI_IDSEL;
output         PCI_SERR_n;
output         PCI_PERR_n;
output         PCI_REQ_n;
input          PCI_GNT_n;
input          PCI_LOCK_n;
output         PCI_INTA_n;
input          PCI_CLK;
input          PCI_RST_n;

// TM Pad signals off-chip

output         TM_OVERFLOW;
input          TM_ENABLE;

// M1 Pad signals off-chip

input          M1_CRS;
input          M1_COL;
input          M1_RXCLK;
input  [3:0]   M1_RXD;
input          M1_RXDV;
input          M1_RXER;
input          M1_TXCLK;
output         M1_MDC;
output [3:0]   M1_TXD;
output         M1_TXEN;
inout          M1_MDIO;

// M2 Pad signals off-chip

input          M2_CRS;
input          M2_COL;
input          M2_RXCLK;
input  [3:0]   M2_RXD;
input          M2_RXDV;
input          M2_RXER;
input          M2_TXCLK;
output         M2_MDC;
output [3:0]   M2_TXD;
output         M2_TXEN;
inout          M2_MDIO;

// LED Output signals (Application I/O)
output	[7:0]	LED8;


// AHB & APB interface signals
wire 			hclk; 
wire 			hresetn;
wire 	[31:0] 	ahbm_haddr;
wire 	[1:0] 	ahbm_htrans;
wire 			ahbm_hwrite;
wire 	[2:0] 	ahbm_hsize;
wire 	[2:0] 	ahbm_hburst;
wire 	[3:0] 	ahbm_hprot;
wire 	[31:0] 	ahbm_hwdata;
wire 	[31:0] 	ahbm_hrdata;
wire 			ahb_hready_in;
wire 	[1:0] 	ahbm_hresp;
wire 			ahbm_hbusreq;
wire 			ahbm_hgrant;
wire 			ahbs_hsel;
wire 	[31:0] 	ahbs_haddr;
wire 	[1:0] 	ahbs_htrans;
wire 			ahbs_hwrite;
wire 	[2:0] 	ahbs_hsize;
wire 	[2:0] 	ahbs_hburst;
wire 	[3:0] 	ahbs_hprot;
wire 	[31:0] 	ahbs_hwdata;
wire 	[31:0] 	ahbs_hrdata;
wire 			ahbs_hready_out;
wire 	[1:0] 	ahbs_hresp;
wire 	[15:2] 	apbs_paddr;
wire 	[31:0] 	apbs_pwdata;
wire 			apbs_psel0, apbs_psel1, apbs_psel2;
wire 			apbs_penable;
wire			apbs_pwrite;
wire 	[31:0] 	apbs_prdata0, apbs_prdata1, apbs_prdata2;
// Timer
wire 			tm_fbenable, tm_extclk1, tm_extclk2, tm_extclk3, tm_extclk4;
wire 			tm_overflow2, tm_overflow3, tm_overflow4;
// MIPS
wire 			fb_int;
wire 			pm_dcachehit;
wire 			pm_dcachemiss;
wire 			pm_dtlbhit;
wire 			pm_dtlbmiss;
wire 			pm_icachehit;
wire 			pm_icachemiss;
wire 			pm_itlbhit;
wire 			pm_itlbmiss;
wire 			pm_instncomplete;
wire 			pm_jtlbhit;
wire 			pm_jtlbmiss;
wire 			pm_wtbmerge;
wire 			pm_wtbnomerge;
wire 			si_rp;
wire 			si_sleep;
// PCI Signal Setting
wire 	[15:0] 	AF_PCI_DEVID = 16'h1234;
wire 	[15:0] 	AF_PCI_VENID = 16'h11E3;
wire 	[23:0] 	AF_PCI_CLASSCODE = 24'habcdef;
wire 	[7:0] 	AF_PCI_REVID = 8'h34;
wire 	[15:0] 	AF_PCI_SUBSYSID = 16'h22;
wire 	[15:0] 	AF_PCI_SUBSYSVID = 16'h11E3;
wire 	[7:0] 	AF_PCI_MAXLAT = 8'h55;
wire 	[7:0] 	AF_PCI_MINGNT = 8'h44;
wire 			AF_PCI_HOST = 1'b1;
wire 			AF_PCI_CFGDONE = 1'b1;

// Tied to Low (Unused Signals)
assign apbs_prdata0 = 32'b0;
assign apbs_prdata1 = 32'b0;
assign apbs_prdata2 = 32'b0;

assign tm_fbenable = 1'b0;
assign tm_extclk1 = 1'b0;
assign tm_extclk2 = 1'b0;
assign tm_extclk3 = 1'b0;
assign tm_extclk4 = 1'b0;

assign ahbm_hprot = 4'b0000;
assign fb_int = 1'b0;

// Call Embedded Hard Macro
qmipsesp QuickMIPScore (

	/**************/
	/*  ESP Pads  */
	/**************/
	// MC Pad signals off-chip
	.CS_n(CS_n),
	.WEN_n(WEN_n),
	.BLS_n(BLS_n),
	.OEN_n(OEN_n),
	.BOOT(BOOT),
	.ADDR(ADDR),
	.DATA(DATA),
	.SD_DQM(SD_DQM),
	.SD_CS_n(SD_CS_n),
	.SD_CKE(SD_CKE),
	.SD_RAS_n(SD_RAS_n),
	.SD_CAS_n(SD_CAS_n),
	.SD_WE_n(SD_WE_n),
	.SD_CLKOUT(SD_CLKOUT),
	.SD_CLKIN(SD_CLKIN),
	// U1 Pad signals off-chip
	.U1_TXD_SIROUT_n(U1_TXD_SIROUT_n),
	.U1_RXD_SIRIN(U1_RXD_SIRIN),
	.U1_CTS_n(U1_CTS_n),
	.U1_DCD_n(U1_DCD_n),
	.U1_DSR_n(U1_DSR_n),
	.U1_RI_n(U1_RI_n),
	.U1_DTR_n(U1_DTR_n),
	.U1_RTS_n(U1_RTS_n),
	// U2 Pad signals off-chip
	.U2_RXD_SIRIN(U2_RXD_SIRIN),
	.U2_TXD_SIROUT_n(U2_TXD_SIROUT_n),
	// PL Pad signals off-chip
	.PL_CLOCKIN(PL_CLOCKIN),
	.PL_RESET_n(PL_RESET_n),
	.PL_WARMRESET_n(PL_WARMRESET_n),
	.PL_ENABLE(PL_ENABLE),
	.PL_CLKOUT(PL_CLKOUT),
	.PL_BYPASS(PL_BYPASS),
	.PL_LOCK(PL_LOCK),
	// GL Pad signals off-chip
	.CPU_BIGENDIAN(CPU_BIGENDIAN),
	.CPU_EXTINT_n(CPU_EXTINT_n),
	// JD Pad signals off-chip
	.EJTAG_DEBUGM( EJTAG_DEBUGM ),
	.EJTAG_DINT( EJTAG_DINT ),
	.EJTAG_TCK( EJTAG_TCK ),
	.EJTAG_TDI( EJTAG_TDI ),
	.EJTAG_TDO( EJTAG_TDO ),
	.EJTAG_TMS( EJTAG_TMS ),
	.EJTAG_TRST( EJTAG_TRST ),
	// PC Pad signals off-chip
	.PCI_AD(PCI_AD),
	.PCI_C_BE_n(PCI_C_BE_n),
	.PCI_PAR(PCI_PAR),
	.PCI_FRAME_n(PCI_FRAME_n),
	.PCI_IRDY_n(PCI_IRDY_n),
	.PCI_TRDY_n(PCI_TRDY_n),
	.PCI_STOP_n(PCI_STOP_n),
	.PCI_DEVSEL_n(PCI_DEVSEL_n),
	.PCI_IDSEL(PCI_IDSEL),
	.PCI_SERR_n(PCI_SERR_n),
	.PCI_PERR_n(PCI_PERR_n),
	.PCI_REQ_n(PCI_REQ_n),
	.PCI_GNT_n(PCI_GNT_n),
	.PCI_LOCK_n(PCI_LOCK_n),
	.PCI_INTA_n(PCI_INTA_n),
	.PCI_CLK(PCI_CLK),
	.PCI_RST_n(PCI_RST_n),
	// TM Pad signals off-chip
	.TM_OVERFLOW(TM_OVERFLOW),
	.TM_ENABLE(TM_ENABLE),
	// M1 Pad signals off-chip
	.M1_CRS(M1_CRS),
	.M1_COL(M1_COL),
	.M1_RXCLK(M1_RXCLK),
	.M1_RXD(M1_RXD),
	.M1_RXDV(M1_RXDV),
	.M1_RXER(M1_RXER),
	.M1_TXCLK(M1_TXCLK),
	.M1_MDC(M1_MDC),
	.M1_TXD(M1_TXD),
	.M1_TXEN(M1_TXEN),
	.M1_MDIO(M1_MDIO),
	// M2 Pad signals off-chip
	.M2_CRS(M2_CRS),
	.M2_COL(M2_COL),
	.M2_RXCLK(M2_RXCLK),
	.M2_RXD(M2_RXD),
	.M2_RXDV(M2_RXDV),
	.M2_RXER(M2_RXER),
	.M2_TXCLK(M2_TXCLK),
	.M2_MDC(M2_MDC),
	.M2_TXD(M2_TXD),
	.M2_TXEN(M2_TXEN),
	.M2_MDIO(M2_MDIO),

	/**************/
	/* Fabric IOs */
	/**************/
	// Interface ports for AHB & APB
	// common clock for both AHB & APB
	.hclk(hclk),
	// common reset for both AHB master & slave, active-low
	.hresetn(hresetn),
	// AHB master
	.ahbm_haddr(ahbm_haddr),
	.ahbm_htrans(ahbm_htrans),
	.ahbm_hwrite(ahbm_hwrite),
	.ahbm_hsize(ahbm_hsize),
	.ahbm_hburst(ahbm_hburst),
	.ahbm_hprot(ahbm_hprot),
	.ahbm_hwdata(ahbm_hwdata),
	.ahbm_hrdata(ahbm_hrdata),
	.ahb_hready_in(ahb_hready_in),
	.ahbm_hresp(ahbm_hresp),
	.ahbm_hbusreq(ahbm_hbusreq),
	.ahbm_hgrant(ahbm_hgrant),
	// AHB slave
	.ahbs_hsel(ahbs_hsel),
	.ahbs_haddr(ahbs_haddr),
	.ahbs_htrans(ahbs_htrans),
	.ahbs_hwrite(ahbs_hwrite),
	.ahbs_hsize(ahbs_hsize),
	.ahbs_hburst(ahbs_hburst),
	.ahbs_hprot(ahbs_hprot),
	.ahbs_hwdata(ahbs_hwdata),
	.ahbs_hrdata(ahbs_hrdata),
	.ahbs_hready_out(ahbs_hready_out),
	.ahbs_hresp(ahbs_hresp),
	// APB slave, shared signals
	.apbs_paddr(apbs_paddr[15:2]),
	.apbs_penable(apbs_penable),
	.apbs_pwrite(apbs_pwrite),
	.apbs_pwdata(apbs_pwdata),
	// APB unique signals
	.apbs_psel0(apbs_psel0),
	.apbs_psel1(apbs_psel1),
	.apbs_psel2(apbs_psel2),
	.apbs_prdata0(apbs_prdata0),
	.apbs_prdata1(apbs_prdata1),
	.apbs_prdata2(apbs_prdata2),
	// Interface ports for Timer
	.tm_fbenable(tm_fbenable),
	.tm_extclk1(tm_extclk1),
	.tm_extclk2(tm_extclk2),
	.tm_extclk3(tm_extclk3),
	.tm_extclk4(tm_extclk4),
	.tm_overflow2(tm_overflow2),
	.tm_overflow3(tm_overflow3),
	.tm_overflow4(tm_overflow4),
	// MIPS	Core Connections 
	.fb_int(fb_int),
	.pm_dcachehit(pm_dcachehit),
	.pm_dcachemiss(pm_dcachemiss),
	.pm_dtlbhit(pm_dtlbhit),
	.pm_dtlbmiss(pm_dtlbmiss),
	.pm_icachehit(pm_icachehit),
	.pm_icachemiss(pm_icachemiss),
	.pm_itlbhit(pm_itlbhit),
	.pm_itlbmiss(pm_itlbmiss),
	.pm_instncomplete(pm_instncomplete),
	.pm_jtlbhit(pm_jtlbhit),
	.pm_jtlbmiss(pm_jtlbmiss),
	.pm_wtbmerge(pm_wtbmerge),
	.pm_wtbnomerge(pm_wtbnomerge),
	.si_rp(si_rp),
	.si_sleep(si_sleep),
	// QuickMIPS antifuses
	// PCI block
	.AF_PCI_DEVID(AF_PCI_DEVID),
	.AF_PCI_VENID(AF_PCI_VENID),
	.AF_PCI_CLASSCODE(AF_PCI_CLASSCODE),
	.AF_PCI_REVID(AF_PCI_REVID),
	.AF_PCI_SUBSYSID(AF_PCI_SUBSYSID),
	.AF_PCI_SUBSYSVID(AF_PCI_SUBSYSVID),
	.AF_PCI_MAXLAT(AF_PCI_MAXLAT),
	.AF_PCI_MINGNT(AF_PCI_MINGNT),
	.AF_PCI_HOST(AF_PCI_HOST),
	.AF_PCI_CFGDONE(AF_PCI_CFGDONE)
);

parameter C2Q_DLY = 1;

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
