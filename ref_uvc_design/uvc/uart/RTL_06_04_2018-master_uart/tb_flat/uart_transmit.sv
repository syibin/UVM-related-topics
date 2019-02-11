print_test_config( `UART_STATUS_REGISTER,
                   mode,
                   interrupts_config,
                   1
                 );

wait(rst_n);
repeat(10) @(posedge clk);

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


//program INTC Register (enable Transmit interrupt)
reg_access( `UART_BASE_ADDRESS + `UART_INTC_REGISTER,
            REG_WR,
            32'd1,
            4'h1,
            read_data,
            error
          );


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


fork

  begin : wait_int
    wait(interrupt);

    $display("Character was succesfully transmitted");
    $finish(2);
  end : wait_int

  begin : timeout_

    repeat(1000) @(posedge clk);
    $display("Transmit interrupt was not set during 1000 clocks after character write into Tx Buffer");
    $finish(2);

  end : timeout_

join




