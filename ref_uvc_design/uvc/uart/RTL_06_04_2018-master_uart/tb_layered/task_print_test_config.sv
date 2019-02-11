task driver::print_test_config( input [31:0] reg_base_addr,
                                input [31:0] mode,
                                input  [2:0] interrupts_config,
                                input [31:0] LOOPBACK_CHARACTER_NUM
                              );


  $display("\033[1;35m*******************************************************************\033[0m"); 
  $display("*   Registers' base address                 0x%h", reg_base_addr);
  $display("*   Baud Rate field                         0x%h", mode[31:16]);
  $display("*   Transmit Interrupt Mode Selection       2'b%b", mode[13:12]);
  $display("*   Receive Polarity Inversion bit          1'b%b", mode[11]);
  $display("*   Receive Interrupt Mode Selection        2'b%b", mode[9:8]);
  $display("*   Loopback Mode Select                    1'b%b", mode[5]);
  $display("*   Flow control enable bit                 1'b%b", mode[4]);
  $display("*   High Baud Rate Select bit               1'b%b", mode[3]);
  $display("*   Stop Selection bit                      1'b%b", mode[2]);
  $display("*   Parity and Data Selection bits          2'b%b", mode[1:0]);
  $display("*   Interrupts used in test        %s", (interrupts_config == 3'b000)? "NONE"           :
                                                    (interrupts_config == 3'b001)? "TXI"            :
                                                    (interrupts_config == 3'b010)? "RXI"            :
                                                    (interrupts_config == 3'b011)? "RXI, TXI"       :
                                                    (interrupts_config == 3'b100)? "ERI"            :
                                                    (interrupts_config == 3'b101)? "ERI, TXI"       :
                                                    (interrupts_config == 3'b110)? "ERI, RXI"       :
                                                    (interrupts_config == 3'b111)? "ERI, RXI, TXI"  :
                                                    "NONE"
          );
  $display("*   Characters to be sent/receeived  %d", LOOPBACK_CHARACTER_NUM);
  $display("\033[1;35m*******************************************************************\033[0m");

endtask : print_test_config