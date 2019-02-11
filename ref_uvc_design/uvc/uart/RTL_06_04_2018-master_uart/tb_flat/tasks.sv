
bit [9:0] rx_data_queue [$];


typedef enum bit { REG_RD = 1'b0, REG_WR = 1'b1 } reg_access_t;


//----- Register access method via APB bus --------------------------------------------------------
task automatic reg_access( input        [31:0] address,      // register's address
                           input  reg_access_t access_type,  // 0 - read, 1 - write
                           input        [31:0] reg_wr_data,  // data to be written into register
                           input         [3:0] reg_be,       // byte enables for write data bytes (1 be per byte)
                           output       [31:0] reg_rd_data,  // data read from register
                           output              reg_err       // error returned
                         );

  bit [3:0] timeout_cnt;

  @(posedge clk);
  psel    <= 1'b1;
  paddr   <= address;
  pwrite  <= access_type;
  if(access_type == REG_WR) begin
    pwdata  <= reg_wr_data;
    pstrb   <= reg_be;
  end

  @(posedge clk);
  penable <= 1'b1;

  fork

    begin : wait_for_resp

      wait(pready);
      @(posedge clk);
      psel        <= 1'b0;
      penable     <= 1'b0;

      if((access_type == REG_RD) & pslverr) begin
          $display("!!! ERROR !!! Illegal register access occured @%0t", $realtime);
          reg_rd_data = 32'hDEAD_BEEF;
          reg_err     = 1'b1;
      end

      if((access_type == REG_RD) & !pslverr) begin
        reg_rd_data = prdata;
        reg_err     = 1'b0;
      end

      if((access_type == REG_WR) & pslverr)  reg_err = 1'b1;
      if((access_type == REG_WR) & !pslverr) reg_err = 1'b0;


    end : wait_for_resp


    while (!pready) begin : timeout

      @(posedge clk);
      timeout_cnt++;
      if(timeout_cnt == 4'hF) begin
        $display("Register access timeout reached at %0t!", $realtime);
        $finish(2);
      end

    end : timeout

  join_any

endtask



//----- Send character to UART controller ---------------------------------------------------------
task automatic send_uart_char( input bit        insert_perr,
                               input bit        insert_ferr,
                               input bit [31:0] mode
                             );

  bit  [7:0] character;
  bit [19:0] baud_cycle;
  bit        parity;

  character  = $urandom_range(8'h7E, 8'h21);
  baud_cycle = (2 ** mode[31:16]) * (mode[3]? 4 : 16);
  parity     = mode[0]? (^character) : !(^character);

  wait(!rts);

  //send start bit
  repeat(16) @(posedge clk);
  rxd <= 1'b0;

  //send data bits
  for(int i = 0; i < 8; i++) begin : send_char
    repeat(baud_cycle) @(posedge clk);
    rxd <= character[i];
  end : send_char

  //send parity bit
  if(^mode[1:0]) begin : send_par
    repeat(baud_cycle) @(posedge clk);
    rxd <= insert_perr? !parity : parity;
  end : send_par


  //since UART Receiver doesn't rely on 2 stop bits reception, send stop bits and wait for rts beeing set to one in parallel
  fork

    //send stop bit/bits
    for(int j = 0; j < (1 << mode[2]); j++) begin : send_stop
      repeat(baud_cycle) @(posedge clk);
      rxd <= !insert_ferr;
    end : send_stop

    if(!insert_ferr) wait(rts);

  join


  repeat(baud_cycle) @(posedge clk);
  rxd <= 1'b1;

  $display("Testbench sent character \"%s\" %s", character, ({insert_perr, insert_ferr} == 2'b10)? "with Parity Error"  :
                                                            ({insert_perr, insert_ferr} == 2'b01)? "with Framing Error" :
                                                            ({insert_perr, insert_ferr} == 2'b11)? "with Parity and Framing Errors" :
                                                                                                   "without errors"
          );
  rx_data_queue.push_back({insert_perr, insert_ferr, character});


endtask




//----- Prints test configuration -----------------------------------------------------------------
task print_test_config( input [31:0] reg_base_addr,
                        input [31:0] mode,
                        input  [2:0] interrupts_config,
                        input [31:0] character_num
                      );

  $display("*******************************************************************");
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
  $display("*   Characters to be sent/receeived  %d", character_num);
  $display("*******************************************************************");

endtask



//----- Prints results of the test ----------------------------------------------------------------
task print_test_result( input string result );

  $display("\n");
  $display("********************************************************");
  $display("*                     TEST %s                      *", result);
  $display("********************************************************");

  $finish(2);

endtask
