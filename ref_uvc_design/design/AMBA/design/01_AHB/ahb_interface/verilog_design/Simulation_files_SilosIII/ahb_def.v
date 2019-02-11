// The AHB define file

parameter HIGH =    1'b1;
parameter LOW =     1'b0;

// Default address driven by the AHB Master.
parameter DEFAULT_ADDR = 32'd56565656;

// Default data bus size of the AHB Master.
parameter DEFAULT_SIZE = 3'b010; // 32 bit data bus

// Default write data driven by the AHB Master.
parameter DEFAULT_WDATA = 32'hbabe_face;
 
// Default read data driven by the AHB Slave.
parameter DEFAULT_RDATA = 32'hbabe_face;

// Default buffer size in bytes of the AHB Master
parameter AHBMST_BUF_SIZE = 16;
parameter AHBMST_BUF_DEPTH = 17'h10000;
 
// The size of the buffer which holds data to be transferred in a transaction.
// This number is in bytes.
// The actual size is (2^AHBSLV_BUF_SIZE) bytes.
parameter  AHBSLV_BUF_SIZE    = 16;  //64k bytes in the memory
// Verilog does not take exponentials, so have to use two parameters
parameter  AHBSLV_BUF_DEPTH   = 17'h10000;  //64k bytes in the memory

// The Response and Delay buffer size
parameter  AHBSLV_RESPBUF_DEPTH  =  32'h1000; // the max no.of beats in master

// max number of wait states for each data phase is (2^AHBSLV_MAXWS)
parameter MAXWS = 5;

parameter IN_DLY = 2;
parameter OUT_DLY = 4;
parameter MUX_DLY = 1;

// Transfer type from AHB Master
parameter  IDLE      =    2'h0;
parameter  BUSY      =    2'h1;
parameter  NONSEQ    =    2'h2;
parameter  SEQ       =    2'h3;

// Read or write type
parameter READ = 1'b0;
parameter WRITE = 1'b1;

// Type of the burst transfer
parameter  SINGLE    =    3'h0;
parameter  INCR      =    3'h1;
parameter  WRAP4     =    3'h2;
parameter  INCR4     =    3'h3;
parameter  WRAP8     =    3'h4;
parameter  INCR8     =    3'h5;
parameter  WRAP16    =    3'h6;
parameter  INCR16    =    3'h7;

// Slave Responses
parameter  OKAY      =    2'h0;
parameter  ERROR     =    2'h1;
parameter  RETRY     =    2'h2;
parameter  SPLIT     =    2'h3;

// Transfer Size
parameter  BUS_8     =    3'h0;
parameter  BUS_16    =    3'h1;
parameter  BUS_32    =    3'h2;
parameter  BUS_64    =    3'h3;
parameter  BUS_128   =    3'h4;
parameter  BUS_256   =    3'h5;
parameter  BUS_512   =    3'h6;
parameter  BUS_1024  =    3'h7;

// Number of clock cycles to wait before retrying
// Must be at least 1
parameter DLY_B4_RETRY = 3;
