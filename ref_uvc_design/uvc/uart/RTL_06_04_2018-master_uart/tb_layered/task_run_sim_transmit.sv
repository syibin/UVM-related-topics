task driver::run_sim_transmit();

	if(special == 2'b00) begin

		if     (mode == 32'h0000_0090 || mode == 32'h0000_3090)  run_sim_transmit_m0090();
	    else if(mode == 32'h0000_1090)                           run_sim_transmit_m1090();
	    else if(mode == 32'h0000_2090)                           run_sim_transmit_m2090();

	end

	else if(special == 2'b11)	begin
		uart_cg_receive.sample();
		if($urandom_range(0, 1)) begin : TXO
			$display("Character Transmission ....\n");
			run_sim_txdata_check();
		end : TXO
		else begin : TXB
			$display("Break Transmission(Written Character will be ignored) ....\n");
			run_sim_txbrk_check();
		end : TXB
	end

    //run_sim_transmit_m1090();
    //run_sim_transmit_mod();  //for cts check

endtask : run_sim_transmit
