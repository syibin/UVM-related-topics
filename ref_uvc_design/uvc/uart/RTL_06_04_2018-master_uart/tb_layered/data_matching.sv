  if(intf[1] & (!(|ins_errors))) begin : handle_rx_int

    //read data from RXBUF 

    if(mode[9:8] == 2'b00 | mode[9:8] == 2'b01) begin
      
      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data,
                  error
                );

      trn_drv.pwdata     = read_data[7:0];
      trn_scb            = trn_drv.copy();
      trn_scb.mode       = mode;
      trn_scb.special    = special;
      trn_scb.block_sel  = block_sel;
      trn_scb.ins_errors = ins_errors;
      drv2scb.put(trn_scb);

      if(symbol[7:0] != read_data[7:0]) begin

        $display("\033[1;31mReceived character doesn't match the character sent by testbench! Received \"%b\", sent \"%b\"\033[0m", read_data[7:0], symbol[7:0]);
        print_test_result("FAILED");
        $finish(2);

      end

      else $display("\033[1;32mReceived character matches the character sent by testbench. Received \"%s\", sent \"%s\"\033[0m", read_data[7:0], symbol[7:0]);

    end

    else if(mode[9:8] == 2'b10) begin

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_n,
                  error
                );

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_nn,
                  error
                );

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_nnn,
                  error
                );

      read_data = {read_data_n[7:0], read_data_nn[7:0], read_data_nnn[7:0]};

      if(symbol[23:0] != read_data[23:0]) begin

        $display("\033[1;31mReceived character doesn't match the character sent by testbench! Received \"%s\", sent \"%s\"\033[0m", read_data[23:0], symbol[23:0]);
        print_test_result("FAILED");
        $finish(2);

      end
      
      else $display("\033[1;32mReceived character matches the character sent by testbench. Received \"%s\", sent \"%s\"\033[0m", read_data[23:0], symbol[23:0]);

    end

    else if(mode[9:8] == 2'b11) begin

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_n,
                  error
                );

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_nn,
                  error
                );

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_nnn,
                  error
                );

      reg_access( `UART_BASE_ADDRESS + `UART_RXBUF_REGISTER,
                  REG_RD,
                  32'h0,
                  4'h0,
                  read_data_nnnn,
                  error
                );

      read_data = {read_data_n[7:0], read_data_nn[7:0], read_data_nnn[7:0], read_data_nnnn[7:0]};

      if(symbol[31:0] != read_data[31:0]) begin

        $display("\033[1;31mReceived character doesn't match the character sent by testbench! Received \"%s\", sent \"%s\"\033[0m", read_data[31:0], symbol[31:0]);
        print_test_result("FAILED");
        $finish(2);

      end
      
      else $display("\033[1;32mReceived character matches the character sent by testbench. Received \"%s\", sent \"%s\"\033[0m", read_data[31:0], symbol[31:0]);

    end
    
  end : handle_rx_int