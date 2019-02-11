task driver::run_sim_transmit_m2090();

	bit [19:0] baud_cycle;
	bit [31:0] status;
	int i;

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

    i = 0;

    reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
		        REG_RD,
		        32'h0,
		        4'h0,
		        read_data,
		        error
		      );
	status     = read_data;
	//uif.cts   <= trans.cts;  //1
	character  = trans.pwdata;

    repeat (LOOPBACK_CHARACTER_NUM) begin : transmit

		uif.cts   <= 1;
		//write until txbuf is full

		while(!status[5]) begin

			reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
				    	REG_WR,
				    	character,
				    	4'h1,
				    	read_data,
				    	error
				  	  );
			$display("Wrote character \"%s\" into TXBUF @%t", character, $time);
			reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
				        REG_RD,
				        32'h0,
				        4'h0,
				        read_data,
				        error
				      );
			status 	  = read_data;
			character = $urandom_range(65, 90);
			i++;

		end

		$display("COUNT : ",i);
		i = 0;
		uif.cts   <= trans.cts;
		
		wait(uif.interrupt[0]);
		reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
				    REG_RD,
				    32'h0,
				    4'h0,
				    read_data,
				    error
				  );
		status 	  = read_data;

		$display("\033[1;32mInterrupt has been asserted.\tTRMT : %b\tTBE : %b\tTime : %t\033[0m", status[6], status[15], $realtime);

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

    end : transmit

    print_test_result("PASSED");

endtask : run_sim_transmit_m2090
