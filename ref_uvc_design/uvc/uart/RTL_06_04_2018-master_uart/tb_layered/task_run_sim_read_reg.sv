task driver::run_sim_read_reg();

	  ins_errors        = trans.ins_errors;
    character         = trans.pwdata;
    err_addr          = $urandom_range(0, 1);
    interrupts_config = trans.interrupts_config;


    print_test_config( `UART_STATUS_REGISTER,
                       mode,
                       interrupts_config,
                       LOOPBACK_CHARACTER_NUM
                      );

    uif.cts <= 1'b0;
    wait(uif.rst_n);
    repeat(10) @(posedge uif.clk);

    if(err_addr) $display("\nAPB Bus Error Check .... \n",);
    for(int i = 0; i < 6; i++) begin
   	
    	reg_access( `UART_BASE_ADDRESS + 4*i + err_addr,
            		  REG_RD,
            		  32'h0,
            		  4'h0,
            		  read_data,
            		  error
          		  );
    	if(read_data == init_reg_val[i])
    		 $display("\033[1;32mMatched !! Initial Value : %4h\tRead Value : %4h\033[0m", init_reg_val[i], read_data);
    	else $display("\033[1;31mMismatched !! Initial Value : %4h\tRead Value : %4h\033[0m", init_reg_val[i], read_data);

    end

    reg_access( `UART_BASE_ADDRESS + `UART_MODE_REGISTER,
                REG_WR,
                mode,
                4'h7,
                read_data,
                error
              );

    if(error) begin

      $display("\033[1;31mError occured during setting up UART's operation mode, address is 32'h%h, data is 32'h%h, byte enable is\033[0m",
               `UART_BASE_ADDRESS + 32'h8, mode, 4'h1
              );
      $finish(2);
      
    end

    reg_access( `UART_BASE_ADDRESS + `UART_MODE_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

    $display("\n\nMODE Register is initialized with the value %h", read_data);

    reg_access( `UART_BASE_ADDRESS + `UART_INTC_REGISTER,
                REG_WR,
                {29'b0, interrupts_config},
                4'h1,
                read_data,
                error
              );

    reg_access( `UART_BASE_ADDRESS + `UART_INTC_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

    $display("INTC Register is initialized with the value %3b", read_data);

    uif.cts <= 1'b1;

    reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
                REG_WR,
                character,
                4'h1,
                read_data,
                error
              );

    reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

    $display("TXBUF Register is initialized with the value %s    @Time:%t\n\n", read_data, $realtime);

    uif.cts   <= 1'b0;  //To clear cts pin, ow status[7] is always set in spite of reset
    uif.rst_n <= 1'b0;
    repeat(10) @(posedge uif.clk);
    uif.rst_n <= 1'b1;

    for(int i = 0; i < 6; i++) begin
    
      reg_access( `UART_BASE_ADDRESS + 4*i,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
                );
      if(read_data == init_reg_val[i])
         $display("\033[1;32mMatched !! Initial Value : %4h\tRead Value : %4h\033[0m", init_reg_val[i], read_data);
      else $display("\033[1;31mMismatched !! Initial Value : %4h\tRead Value : %4h\033[0m", init_reg_val[i], read_data);

    end

endtask : run_sim_read_reg