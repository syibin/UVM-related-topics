/*************************************************
**
**  QuickMips for rtl simulation 
**
**************************************************
**  GeunHag La
**************************************************/


`timescale 1ns/1ns

module qmipsesp (

		/**************/
		/* System IOs */
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

		/*****************************/
		/* Interface ports to fabric */
		/*****************************/

		// AHB & APB
		hclk,
		hresetn,
		// AHB master
		ahbm_haddr,
		ahbm_htrans,
		ahbm_hwrite,
		ahbm_hsize,
		ahbm_hburst,
		ahbm_hprot,
		ahbm_hwdata,
		ahbm_hrdata,
		ahb_hready_in,
		ahbm_hresp,
		ahbm_hbusreq,
		ahbm_hgrant,
		// AHB slave
		ahbs_hsel,
		ahbs_haddr,
		ahbs_htrans,
		ahbs_hwrite,
		ahbs_hsize,
		ahbs_hburst,
		ahbs_hprot,
		ahbs_hwdata,
		ahbs_hrdata,
		ahbs_hready_out,
		ahbs_hresp,
		// APB slave, shared signals
		apbs_paddr,
		apbs_penable,
		apbs_pwrite,
		apbs_pwdata,
		// APB unique signals
		apbs_psel0,
		apbs_psel1,
		apbs_psel2,
		apbs_prdata0,
		apbs_prdata1,
		apbs_prdata2,
		// Timer
		tm_fbenable,
		tm_extclk1,
		tm_extclk2,
		tm_extclk3,
		tm_extclk4,
		tm_overflow2,
		tm_overflow3,
		tm_overflow4,
		// MIPS
		fb_int,
		pm_dcachehit,
		pm_dcachemiss,
		pm_dtlbhit,
		pm_dtlbmiss,
		pm_icachehit,
		pm_icachemiss,
		pm_itlbhit,
		pm_itlbmiss,
		pm_instncomplete,
		pm_jtlbhit,
		pm_jtlbmiss,
		pm_wtbmerge,
		pm_wtbnomerge,
		si_rp,
		si_sleep,
		// PCI block
		AF_PCI_DEVID,
		AF_PCI_VENID,
		AF_PCI_CLASSCODE,
		AF_PCI_REVID,
		AF_PCI_SUBSYSID,
		AF_PCI_SUBSYSVID,
		AF_PCI_MAXLAT,
		AF_PCI_MINGNT,
		AF_PCI_HOST,
		AF_PCI_CFGDONE
) /* synthesis syn_black_box syn_macro=1 */;

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
input          PL_RESET_n; // Inverted polarity per Hyong. Hari 5/22/01
input          PL_WARMRESET_n; // Inverted polarity per Hyong. Hari 5/22/01
input          PL_ENABLE;
input          PL_BYPASS;
output         PL_CLKOUT;
output         PL_LOCK  ;
// GL Pad signals off-chip
input  [6:0]   CPU_EXTINT_n; // Inverted polarity per Hyong. Hari 5/22/01
input          CPU_BIGENDIAN;
// JD Pad signals off-chip
input          EJTAG_DINT; // 5/9
output         EJTAG_DEBUGM; // 5/9
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
inout          PCI_PERR_n;
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

// AHB & APB interface signals
output hclk /* synthesis syn_isclock = 1 */;
output hresetn;
input [31:0] ahbm_haddr;
input [1:0] ahbm_htrans;
input ahbm_hwrite;
input [2:0] ahbm_hsize;
input [2:0] ahbm_hburst;
input [3:0] ahbm_hprot;
input [31:0] ahbm_hwdata;
output [31:0] ahbm_hrdata;
output ahb_hready_in;
output [1:0] ahbm_hresp;
input ahbm_hbusreq;
output ahbm_hgrant;
output ahbs_hsel;
output [31:0] ahbs_haddr;
output [1:0] ahbs_htrans;
output ahbs_hwrite;
output [2:0] ahbs_hsize;
output [2:0] ahbs_hburst;
output [3:0] ahbs_hprot;
output [31:0] ahbs_hwdata;
input [31:0] ahbs_hrdata;
input ahbs_hready_out;
input [1:0] ahbs_hresp;
output [15:2] apbs_paddr;
output [31:0] apbs_pwdata;
output apbs_psel0, apbs_psel1, apbs_psel2;
output apbs_penable;
output apbs_pwrite;
input [31:0] apbs_prdata0, apbs_prdata1, apbs_prdata2;
// Timer
input tm_fbenable, tm_extclk1, tm_extclk2, tm_extclk3, tm_extclk4;
output tm_overflow2, tm_overflow3, tm_overflow4;
// MIPS
input fb_int;
output pm_dcachehit;
output pm_dcachemiss;
output pm_dtlbhit;
output pm_dtlbmiss;
output pm_icachehit;
output pm_icachemiss;
output pm_itlbhit;
output pm_itlbmiss;
output pm_instncomplete;
output pm_jtlbhit;
output pm_jtlbmiss;
output pm_wtbmerge;
output pm_wtbnomerge;
output si_rp;
output si_sleep;
// PCI
input [15:0] AF_PCI_DEVID;
input [15:0] AF_PCI_VENID;
input [23:0] AF_PCI_CLASSCODE;
input [7:0] AF_PCI_REVID;
input [15:0] AF_PCI_SUBSYSID;
input [15:0] AF_PCI_SUBSYSVID;
input [7:0] AF_PCI_MAXLAT;
input [7:0] AF_PCI_MINGNT;
input AF_PCI_HOST;
input AF_PCI_CFGDONE;

/*****************************/
/*   System Core Instance    */
/*****************************/

core core_inst (

   // FB

   .n(n),
   .p(p),
   .pllpad_n(pllpad_n),
   .pllpad_p(pllpad_p),
   .pad(pad),
   .progpad(progpad),
   .clkpad(clkpad),
   .gndana(gndana),
   .inref(inref),
   .ioclkpad(ioclkpad),
   .pllout_pad(pllout_pad),
   .pllrst(pllrst),
   .stm(stm),
   .vddio(vddio),
   .vddana(vddana),
//   .tdo(tdo), // This is output of pad and not 
                // from core_inst/fb_inst. Hari 5/29/01
   .up(up),     // These two are used to derive tdo
   .dwn(dwn),   // See file pad_top.v
   // MC

   .io_mc_xdatain(io_mc_xdatain),
   .io_mc_clkin(io_mc_clkin),
   .io_mc_boot(io_mc_boot),

   .mc_io_xcs_sm(mc_io_xcs_sm),
   .mc_io_xwen_sm_n(mc_io_xwen_sm_n),
   .mc_io_xbls_sm_n(mc_io_xbls_sm_n),
   .mc_io_xoen_sm_n(mc_io_xoen_sm_n),

   .mc_io_xaddr(mc_io_xaddr),
   .mc_io_xdataout(mc_io_xdataout),
   .mc_io_xdataen_n(mc_io_xdataen_n),
   .mc_io_xdqm_sd(mc_io_xdqm_sd),
   .mc_io_xcs_sd_n(mc_io_xcs_sd_n),
   .mc_io_xcke_sd(mc_io_xcke_sd),
   .mc_io_xras_sd_n(mc_io_xras_sd_n),
   .mc_io_xcas_sd_n(mc_io_xcas_sd_n),
   .mc_io_xwe_sd_n(mc_io_xwe_sd_n),
   .mc_io_xclkout_sd(mc_io_xclkout_sd),

   // U1

   .u1_io_txd_sirout_n(u1_io_txd_sirout_n),
   .io_u1_rxd_sirin(io_u1_rxd_sirin),
   .io_u1_cts_n(io_u1_cts_n),
   .io_u1_dcd_n(io_u1_dcd_n),
   .io_u1_dsr_n(io_u1_dsr_n),
   .io_u1_ri_n(io_u1_ri_n),
   .u1_io_dtr_n(u1_io_dtr_n),
   .u1_io_rts_n(u1_io_rts_n),

   // U2

   .io_u2_rxd_sirin(io_u2_rxd_sirin),
   .u2_io_txd_sirout_n(u2_io_txd_sirout_n),

   // PL

   .io_pl_clockin(io_pl_clockin),
   .io_pl_coldreset(io_pl_coldreset),
   .io_pl_warmreset(io_pl_warmreset),
   .io_pl_pll_en(io_pl_pll_en),
   .io_pl_bypass(io_pl_bypass),
//   .io_pl_agnd(io_pl_agnd),
//   .io_pl_avdd(io_pl_avdd),

   .io_al_bigendian(io_al_bigendian),
   .pl_io_clkout(pl_io_clkout),
   .pl_io_lock  (pl_io_lock),
	.io_gl_bypass_fb (io_gl_bypass_fb ),

   .io_gl_extint(io_gl_extint),
   .io_gl_spare_in (io_gl_spare_in ), // 5/9
//   .gl_io_spare_out(gl_io_spare_out), // 5/9
//   .gl_io_spare_outen_n(gl_io_spare_outen_n), // 5/9
   // JD

   .io_dt_tst_scanmode(io_dt_tst_scanmode),
   .io_dt_tst_bistmode(io_dt_tst_bistmode),
   .jd_io_ej_debugm(jd_io_ej_debugm),
   .io_jd_ej_dint(io_jd_ej_dint),
   .io_jd_ej_tck(io_jd_etck),
   .io_jd_ej_tdi(io_jd_etdi),
   .jd_io_ej_tdo(jd_io_etdo),
   .io_jd_ej_tms(io_jd_etms),
   .io_jd_ej_trst_n(io_jd_etrst),

   // PC

   .pc_io_adout(pc_io_adout),
   .pc_io_adout_en_n(pc_io_adout_en_n),
   .io_pc_adin(io_pc_adin),
   .pc_io_c_beout_n(pc_io_c_beout_n),
   .pc_io_c_beout_en_n(pc_io_c_beout_en_n),
   .io_pc_c_bein_n(io_pc_c_bein_n),
   .pc_io_parout(pc_io_parout),
   .pc_io_parout_en_n(pc_io_parout_en_n),
   .io_pc_parin(io_pc_parin),
   .pc_io_frameout_n(pc_io_frameout_n),
   .pc_io_frameout_en_n(pc_io_frameout_en_n),
   .io_pc_framein_n(io_pc_framein_n),
   .pc_io_irdyout_n(pc_io_irdyout_n),
   .pc_io_irdyout_en_n(pc_io_irdyout_en_n),
   .io_pc_irdyin_n(io_pc_irdyin_n),
   .pc_io_trdyout_n(pc_io_trdyout_n),
   .pc_io_ctrl_en_n(pc_io_ctrl_en_n),
   .io_pc_trdyin_n(io_pc_trdyin_n),
   .pc_io_stopout_n(pc_io_stopout_n),

   .io_pc_stopin_n(io_pc_stopin_n),
   .pc_io_devselout_n(pc_io_devselout_n),

   .io_pc_devselin_n(io_pc_devselin_n),


   .io_pc_idselin(io_pc_idselin),
   .pc_io_serr_n(pc_io_serr_n),
   .pc_io_perr_n(pc_io_perr_n),
   .pc_io_perr_en_n(pc_io_perr_en_n),
   .io_pc_perr_n(io_pc_perr_n),
   .pc_io_req_n(pc_io_req_n),
   .pc_io_req_en_n(pc_io_req_en_n),
   .io_pc_gnt_n(io_pc_gnt_n),
   .io_pc_lock_n(io_pc_lock_n),
   .pc_io_inta_n(pc_io_inta_n),
   .io_pc_clk(io_pc_clk),
   .io_pc_rst_n(io_pc_rst_n),

   // TM

   .tm_io_overflow(tm_io_overflow),
   .io_tm_enable(io_tm_enable),

   // M1

   .io_m1_crs(io_m1_crs),
   .io_m1_col(io_m1_col),
   .io_m1_rxclk(io_m1_rxclk),
   .io_m1_rxd(io_m1_rxd),
   .io_m1_rxdv(io_m1_rxdv),
   .io_m1_rxer(io_m1_rxer),
   .io_m1_txclk(io_m1_txclk),
   .m1_io_mdc(m1_io_mdc),
   .m1_io_txd(m1_io_txd),
   .m1_io_txen(m1_io_txen),
   .m1_io_mdo(m1_io_mdo),
   .m1_io_mdo_en_n(m1_io_mdo_en_n),
   .io_m1_mdi(io_m1_mdi),

   // M2

   .io_m2_crs(io_m2_crs),
   .io_m2_col(io_m2_col),
   .io_m2_rxclk(io_m2_rxclk),
   .io_m2_rxd(io_m2_rxd),
   .io_m2_rxdv(io_m2_rxdv),
   .io_m2_rxer(io_m2_rxer),
   .io_m2_txclk(io_m2_txclk),
   .m2_io_mdc(m2_io_mdc),
   .m2_io_txd(m2_io_txd),
   .m2_io_txen(m2_io_txen),
   .m2_io_mdo(m2_io_mdo),
   .m2_io_mdo_en_n(m2_io_mdo_en_n),
   .io_m2_mdi(io_m2_mdi),

	/*****************************/
	/* Interface ports to fabric */
	/*****************************/

	// AHB & APB
	.hclk(hclk),
	.hresetn(hresetn),
	// AHB master
	.fb_ac_haddr(ahbm_haddr),
	.fb_ac_htrans(ahbm_htrans),
	.fb_ac_hwrite(ahbm_hwrite),
	.fb_ac_hsize(ahbm_hsize),
	.fb_ac_hburst(ahbm_hburst),
	.fb_ac_hprot(ahbm_hprot),
	.fb_ac_hwdata(ahbm_hwdata),
	.fb_ac_hrdata(ahbm_hrdata),
	.fb_ac_hready(ahb_hready_in),
	.fb_ac_hresp(ahbm_hresp),
	.fb_ac_hbusreq(ahbm_hbusreq),
	.ac_fb_hgrant(ahbm_hgrant),
	// AHB slave
	.ac_fb_hsel(ahbs_hsel),
	.haddr(ahbs_haddr),
	.htrans(ahbs_htrans),
	.hwrite(ahbs_hwrite),
	.hsize(ahbs_hsize),
	.hburst(ahbs_hburst),
	.hprot(ahbs_hprot),
	.hwdata(ahbs_hwdata),
	.hrdata(ahbs_hrdata),
	.hready(ahbs_hready_out),
	.hresp(ahbs_hresp),
	// APB slave), shared signals
	.paddr(apbs_paddr),
	.penable(apbs_penable),
	.pwrite(apbs_pwrite),
	.pwdata(apbs_pwdata),
	// APB unique signals
	.ap_f1_psel(apbs_psel0),
	.ap_f2_psel(apbs_psel1),
	.ap_f3_psel(apbs_psel2),
	.f1_ap_prdata(apbs_prdata0),
	.f2_ap_prdata(apbs_prdata1),
	.f3_ap_prdata(apbs_prdata2),
	// Timer
	.fb_tm_tim_en(tm_fbenable),
	.fb_tm_extclk1(tm_extclk1),
	.fb_tm_extclk2(tm_extclk2),
	.fb_tm_extclk3(tm_extclk3),
	.fb_tm_extclk4(tm_extclk4),
	.tm_fb_overflow2(tm_overflow2),
	.tm_fb_overflow3(tm_overflow3),
	.tm_fb_overflow4(tm_overflow4),
	// MIPS
	.fb_gl_fb_int(fb_int),
	.jd_fb_pm_dcachehit(pm_dcachehit),
	.jd_fb_pm_dcachemiss(pm_dcachemiss),
	.jd_fb_pm_dtlbhit(pm_dtlbhit),
	.jd_fb_pm_dtlbmiss(pm_dtlbmiss),
	.jd_fb_pm_icachehit(pm_icachehit),
	.jd_fb_pm_icachemiss(pm_icachemiss),
	.jd_fb_pm_itlbhit(pm_itlbhit),
	.jd_fb_pm_itlbmiss(pm_itlbmiss),
	.jd_fb_pm_instncomplete(pm_instncomplete),
	.jd_fb_pm_jtlbhit(pm_jtlbhit),
	.jd_fb_pm_jtlbmiss(pm_jtlbmiss),
	.jd_fb_pm_wtbmerge(pm_wtbmerge),
	.jd_fb_pm_wtbnomerge(pm_wtbnomerge),
	.jd_fb_si_rp(si_rp),
	.jd_fb_si_sleep(si_sleep),
	// PCI block
	.AF_PC_DEVID(AF_PCI_DEVID),
	.AF_PC_VENID(AF_PCI_VENID),
	.AF_PC_CLASSCODE(AF_PCI_CLASSCODE),
	.AF_PC_REVID(AF_PCI_REVID),
	.AF_PC_SUBSYSID(AF_PCI_SUBSYSID),
	.AF_PC_SUBSYSVID(AF_PCI_SUBSYSVID),
	.AF_PC_MAXLAT(AF_PCI_MAXLAT),
	.AF_PC_MINGNT(AF_PCI_MINGNT),
	.AF_PC_HOST(AF_PCI_HOST),
	.AF_PC_CFGDONE(AF_PCI_CFGDONE)
         );

endmodule
