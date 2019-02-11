`timescale 1ns/1ns

`include "ahbdec.v"
`include "ahbarb.v"
`include "ahbmst.v"
`include "ahbslv.v"
`include "demo_amba_for_tb.v"

module t;

`include "ahb_def.v"

reg           hclk;
reg           hresetn;
 
// master 0 signals
wire [31:0] mst0_addr;
wire [1:0] mst0_trans;
wire mst0_write;
wire [2:0] mst0_size;
wire [2:0] mst0_burst;
wire [31:0] mst0_wdata;
wire mst0_busreq;
wire mst0_grant;

// master 1 signals
wire [31:0] mst1_addr;
wire [1:0] mst1_trans;
wire mst1_write;
wire [2:0] mst1_size;
wire [2:0] mst1_burst;
wire [31:0] mst1_wdata;
wire mst1_busreq;
wire mst1_grant;

// slave 0 signals
wire slv0_ready;
wire [1:0] slv0_resp;
wire [31:0] slv0_rdata;

// slave 1 signals
wire slv1_ready;
wire [1:0] slv1_resp;
wire [31:0] slv1_rdata;

// mux outputs
wire [31:0] addr;
wire [1:0] trans;
wire write;
wire [2:0] size;
wire [2:0] burst;
wire [31:0] wdata;
wire ready;
wire [1:0] resp;
wire  [31:0] rdata;
 
// decoder output signals
wire slv0_hsel;
wire slv0_hsel_rd;
wire slv1_hsel;
wire slv1_hsel_rd;

// arbiter signals
wire mst2_grant, mst3_grant;
wire   [3:0]  master;       
wire   [3:0]  master_wd;

// other
wire   [7:0]  LED8;

// clock period
parameter ahb_clk = 16;

// instantiate AHB interface design (DUT)
demo_amba m (

	.hclk             (hclk),
	.hresetn          (hresetn),

    // shared AHB master/slave signals
	.ahb_hready_in    (ready),

    // AHB master signals
    .ahbm_hresp       (resp),
    .ahbm_hgrant      (mst1_grant),

    .ahbm_hbusreq     (mst1_busreq),
    .ahbm_htrans      (mst1_trans),
    .ahbm_hwrite      (mst1_write),
    .ahbm_hsize       (mst1_size),
    .ahbm_hburst      (mst1_burst),

    .ahbm_haddr       (mst1_addr),
    .ahbm_hwdata      (mst1_wdata),
	.ahbm_hrdata      (rdata),

    // AHB slave signals
	.ahbs_hsel        (slv1_hsel),
	.ahbs_haddr       (addr),
	.ahbs_htrans      (trans),
	.ahbs_hwrite      (write),
	.ahbs_hsize       (size),
	.ahbs_hburst      (burst),
	.ahbs_hwdata      (wdata),
	.ahbs_hrdata      (slv1_rdata),
	.ahbs_hready_out  (slv1_ready),
	.ahbs_hresp       (slv1_resp),

    // LED output
    .LED8			  (LED8)
);


// ahbmst 0
ahbmst ahbmst_inst (
  .hclk        (hclk),
  .hresetn     (hresetn),
  .haddr_o     (mst0_addr),
  .htrans_o    (mst0_trans),
  .hwrite_o    (mst0_write),
  .hburst_o    (mst0_burst),
  .hsize_o     (mst0_size),
  .hwdata_o    (mst0_wdata),
  .hready_i    (ready),
  .hresp_i     (resp),
  .hrdata_i    (rdata),
  .hbusreq_o   (mst0_busreq),
  .hgrant_i    (mst0_grant)
);

// ahbslv 0
ahbslv ahbslv_inst (
   .hclk        ( hclk   ),
   .hresetn     ( hresetn     ),
   .hsel_i      ( slv0_hsel ),
   .haddr_i     ( addr    ),
   .hwrite_i    ( write   ),
   .hsize_i     ( size    ),
   .htrans_i    ( trans   ),
   .hburst_i    ( burst   ),
   .hwdata_i    ( wdata   ),
   .hready_o    ( slv0_ready   ),
   .hresp_o     ( slv0_resp    ),
   .hrdata_o    ( slv0_rdata   ),
   .hready_i    ( ready )
);

//ahb bus decoder instatiation
ahbdec  ahb_dec_inst (
   .hclk     ( hclk           ),
   .hresetn  ( hresetn        ),
   .addr     ( addr       ),
   .ready    ( ready      ),
   .hsel0    ( ),
   .hsel0_rd ( ),
   .hsel1    ( slv1_hsel ),
   .hsel1_rd ( slv1_hsel_rd ),
   .hsel2    ( slv0_hsel ),
   .hsel2_rd ( slv0_hsel_rd )
);

// ahb arbiter
ahbarb ahbarb_inst (
   .hclk       ( hclk         ),
   .hresetn    ( hresetn      ),
   .hbusreqs   ( {mst0_busreq, mst1_busreq, 2'b0}),
   .haddr      ( addr     ),
   .htrans     ( trans    ),
   .hburst     ( burst    ),
   .hresp      ( resp     ),
   .hready     ( ready    ),
   .hgrants    ( {mst0_grant, mst1_grant, mst2_grant, mst3_grant} ),
   .hmaster    ( master    ),
   .hmaster_wd ( master_wd )
);

assign #MUX_DLY addr = (master == 3'b011) ? mst0_addr : ((master == 3'b010) ? mst1_addr : DEFAULT_ADDR);
assign #MUX_DLY write = (master == 3'b011) ? mst0_write : ((master == 3'b010) ? mst1_write : READ);
assign #MUX_DLY trans = (master == 3'b011) ? mst0_trans : ((master == 3'b010) ? mst1_trans : IDLE);
assign #MUX_DLY size = (master == 3'b011) ? mst0_size : ((master == 3'b010) ? mst1_size : BUS_32);
assign #MUX_DLY burst = (master == 3'b011) ? mst0_burst : ((master == 3'b010) ? mst1_burst : SINGLE);
assign #MUX_DLY wdata = (master_wd == 3'b011) ? mst0_wdata : ((master_wd == 3'b010) ? mst1_wdata : DEFAULT_WDATA);

//decoder signals will be controlled by both csr select and normal bridge select 
assign #MUX_DLY resp = (slv0_hsel_rd) ? slv0_resp : (slv1_hsel_rd ? slv1_resp : OKAY);
assign #MUX_DLY ready = (slv0_hsel_rd) ? slv0_ready : (slv1_hsel_rd ? slv1_ready : 1'b1);
assign #MUX_DLY rdata = (slv0_hsel_rd) ? slv0_rdata : (slv1_hsel_rd ? slv1_rdata : DEFAULT_RDATA);

always # (ahb_clk/2) hclk = ~hclk;

initial begin
   // ahb reset
   hclk    <= HIGH;
   hresetn <= LOW;
   repeat (10) @ (posedge hclk);
   hresetn <= HIGH;
end

wire [15:0] start_addr;
assign start_addr = 16'h4000;
reg pass_fail;
reg [31:0] j;

// this file should contain all the stimuli
`include "ahb_stimuli.v"

// this is the test vector file for ahbmst and ahbslv
//`include "qm_ahbmst_tasks.v"

endmodule
