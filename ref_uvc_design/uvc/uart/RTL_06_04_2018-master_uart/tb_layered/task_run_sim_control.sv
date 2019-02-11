task driver::run_sim_control();

    gen2drv.get(trans);
    mode      = trans.mode;
    special   = trans.special;
    block_sel = trans.block_sel;

    $display("special : ", special, "\tblock_sel : ", block_sel);

    if(block_sel == 2'b00 && (special == 2'b00 || special == 2'b11)) begin  

        uif.rst_n <= 1'b0;
        repeat(20) @(posedge uif.clk);
        uif.rst_n <= 1'b1;

        uart_cg_receive.sample();
        $display("Entering Transmitter Verification Mode ....\n\n");
        run_sim_transmit();

    end

    else if(block_sel == 2'b01 && special == 2'b00) begin

        uif.rst_n <= 1'b0;
        repeat(20) @(posedge uif.clk);
        uif.rst_n <= 1'b1;

        uart_cg_receive.sample();
        $display("Entering Receiver Verification Mode ....\n\n");
        run_sim_receive();

    end

    else if(block_sel == 2'b10 && special == 2'b00) begin

        uif.rst_n <= 1'b0;
        repeat(20) @(posedge uif.clk);
        uif.rst_n <= 1'b1;

        uart_cg_loopback.sample();
        interrupts_config = trans.interrupts_config;

        if(interrupts_config == 3'b000) begin

            $display("Entering Loopback Verification Mode ....\n\n");
            run_sim_loop_back();

        end
        else if(interrupts_config == 3'b011) begin

            $display("Entering Loopback (SOC) Verification Mode ....\n\n");
            run_sim_loop_back_soc();

        end

    end

    else if(block_sel == 2'b01 && special == 2'b01) begin

        $display("Entering RX Buffer Overrun Verification Mode ....\n\n");
        run_sim_overrun();

    end

    else if(block_sel == 2'b00 && special == 2'b10) begin

        $display("Entering Register Read Verification Mode ....\n\n");
        run_sim_read_reg();

    end

endtask : run_sim_control