task driver::run_sim_transmit_m0090();

	bit [19:0] baud_cycle;
	bit [31:0] status;

	baud_cycle = (2 ** mode[31:16]) * (mode[3]? 4 : 16);
	interrupts_config = trans.interrupts_config;
	ins_errors 		  = trans.ins_errors;

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
	status     = read_data;
	uif.cts   <= trans.cts;
	character  = trans.pwdata;

    repeat (LOOPBACK_CHARACTER_NUM) begin : transmit

    	reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
				    REG_WR,
				    character,
				    4'h1,
				    read_data,
				    error
				  );
		$display("Wrote character \"%s\" into TXBUF @%t", character, $time);
		
		/*while(status[6]) begin 

		$display("\033[1;31mTransmission is in progress now.\tStatus : %10b\tTime : %t\033[0m",status, $realtime);*/
		wait(uif.interrupt[0]);
		$display("\033[1;32mInterrupt has been asserted.\tStatus : %10b\tTime : %t\033[0m",status, $realtime);

		//clear interrupt

		reg_access( `UART_BASE_ADDRESS + `UART_INTF_REGISTER,
			        REG_WR,
			        {29'b0, 3'b111},
			        4'h1,
			        read_data,
			        error
			      );

		/*wait for txbuf to be empty(actually wait for "not full"; as there is no status bit for TXBUF to be empty.
									 Existing one(TXBF) only care about whether it is full or not; but not full 
									 does not necesserily mean empty all the time.)*/
		
		while(status[5]) begin 

			reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
				        REG_RD,
				        32'h0,
				        4'h0,
				        read_data,
				        error
				      );
			status = read_data;

		end

		if(loop_count != 1) begin

		    gen2drv.get(trans);
		    character = trans.pwdata; 

		end

	    loop_count--;

    end : transmit

    print_test_result("PASSED");

endtask : run_sim_transmit_m0090
