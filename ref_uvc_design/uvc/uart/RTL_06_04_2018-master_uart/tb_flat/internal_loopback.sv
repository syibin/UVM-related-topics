//*****************************************************************************
// This test checks data transmission in loopback mode with different
// PDSEL, STSEL, BRGH, FCE and BRG values
//
// The sequence of steps is:
//
// 1) Wait for the end of reset, then wait 10 clocks
// 2) Check if Tx Buffer is not full
// 3) Write one character into Tx Buffer
// 4) Wait for a character in Rx Buffer (STATUS.RXDA asserts to 1'b1)
// 5) Read the character from Rx Buffer and compare it with previously sent one
//*****************************************************************************

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


//iterate `CHARACTER_NUM times write_character-read_character-compare_them sequence
repeat (`CHARACTER_NUM) begin : send_receive

  //check if the TXBUF is not full and write new character for transmission
  do begin : check_txbuf
  reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
              REG_RD,
              32'h0,
              4'h0,
              read_data,
              error
            );
  end : check_txbuf
  while(read_data[5]);

  character = $urandom_range(8'h7E, 8'h21);

  reg_access( `UART_BASE_ADDRESS + `UART_TXBUF_REGISTER,
              REG_WR,
              {24'h0, character},
              4'h1,
              read_data,
              error
            );

  $display("Wrote character \"%s\" into TXBUF @%t", character, $time);


  //wait for a character beeing received in RXBUF
  do begin : wait_for_rxda

    reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

  end : wait_for_rxda
  while(!read_data[0]);

  //read received character
  reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
              REG_RD,
              32'h0,
              4'h0,
              read_data,
              error
            );

  $display("Read character  \"%s\" from RXBUF @%t", read_data[7:0], $time);


  //compare sent and received characters
  if(read_data[7:0] != character) begin : data_mismatch
    $display("There is a mismatch between sent and received character, sent %s, received %s", character, read_data[7:0]);
    print_test_result("FAILED");
    $finish(2);
  end : data_mismatch

  $display("Written and read characters matched \n");

end : send_receive


print_test_result("PASSED");
$finish(2);



