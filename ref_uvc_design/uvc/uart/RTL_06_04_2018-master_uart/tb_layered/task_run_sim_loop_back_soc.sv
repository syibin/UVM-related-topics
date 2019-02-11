task driver::run_sim_loop_back_soc();

    //interrupts_config = trans.interrupts_config;

    print_test_config( `UART_STATUS_REGISTER,
                       mode,
                       interrupts_config,
                       LOOPBACK_CHARACTER_NUM
                     );

    wait(uif.rst_n);
    repeat(10) @(posedge uif.clk);

    //program MODE register

    reg_access( `UART_BASE_ADDRESS + `UART_MODE_REGISTER,
                REG_WR,
                mode,
                4'h3,
                read_data,
                error
              );

    if(error) begin

        $display("Error occured during setting up UART's operation mode, address is 32'h%h, data is 32'h%h, byte enable is",
        `UART_BASE_ADDRESS + 32'h8, mode, 4'h1);
        $finish(2);

    end

    //program INTC Register

    reg_access( `UART_BASE_ADDRESS + `UART_INTC_REGISTER,
                REG_WR,
                {29'b0, interrupts_config},
                4'h1,
                read_data,
                error
              );
    $display("%t", $realtime());

    //iterate `LOOPBACK_LOOPBACK_CHARACTER_NUM times write_character-read_character-compare_them sequence

    repeat (LOOPBACK_CHARACTER_NUM) begin : send_receive

        //check if the TXBUF is not full and write new character for transmission

        do  begin : check_txbuf

            reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
                        REG_RD,
                        32'h0,
                        4'h0,
                        read_data,
                        error
                      );
            end : check_txbuf
            
        while(read_data[5]);

        character = trans.pwdata; 

        reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
                    REG_WR,
                    character,
                    4'h1,
                    read_data,
                    error
                 );

        $display("Wrote character \"%s\" into TXBUF @%t", character, $time);

        //wait for a character beeing received in RXBUF

        /*do begin : wait_for_rxda

            reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
                        REG_RD,
                        32'h0,
                        4'h0,
                        read_data,
                        error
                      );

            end : wait_for_rxda
         while(!read_data[0]);*/

        wait(uif.interrupt[0]);
        wait(uif.interrupt[1]);

        //read received character

        reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                    REG_RD,
                    32'h0,
                    4'h0,
                    read_data,
                    error
                  );

        $display("Read character  \"%s\" from RXBUF @%t\n\n", read_data[7:0], $time);

        trn_drv.pwdata    = read_data[7:0];
        trn_scb           = trn_drv.copy();
        trn_scb.mode      = mode;
        trn_scb.special   = special;
        trn_scb.block_sel = block_sel;
        drv2scb.put(trn_scb);

        //compare sent and received characters
        
        /*if(read_data[7:0] != character) begin : data_mismatch

            $display("\033[1;31mThere is a mismatch between sent and received character, sent %s, received %s\033[0m", character, read_data[7:0]);
            print_test_result("\033[1;31mFAILED\033[0m");
            $finish(2);

        end : data_mismatch

        $display("\033[1;32mWritten and read characters matched \033[0m\n");*/

        //clear interrupt flag register

        reg_access( `UART_BASE_ADDRESS + `UART_INTF_REGISTER,
                    REG_WR,
                    {29'b0, 3'b111},
                    4'h1,
                    read_data,
                    error
                  );

        if(loop_count != 1) begin

            gen2drv.get(trans);
            character = trans.pwdata; 

        end

        loop_count--;

    end : send_receive

    //clean interrupt flags

    reg_access( `UART_BASE_ADDRESS + `UART_INTF_REGISTER,
                REG_WR,
                {29'b0, 3'b111},
                4'h1,
                read_data,
                error
              );

    //print_test_result("PASSED");
    //$finish(2);

endtask : run_sim_loop_back_soc