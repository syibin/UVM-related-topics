class environment;
    
    virtual uart_interface uif;
    event                  trans_done;
    mailbox                gen2drv, gen2scb, drv2scb;
    generator              gen;
    driver                 drv;
    scoreboard             scb;
 
    function new(virtual uart_interface uif);
        this.uif = uif;
        gen2drv  = new();
        gen2scb  = new();
        drv2scb  = new();
        gen      = new(gen2drv, gen2scb, trans_done);
        drv      = new(uif, gen2drv, drv2scb);
        scb      = new(gen2scb, drv2scb);
    endfunction

endclass : environment
