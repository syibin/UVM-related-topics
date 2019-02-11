if(intf[0]) begin

  $display("\033[1;31mIllegal interrupt set\033[0m");
  print_test_result("\033[1;31mFAILED\033[0m");
  $finish(2);

end

if(intf[1] & !intf[2] & (|ins_errors)) begin

  //read data from RXBUF
  if(mode[9:8] == 2'b00 | mode[9:8] == 2'b01)

  reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
              REG_RD,
              32'h0,
              4'h0,
              read_data,
              error
            );

  else if(mode[9:8] == 2'b10) begin

    repeat(3)
    reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

  end

  else if(mode[9:8] == 2'b11) begin

    repeat(4)
    reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                REG_RD,
                32'h0,
                4'h0,
                read_data,
                error
              );

  end

end

//clean interrupt flags

reg_access( `UART_BASE_ADDRESS + `UART_INTF_REGISTER,
            REG_WR,
            {29'b0, 3'b111},
            4'h1,
            read_data,
            error
          );

$display("Interrupt is cleared");