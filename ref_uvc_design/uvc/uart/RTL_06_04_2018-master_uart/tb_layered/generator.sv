class generator;

    transaction trans, trn_drv, trn_scb;
    mailbox     gen2drv, gen2scb;
    event       trans_done;
    int         repeat_count;

    function new(mailbox gen2drv, gen2scb, event trans_done);
        this.gen2drv      = gen2drv;
        this.gen2scb      = gen2scb;
        this.trans_done   = trans_done;
    endfunction

    extern task signal_generate();
    extern task signal_display();

endclass : generator


task generator::signal_generate();

    $display("\n\n***************GENERATED SIGNALS***************\n\n");
    repeat(repeat_count) begin
        if(!trans.randomize()) begin
            $display("ERROR!!!!!!!!!!!!!!!!Randomization Failed!!!!!!!!!!!!!!"); 
            $finish(3);
        end
        trn_drv = trans.copy();
        trn_scb = trans.copy();
        gen2drv.put(trn_drv);
        gen2scb.put(trn_scb);
        signal_display();
        trans = new();
    end
    $display("\n\n***************END OF GENERATION***************\n\n");

endtask : signal_generate


task generator::signal_display();
    $display("pwdata = %s\t", trn_drv.pwdata, "mode = %h\t", trn_drv.mode, "cts = %b\t", trn_drv.cts, "special = %b\t", trn_drv.special, "block_sel = %b\t", trn_drv.block_sel, "interrupts_config = %3b", trn_drv.interrupts_config);
endtask : signal_display
