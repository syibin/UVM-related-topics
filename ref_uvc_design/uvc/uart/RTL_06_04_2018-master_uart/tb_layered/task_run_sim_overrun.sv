task driver:: run_sim_overrun();

	ins_errors        = trans.ins_errors;
    interrupts_config = trans.interrupts_config;


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
               `UART_BASE_ADDRESS + 32'h8, mode, 4'h1
              );
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

    reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
            	REG_RD,
            	32'h0,
            	4'h0,
            	read_data,
            	error
          	  );

    //repeat LOOPBACK_CHARACTER_NUM symbols receiption

    repeat(LOOPBACK_CHARACTER_NUM) begin : check_overrun

    	character = trans.pwdata;        
  		send_uart_char( ins_errors[1], ins_errors[0], mode, character );
  		reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
              		REG_RD,
              		32'h0,
              		4'h0,
              		read_data,
              		error
            	      );

	    if(read_data[1]) begin

		    $display("\033[1;31mOverrun Status Bit is Set.\033[0m");
		    while(!read_data[14]) begin : empty_rxbf

			    reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
			                REG_RD,
			                32'h0,
			                4'h0,
			                read_data,
			                error
			              );
			    $display("Data Read from RXBF : %s", read_data);
			    reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
		            		REG_RD,
		            		32'h0,
		            		4'h0,
		            		read_data,
		            		error
		          	      );

			  end : empty_rxbf

		end

		if(read_data[14]) $display("\033[1;32mRX Buffer is Empty.\033[0m");

		if(loop_count != 1) begin
	      gen2drv.get(trans);
	    end

	    loop_count--;

    end : check_overrun


endtask : run_sim_overrun