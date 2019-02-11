class transaction;

         bit        psel;
         bit  [7:0] paddr;
         bit        pwrite;
         bit  [3:0] pstrb;
         bit        penable;
    rand bit [31:0] mode;
    rand bit  [3:0] interrupts_config;
    rand bit  [1:0] ins_errors;
    rand bit [31:0] pwdata;
    rand bit        cts;
    rand bit  [1:0] block_sel;
    rand bit  [1:0] special;
    rand bit        tx_brk_ctrl;

    constraint data  { pwdata inside { [ 65:90 ] }; }
    constraint clear { cts == 1'b0; }

    virtual function transaction copy();
    
        copy = new();
        copy.psel              = psel;
        copy.paddr             = paddr;
        copy.pwrite            = pwrite;
        copy.pstrb             = pstrb;
        copy.mode              = mode;
        copy.pwdata            = pwdata;
        copy.cts               = cts;
        copy.block_sel         = block_sel;
        copy.special           = special;
        copy.ins_errors        = ins_errors;
        copy.interrupts_config = interrupts_config;

    endfunction : copy
  
endclass : transaction
