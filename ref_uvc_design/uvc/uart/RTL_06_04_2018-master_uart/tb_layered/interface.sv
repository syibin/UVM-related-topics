interface uart_interface(input bit clk);

    bit          rst_n;
    bit    [7:0] paddr;
    bit          psel;
    bit          penable;
    bit          pwrite;
    bit   [31:0] pwdata;
    bit    [3:0] pstrb;
    logic [31:0] prdata;
    bit          pready;
    logic        pslverr;
    logic  [2:0] interrupt;
    logic        cts;
    logic        txd;
    logic        rxd;
    logic        rts;
    logic        rx_trig_o;
    logic        tx_trig_o;

endinterface : uart_interface