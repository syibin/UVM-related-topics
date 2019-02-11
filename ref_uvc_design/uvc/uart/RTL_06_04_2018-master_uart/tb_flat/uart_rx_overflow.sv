print_test_config( `UART_STATUS_REGISTER,
                   mode,
                   interrupts_config,
                   `CHARACTER_NUM
                 );


wait(rst_n);
repeat(10) @(posedge clk);


//program MODE register
reg_access( `UART_BASE_ADDRESS + `UART_MODE_REGISTER,
            REG_WR,
            mode,
            4'h1,
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


//repeat CHARACTER_NUM symbols receiption
repeat (`CHARACTER_NUM) begin : uart_rx

  send_error = $urandom_range(8,0);
  $display("send_error = %0h", send_error);


  if(|send_error) send_uart_char( ins_errors[1],
                                  ins_errors[0],
                                  mode
                                );
   else           send_uart_char( 1'b0,
                                  1'b0,
                                  mode
                                );



end : uart_rx

wait(interrupt);


//read Status register and check if OERR flag asserted to 1
reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
            REG_RD,
            32'h0,
            4'h0,
            read_data,
            error
          );

if(read_data[1]) begin
  $display("OERR flag was correctly asserted to 1 at %t", $time);
  print_test_result("PASSED");
  $finish(2);
end
else begin
  $display("ERROR! OERR flag was NOT asserted to 1 after reception of %d consecutive bytes!", `CHARACTER_NUM);
  print_test_result("FAILED");
  $finish(2);
end


