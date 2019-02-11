reg_access( `UART_BASE_ADDRESS + `UART_INTF_REGISTER,
            REG_RD,
            32'h0,
            4'h0,
            read_data,
            error
          );

intf = read_data;

reg_access( `UART_BASE_ADDRESS + `UART_STATUS_REGISTER,
            REG_RD,
            32'h0,
            4'h0,
            read_data,
            error
          );

//$display("INTF[2] : ", intf[2], "\tFERR : ", read_data[2], "\tPERR : ", read_data[3], "\t@Time : ", $realtime);