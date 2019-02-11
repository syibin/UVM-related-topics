//APB
input PCLK,
input PRESETn,
input [3:0] PADDR,
input PSEL,
input PENABLE,
input PWRITE,
input [`DATA_WIDTH-1:0] PWDATA,
output PREADY,
output [`DATA_WIDTH-1:0] PRDATA,
output PSLVERR,
// UART
input RXD,
output TXD
