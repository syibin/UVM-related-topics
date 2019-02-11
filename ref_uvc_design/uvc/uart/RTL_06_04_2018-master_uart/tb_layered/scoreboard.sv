class scoreboard;

	transaction            trn_gen, trn_drv;
	mailbox                gen2scb, drv2scb;
	int 				   loop_count, LOOPBACK_CHARACTER_NUM;

	function  new(mailbox gen2scb, drv2scb);

		this.gen2scb = gen2scb;
		this.drv2scb = drv2scb;

	endfunction

	extern task scb_loopback();
	extern task scb_transmit();
	extern task scb_receive();
	extern task scb_control();
	extern task print_test_result( input string result );

endclass : scoreboard

task scoreboard::scb_loopback();

	repeat(LOOPBACK_CHARACTER_NUM) begin

		if(trn_drv.pwdata[7:0] == trn_gen.pwdata[7:0]) $display("\033[1;32mMatched!!!!\tTXBF Data : %s\tRXBF Data : %s\033[0m", trn_gen.pwdata[7:0], trn_drv.pwdata[7:0]);
		else begin
			$display("\033[1;31mMismatched!!!!\tTXBF Data : %s\tTXD Line Data : %s\033[0m", trn_gen.pwdata[7:0], trn_drv.pwdata[7:0]);
			print_test_result("FAILED");
			$finish;
		end
		if(loop_count != 1) begin

		    gen2scb.get(trn_gen);
			drv2scb.get(trn_drv);

		end

	    loop_count--;

	end

endtask : scb_loopback

task scoreboard::scb_transmit();


	repeat(LOOPBACK_CHARACTER_NUM) begin

		if(!trn_drv.tx_brk_ctrl) begin : Data_Check

			if(trn_drv.mode[1]^trn_drv.mode[0]) begin

				trn_gen.pwdata[10:9] = {trn_drv.mode[2], 1'b1};
				if(trn_drv.mode[1]) trn_gen.pwdata[8] = !(^(trn_gen.pwdata[7:0]));
				else if(trn_drv.mode[0]) trn_gen.pwdata[8] = ^(trn_gen.pwdata[7:0]);

			end
			else if(!(trn_drv.mode[1]^trn_drv.mode[0])) trn_gen.pwdata[10:8] = { 1'b0, trn_drv.mode[2], 1'b1 };

			if({trn_gen.pwdata[10:0], 1'b0} == trn_drv.pwdata[11:0]) $display("\033[1;32mMatched!!!!\tTXBF Data : %s\tTXD Line Data : %s\033[0m", trn_gen.pwdata[7:0], trn_drv.pwdata[8:1]);
			else begin
				$display("\033[1;31mMismatched!!!!\tTXBF Data : %s\tTXD Line Data : %s\033[0m", {trn_gen.pwdata[10:0], 1'b0}, trn_drv.pwdata[11:0]);
				print_test_result("FAILED");
				$finish;
			end

		end : Data_Check

		else begin : Break_Check

			if(trn_drv.pwdata[13:0] == {1'b1, 12'b0, 1'b0}) $display("\033[1;32mMatched!!!!\tTXBF Data : %14b\tTXD Line Data : %14b\033[0m", {1'b1, 12'b0, 1'b0}, trn_drv.pwdata[13:0]);
			else begin
				$display("\033[1;31mMismatched!!!!\tTXBF Data : %14b\tTXD Line Data : %14b\033[0m", {1'b1, 12'b0, 1'b0}, trn_drv.pwdata[13:0]);
				print_test_result("FAILED");
				$finish;
			end

		end : Break_Check

		if(loop_count != 1) begin

		    gen2scb.get(trn_gen);
			drv2scb.get(trn_drv);

		end

	    loop_count--;

	end

endtask : scb_transmit

task scoreboard::scb_receive();

	repeat(LOOPBACK_CHARACTER_NUM) begin

		if(trn_drv.pwdata[7:0] == trn_gen.pwdata[7:0]) $display("\033[1;32mMatched!!!!\tTestbench Data : %s\tRXBF Data : %s\033[0m", trn_gen.pwdata[7:0], trn_drv.pwdata[7:0]);
		else begin
			$display("\033[1;31mMismatched!!!!\tTestbench Data : %s\tRXBF Data : %s\033[0m", trn_gen.pwdata[7:0], trn_drv.pwdata[7:0]);
			print_test_result("FAILED");
			$finish;
		end
		if(loop_count != 1) begin

		    gen2scb.get(trn_gen);
			drv2scb.get(trn_drv);

		end

	    loop_count--;

	end

endtask : scb_receive

task scoreboard::scb_control();

	gen2scb.get(trn_gen);
	drv2scb.get(trn_drv);
	if(trn_drv.block_sel == 2'b00 && (trn_drv.special == 2'b00 || trn_drv.special == 2'b11)) begin

        if(trn_drv.tx_brk_ctrl)	$display("\nEntering Scoreboard For Transmitter (Break Character Checking) ....\n");
        else if(!trn_drv.tx_brk_ctrl)	$display("\nEntering Scoreboard For Transmitter (Data Checking) ....\n");
        scb_transmit();
        print_test_result("PASSED");

    end
    else if(trn_drv.block_sel == 2'b10 && trn_drv.special == 2'b00) begin

        $display("Entering Scoreboard For Loopback Mode ....\n\n");
        scb_loopback();
        print_test_result("PASSED");

    end
    else if(trn_drv.block_sel == 2'b01 && trn_drv.special == 2'b00) begin

        if((trn_drv.mode [9:8] == 2'b00 | trn_drv.mode [9:8] == 2'b01) && trn_drv.ins_errors == 2'b00) begin
        	$display("\nEntering Scoreboard For Receiver ....\n");
        	scb_receive();
        	print_test_result("PASSED");
        end

    end
	//scb_transmit();

endtask : scb_control

task scoreboard::print_test_result( input string result );

  $display("\n");
  $display("********************************************************");
  if (result == "PASSED")	$display("\033[1;32m*                     TEST %s                      *\033[0m", result);
  else $display("\033[1;31m*                     TEST %s                      *\033[0m", result);
  $display("********************************************************");

endtask : print_test_result
