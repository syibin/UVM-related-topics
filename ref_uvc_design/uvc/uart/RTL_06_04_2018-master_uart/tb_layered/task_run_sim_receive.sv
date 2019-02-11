task driver::run_sim_receive();

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
                  4'hF,
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

    
    //repeat LOOPBACK_CHARACTER_NUM symbols receiption

    repeat (LOOPBACK_CHARACTER_NUM) begin : uart_rx


      if(mode[9:8] == 2'b00 | mode[9:8] == 2'b01) begin

		    character = trans.pwdata;        
		    send_uart_char( ins_errors[1], ins_errors[0], mode, character );  //Edited Today
        symbol = rx_data_queue.pop_front();
        
        if(!ins_errors[0])  begin
          wait(uif.interrupt[1]);
          $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");
        end

        `include "read_status_intf.sv"
        if(ins_errors == 2'b10 || ins_errors == 2'b11) begin
          `include "parity_error.sv"
        end
        else if(ins_errors == 2'b01 || ins_errors == 2'b11) begin
          `include "framing_error.sv"
        end
        if(ins_errors == 2'b00) begin
          `include "data_matching.sv"
        end
        `include "clear_rxbuf_intf.sv"

      end

      else if(mode[9:8] == 2'b10) begin
        
    		int i = 1;        
    		character = trans.pwdata;
	      while((!(|ins_errors) & !uif.interrupt[1]) | (|ins_errors & i <= 3)) begin

		        send_uart_char( ins_errors[1], ins_errors[0], mode, character );
            `include "read_status_intf.sv"
            if(uif.interrupt[1])  $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");

            if(|ins_errors) begin

              symbol = rx_data_queue.pop_front();

              if(ins_errors == 2 || ins_errors == 3) begin
                //$display("STATUS : ", read_data[2], "\tINTF : ", intf[2]);
                `include "parity_error.sv"
              end

              if(ins_errors == 1 || ins_errors == 3)  begin
                `include "framing_error.sv"
              end

              /*if(|(ins_errors) & (i == 3))  begin

                wait(uif.interrupt[1]);
                $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");

              end*/ ////Check after designer's response
              
              `include "clear_rxbuf_intf.sv"  //change here

            end

		        character = $urandom_range(65,90);
      			if(i<3 & uif.interrupt[1] &(!(|ins_errors))) $display("\033[1;31mError !! Early Interrupt ....\033[0m");
            else if(i>3 &(!(|ins_errors)) & uif.interrupt[1]) $display("\033[1;31mError !! Late Interrupt ....\033[0m");  				
    			  i++;

	      end

        $display("\033[1;31mWhile FINISHED\033[0m");

        if(!(|ins_errors)) begin

          symbol_n   = rx_data_queue.pop_front();  
          symbol_nn  = rx_data_queue.pop_front();  
          symbol_nnn = rx_data_queue.pop_front();  
          symbol     = {symbol_n[7:0], symbol_nn[7:0], symbol_nnn[7:0]};
          wait(uif.interrupt[1]);
          $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");
          `include "data_matching.sv"
          `include "clear_rxbuf_intf.sv"

        end

      end

      else if(mode[9:8] == 2'b11) begin
        
    		int i = 1;        
    		character = trans.pwdata;
	      while((!(|ins_errors) & !uif.interrupt[1]) | (|ins_errors & i <= 4)) begin

		        send_uart_char( ins_errors[1], ins_errors[0], mode, character );
            `include "read_status_intf.sv"

            if(|ins_errors) begin

              symbol = rx_data_queue.pop_front();

              if(ins_errors == 2 || ins_errors == 3) begin
                //$display("INTF : ",intf[2]);
                `include "parity_error.sv"
              end

              if(ins_errors == 1 || ins_errors == 3)  begin
                `include "framing_error.sv"
              end

              /*if(|(ins_errors) & (i == 4))  begin

                wait(uif.interrupt[1]);
                $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");

              end*/ ////Check after designer's response

              `include "clear_rxbuf_intf.sv"

            end

		        character = $urandom_range(65, 90);
    			  if(i<4 & uif.interrupt[1] &(!(|ins_errors))) $display("\033[1;31mError !! Early Interrupt ....\033[0m");
            else if(i>4 & (!(|ins_errors)) & uif.interrupt[1]) $display("\033[1;31mError !! Late Interrupt ....\033[0m");         
            i++;

	      end

        $display("\033[1;31mWhile FINISHED\033[0m");
        
        if(!(|ins_errors)) begin

          symbol_n    = rx_data_queue.pop_front();  
          symbol_nn   = rx_data_queue.pop_front();  
          symbol_nnn  = rx_data_queue.pop_front();  
          symbol_nnnn = rx_data_queue.pop_front();  
          symbol      = {symbol_n[7:0], symbol_nn[7:0], symbol_nnn[7:0], symbol_nnnn[7:0]};
          wait(uif.interrupt[1]);
          $display("\033[1;31mInterrupt Has Been Asserted.\033[0m");
          `include "data_matching.sv"
          `include "clear_rxbuf_intf.sv"

        end

      end

    if(loop_count != 1) begin
      gen2drv.get(trans);
    end
    
    loop_count--;

    end : uart_rx

    /*if(mode[9:8] != 2'b00 && mode[9:8] != 2'b01 && ins_errors == 2'b00)*/ print_test_result("PASSED");

endtask : run_sim_receive