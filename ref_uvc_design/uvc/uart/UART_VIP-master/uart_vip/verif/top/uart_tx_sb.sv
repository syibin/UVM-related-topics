
`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)

class u0_tx_scoreboard extends uvm_scoreboard;

  uvm_analysis_imp_tx #(u0_xtn, u0_tx_scoreboard) tx_uart;
  uvm_analysis_imp_rx #(u0_xtn, u0_tx_scoreboard) rx_uart;

  u0_xtn       u0_xtn_h;

  virtual u0if u0_if;

  real t_pos;
  real clk_period; 
  real fosc ; 
  real baud_rate;

  bit  [11:0] brr_reg; 
  bit  [1:0]  parity; 
  bit  [1:0]  stop_bit;
  bit  [2:0]  frame_size;
  bit  [0:0]  DRE ;
  bit  [0:0]  parity_error;  
  bit  [2:0]  UCSZ;
  bit  [3:0]  ucsz_length;

  int         sync_cnt, txbit_pos;
  bit   [8:0] rcvd_data, exp_data;
  
  // Store Register Data 
  static bit [7:0] BRR_L_ADDR, BRR_L; 
  static bit [7:0] BRR_H_ADDR, BRR_H; 
  static bit [7:0] CSR_A_ADDR, CSR_A, 
                   CSR_B_ADDR, CSR_B,
                   CSR_C_ADDR, CSR_C,
                   UDR0_ADDR,  UDR0;
  bit    [8:0]     exp_data_q[$]; 

  // Baud Rate Cal
  bit  [11:0] brr_load; 
  bit  [03:0] brr_div=4'hF; 
  bit  [00:0] brr_event ;   
  bit         div2, div8, div16;

  // Flag 
  bit enable_h;  // For baud calculation
  bit enable_l;  
  bit enable;    

  typedef  enum  { tx_idle, tx_sync, tx_data, tx_parity, tx_stop0, tx_stop1, tx_stop2 } tx_states;
  tx_states      uart_state; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    tx_uart = new("tx_uart", this);
    rx_uart = new("rx_uart", this);
    uart_state = tx_idle;
  endfunction

  `uvm_component_utils(u0_tx_scoreboard)

  logic [31:0] ref_data [int];
  int txn_in,
      txn_out ,
      txn_dropped, 
      txn_compared,
      txn_passed ,
      txn_failed ,
      parity_failed; 

  function int halfbit();
    brr_reg = {BRR_H, BRR_L};
    return (brr_reg+1)*4*((CSR_A[1])?1:2);
  endfunction

  function int fullbit();
    brr_reg = {BRR_H, BRR_L};
    return (brr_reg+1)*8*((CSR_A[1])?1:2);
  endfunction 

  function bit [3:0] char_size();
    UCSZ = {CSR_B[2],CSR_C[2:1]};
    case(UCSZ)
      3'b000 : ucsz_length = 'h5;
      3'b001 : ucsz_length = 'h6;
      3'b010 : ucsz_length = 'h7;
      3'b011 : ucsz_length = 'h8;
      3'b100 : ucsz_length = 'hA;   // Bad size 
      3'b101 : ucsz_length = 'hA;   // Bad size 
      3'b110 : ucsz_length = 'hA;   // Bad size. Error Msg for this size 
      3'b111 : ucsz_length = 'h9;
    endcase 
    return ucsz_length;
  endfunction 

  virtual function void drv_write(u0_xtn tx);
    if (tx.write)
      begin 
        ref_data[tx.addr] = tx.din;
        // Calculating baud rate
        if (tx.addr == 8'hc5) begin  // BRR0H. 
          BRR_H = tx.din[3:0];
          enable_h=1;
          BRR_H_ADDR = 8'hc5;
        end 
        if (tx.addr == 8'hc4) begin  // BRR0L. Baud rate set
          BRR_L = tx.din;
          enable_l = 1;
          BRR_L_ADDR = 8'hc5;
        end 
        enable = enable_h & enable_l;  // order independent for Baud Rate register configurations
        // Storing Register Values 
        if (tx.addr == 8'hc0) begin   // CSR0A. Data Empty register, Parity Error, Transmission speed.
          CSR_A = tx.din   ;
          CSR_A_ADDR = 8'hc0;
        end 
        if (tx.addr == 8'hc1) begin   // CSR0B. Txen, Rxen, etc.
          CSR_B = tx.din   ;
          CSR_B_ADDR = 8'hc1;
        end 
        if (tx.addr == 8'hc2) begin   // CSR0C. Async UART, Parity, Stop bits, Frame size.
          CSR_C = tx.din   ;
          CSR_C_ADDR = 8'hc2;
          if(CSR_C[7:6] == 0) begin
            `uvm_info(" CFG_SETTINGS ", "Async USART Mode set" , UVM_LOW)
          end 
          else begin 
            `uvm_error(" BAD_CFG_SETTINGS","Invalid USART Mode set")
          end 
          if(CSR_C[5:4] == 0) begin
            `uvm_info(" PAR DISABLED ", "USART PArity Disabled", UVM_LOW)
          end 
          else if (CSR_C[5:4] == 1) begin 
            `uvm_info(" RESERVED PARITY"," Configuring Reserved bits ", UVM_LOW)
          end 
          else if (CSR_C[5:4] == 2) begin 
            `uvm_info(" EVEN PARITY","  Even Parity Configured   ", UVM_LOW)
          end 
          else begin 
            `uvm_info(" ODD PARITY"," Odd Parity Configured ", UVM_LOW)
          end 
          if(CSR_C[3] == 0) begin
            `uvm_info(" STOP BIT 1-bit","Stop bit is set to 1 bits ", UVM_LOW)
          end 
          else if (CSR_C[3] == 1) begin 
            `uvm_info(" STOP BIT 2-bits","Stop bit is set to 2 bits ", UVM_LOW)
          end 
          if({ CSR_B[2], CSR_C[2:1]} == 0) begin
            `uvm_info(" CHAR SIZE 5  ", "Char size set to 5", UVM_LOW)
          end 
          else if ({ CSR_B[2], CSR_C[2:1]} == 1) begin 
            `uvm_info(" CHAR SIZE 6 "," Char size set to 6 ", UVM_LOW)
          end 
          else if ({ CSR_B[2], CSR_C[2:1]} == 2) begin 
            `uvm_info("CHAR SIZE 7  "," Char size set to 7 ", UVM_LOW)
          end 
          else if ({ CSR_B[2], CSR_C[2:1]} == 3) begin 
            `uvm_info("CHAR SIZE 8 "," Char size set to 8 ", UVM_LOW)
          end 
          else if ({ CSR_B[2], CSR_C[2:1]} == 7) begin 
            `uvm_info("CHAR SIZE 9  "," Char size set to 9 ", UVM_LOW)
          end 
          else if ({ CSR_B[2], CSR_C[2:1]} == 3) begin 
            `uvm_info(" RSVD CHAR SIZE "," Reserved Char size configured ", UVM_LOW)
          end 
        end 
        if (tx.addr == 8'hc6) begin   // UDR0. Data register 
          if(tx.TXEn) 
          UDR0  = tx.din   ;
          exp_data_q.push_back(UDR0);
          UDR0_ADDR = 8'hc6;
          txn_in++;
        end 
        // `uvm_info(get_type_name(), $sformatf(" SCBD write monitor transactions \n %s", tx.sprint()), UVM_LOW)
      end 
  endfunction 

  // Tx monitor write_implementation method. Expected Data. 
  virtual function void write_tx (u0_xtn tx);
    drv_write(tx);
  endfunction 

  // DUT monitor write_implementation method. Received Data. 
  function void rcvd_write(u0_xtn rx);
    this.u0_xtn_h = rx; 
    case(uart_state) 
      tx_idle    :  if(!u0_xtn_h.txdata  && CSR_B[3]) begin
                      uart_state = tx_sync;
                      sync_cnt = 0;
                    end 
                    else if(!u0_xtn_h.txdata  && !CSR_B[3]) begin
                      `uvm_error("TXEn Error"," TXEn Transmit Error, TXEn is not asserted")
                      uart_state = tx_idle;
                    end 
      tx_sync    :  if (u0_xtn_h.txdata) begin
                      `uvm_error("Start Bit Error","Start Bit asserted, but did not stay low")
                      uart_state = tx_idle;
                    end 
                    else begin
                      sync_cnt += 1;
                      if (sync_cnt == halfbit()) begin
                        sync_cnt = 0;
                        uart_state = tx_data;
                        txbit_pos  = 0;
                        rcvd_data  = 0;
                        parity     = 0;
                      end 
                    end 
      tx_data    :  begin   // {
                      sync_cnt += 1;
                      if(sync_cnt >= fullbit()) begin   // {
                        rcvd_data[txbit_pos] = u0_xtn_h.txdata; 
                        txbit_pos += 1;
                        sync_cnt = 0;
                        parity ^= u0_xtn_h.txdata;
                        if(txbit_pos == char_size) begin   // {
                          txn_out++;
                          txn_dropped = txn_in - txn_out;
                          if(UDR0_ADDR == 'hc6) begin   // {
                            exp_data = exp_data_q.pop_front(); //UDR0 ; // u0_xtn_h.din;
                            // case(char_size)
                            //   5: exp_data &= 9'h1f;
                            //   6: exp_data &= 9'h3f;
                            //   7: exp_data &= 9'h7f;
                            //   8: exp_data &= 9'hff;
                            //   9: exp_data &= 9'h1ff;
                            // endcase
                          end //}
                            // Use a queue for rcvd_data. Use it like a fifo. 
                            if(rcvd_data != exp_data) begin   // {
                              `uvm_error("DATA Mismatch",$sformatf("expected %h received %h",exp_data,rcvd_data));
                              txn_failed++;
                            end //}
                            else begin   // {
                              `uvm_info("DATA Matched",$sformatf("expected %h received %h",exp_data,rcvd_data), UVM_LOW);
                              txn_passed++;
                            end //}
                            if (CSR_C[5:4])
                              uart_state = tx_parity;
                            else 
                              uart_state = tx_stop0;
                          txn_compared++;
                        end//}
                        else 
                          uart_state = tx_data ;
                      end //}
                    end //}
      tx_parity  : begin 
                     sync_cnt += 1;
                     if(sync_cnt >= fullbit()) begin
                       sync_cnt = 1;
                       if((parity^CSR_C[4]) != u0_xtn_h.txdata) begin
                         `uvm_error("Parity Error",$sformatf("expected parity %h received parity %h",parity,u0_xtn_h.txdata));
                         parity_failed++;
                       end 
                       uart_state = tx_stop0;
                     end 
                   end 
      tx_stop0   : begin
                     sync_cnt += 1;
                     if(sync_cnt >= halfbit()) begin
                       sync_cnt = 2;
                       uart_state = tx_stop1;
                     end 
                   end 
      tx_stop1   : begin
                     sync_cnt += 1;
                     if(u0_xtn_h.txdata == 1'b0) begin
                       `uvm_error("Stop Bit Error"," Zero seen during stop time")
                     end
                     if(sync_cnt >= fullbit()) begin
                       sync_cnt=1;
                       if(CSR_C[3]) begin
                         uart_state = tx_stop2;
                       end else begin
                         uart_state = tx_idle;
                       end
                     end
                   end
      tx_stop2   : begin 
                     sync_cnt += 1;
                     if(u0_xtn_h.txdata == 1'b0) begin
                       `uvm_error("Stop Bit Error"," Zero seen during stop time")
                     end
                     if(sync_cnt >= fullbit()) begin
                       sync_cnt=1;
                       uart_state = tx_idle;   // Transmit complete
                     end
                   end 
    endcase 
  endfunction 

  virtual function void write_rx (u0_xtn rx);
    rcvd_write(rx);
  endfunction 

  task baud_rate_cal();
  begin
    // tx = u0_xtn::type_id::create("tx");
    @(posedge clk) t_pos = $time;
    @(posedge clk) clk_period = ($time - t_pos);
    fosc = (10**9/clk_period);                    // Assuming timescale is in nano-sec
    wait (enable)
    brr_reg = {BRR_H, BRR_L};
    brr_load = brr_reg ;
    baud_rate = fosc/(16*(brr_reg+1));
    // It is incomplete
    div_by_x();
  end 
  endtask 

  task div_by_x();
    wait(enable);
    forever begin 
      @(posedge clk);
      brr_load--;
      if (brr_load==0) begin 
      @(posedge clk);
        brr_load = brr_reg;
      end 
      if (brr_load == brr_reg) begin
        brr_event = 1;
        brr_div ++;
      end 
      else 
        brr_event = 0;
      div2  = brr_event && (brr_div[0]==1);
      div8  = brr_event && (brr_div[2:0]==7);
      div16 = brr_event && (brr_div==15);
      // if (brr_event)
      // $display(" brr_event %d,  brr_div  %d div2   %d,   div8  %d,  div16  %d  %t ",  brr_event, brr_div, div2, div8, div16, $time);
    end 
  endtask 

  function void report_phase(uvm_phase phase);
    `uvm_info("    $$$$$$     ", "############################################################### \n", UVM_LOW)
    `uvm_info("    TXN_IN     ", $sformatf("Num. of Transactions input to the DUT     %0d",txn_in), UVM_LOW)
    `uvm_info("    TXN_OUT    ", $sformatf("Num. of Transactions output from the DUT  %0d",txn_out), UVM_LOW)
    `uvm_info("    TXN_STATUS ", $sformatf("                   \n \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t Txn compared %0d \n \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t Txn Passed   %0d \n \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t Txn Failed    %0d \n  \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t Txn Dropped   %0d \n",txn_compared, txn_passed, txn_failed, txn_dropped), UVM_LOW)
    `uvm_info("    $$$$$$     ", "############################################################### \n", UVM_LOW)
  endfunction 


endclass 
