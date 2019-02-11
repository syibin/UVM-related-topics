task driver::run_sim_txdata_check();

	bit [19:0] baud_cycle;
	bit [31:0] status;
	int i;

	baud_cycle 		  = (2 ** mode[31:16]) * (mode[3]? 4 : 16);
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

	uif.cts   <= 0;
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

		wait(uif.interrupt[0]);
		wait(uif.txd == 0);
		
		for(int i = 0; i <= 9+(mode[1]^mode[0])+mode[2]; i++) begin
			repeat(baud_cycle) @(posedge uif.clk);
			trn_drv.pwdata[i] = uif.txd;
			//$display("stop-parity : ", i);
			//$display("uif.txd : %b\t@%t", uif.txd, $realtime());
		end

		trn_scb 		  = trn_drv.copy();
		trn_scb.mode      = mode;
		trn_scb.special   = special;
		trn_scb.block_sel = block_sel;

		if(!(mode[1]^mode[0]) && !(mode[2])) begin
			trn_scb.pwdata[11:10] = 2'b00;
			//$display("stop-parity : %3b\tmode : %3b", trn_scb.pwdata[11:9], mode[2:0]);
		end
		else if(!(mode[1]^mode[0]) && (mode[2])) begin
			trn_scb.pwdata[11] = 1'b0;
		end
		else if((mode[1]^mode[0]) && !(mode[2])) begin
			trn_scb.pwdata[11] = 1'b0;
		end

		drv2scb.put(trn_scb);
		/*$display("trn_scb.pwdata : %8b", trn_scb.pwdata[8:1]);
		if(mode[1]^mode[0])	$display("PSEL : %2b\tparity : %b", mode[1:0], trn_scb.pwdata[9]);
		else if(mode[2])	$display("SSEL : %b\tstop : %2b", mode[2], trn_scb.pwdata[10:9]);*/

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
		
		while(!status[15]) begin 

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

endtask : run_sim_txdata_check