module demo_amba (
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
  U1_TXD_SIROUT_n,
  U1_RXD_SIRIN,
  U1_CTS_n,
  U1_DCD_n,
  U1_DSR_n,
  U1_RI_n,
  U1_DTR_n,
  U1_RTS_n,
  U2_RXD_SIRIN,
  U2_TXD_SIROUT_n,
  PL_CLOCKIN,
  PL_RESET_n,
  PL_WARMRESET_n,
  PL_ENABLE,
  PL_CLKOUT,
  PL_BYPASS,
  PL_LOCK,
  CPU_BIGENDIAN,
  CPU_EXTINT_n,
  EJTAG_DEBUGM,
  EJTAG_DINT,
  EJTAG_TCK,
  EJTAG_TDI,
  EJTAG_TDO,
  EJTAG_TMS,
  EJTAG_TRST,
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
  TM_OVERFLOW,
  TM_ENABLE,
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
  LED8
);
output [7:0] CS_n;
output WEN_n;
output [3:0] BLS_n;
output OEN_n;
input [1:0] BOOT;
output [23:0] ADDR;
inout [31:0] DATA;
output [3:0] SD_DQM;
output [3:0] SD_CS_n;
output [3:0] SD_CKE;
output SD_RAS_n;
output SD_CAS_n;
output SD_WE_n;
output SD_CLKOUT;
input SD_CLKIN;
output U1_TXD_SIROUT_n;
input U1_RXD_SIRIN;
input U1_CTS_n;
input U1_DCD_n;
input U1_DSR_n;
input U1_RI_n;
output U1_DTR_n;
output U1_RTS_n;
input U2_RXD_SIRIN;
output U2_TXD_SIROUT_n;
input PL_CLOCKIN;
input PL_RESET_n;
input PL_WARMRESET_n;
input PL_ENABLE;
output PL_CLKOUT;
input PL_BYPASS;
output PL_LOCK;
input CPU_BIGENDIAN;
input [6:0] CPU_EXTINT_n;
output EJTAG_DEBUGM;
input EJTAG_DINT;
input EJTAG_TCK;
input EJTAG_TDI;
output EJTAG_TDO;
input EJTAG_TMS;
input EJTAG_TRST;
inout [31:0] PCI_AD;
inout [3:0] PCI_C_BE_n;
inout PCI_PAR;
inout PCI_FRAME_n;
inout PCI_IRDY_n;
inout PCI_TRDY_n;
inout PCI_STOP_n;
inout PCI_DEVSEL_n;
input PCI_IDSEL;
output PCI_SERR_n;
output PCI_PERR_n;
output PCI_REQ_n;
input PCI_GNT_n;
input PCI_LOCK_n;
output PCI_INTA_n;
input PCI_CLK;
input PCI_RST_n;
output TM_OVERFLOW;
input TM_ENABLE;
input M1_CRS;
input M1_COL;
input M1_RXCLK;
input [3:0] M1_RXD;
input M1_RXDV;
input M1_RXER;
input M1_TXCLK;
output M1_MDC;
output [3:0] M1_TXD;
output M1_TXEN;
inout M1_MDIO;
input M2_CRS;
input M2_COL;
input M2_RXCLK;
input [3:0] M2_RXD;
input M2_RXDV;
input M2_RXER;
input M2_TXCLK;
output M2_MDC;
output [3:0] M2_TXD;
output M2_TXEN;
inout M2_MDIO;
output [7:0] LED8;
