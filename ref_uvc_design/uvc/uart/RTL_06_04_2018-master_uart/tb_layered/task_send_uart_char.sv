//----- Send character to UART controller -----//
task automatic driver::send_uart_char( input bit        insert_perr,
                                       input bit        insert_ferr,
                                       input bit [31:0] mode,
                                       input bit [ 7:0] character
                                      );

  //bit  [7:0] character;
  bit [19:0] baud_cycle;
  bit        parity;

  //character  = trans.pwdata;
  //baud_cycle = (2 ** mode[31:16]) * (mode[3]? 4 : 16);
  baud_cycle = (mode[31:16]+1'b1) * (mode[3]? 4 : 16);
  parity     = mode[0]? (^character) : !(^character);
  //$display("Here");
  wait(!uif.rts);

  //Set rxd line before sending start bit
  //This switching is required for UART protocol
  repeat(baud_cycle) @(posedge uif.clk);
  uif.rxd <= 1'b1;

  //send start bit
  //uif.cts <= trans.cts;
  repeat(baud_cycle) @(posedge uif.clk);
  uif.rxd <= 1'b0;
  //uif.rxd <= mode[11] ? 1'b1 : 1'b0;    //////////////////////

  //send data bits

  for(int i = 0; i < 8; i++) begin : send_char

    repeat(baud_cycle) @(posedge uif.clk);
    //$display(uif.rxd);
    uif.rxd <= character[i];
    //uif.rxd <= mode[11] ? !(character[i]) : character[i];    //////////////////////

  end : send_char

  //send parity bit

  if(^mode[1:0]) begin : send_par

    repeat(baud_cycle) @(posedge uif.clk);
    uif.rxd <= insert_perr? !parity : parity;
    //uif.rxd <= mode[11] ? (insert_perr? parity : !parity) : (insert_perr? !parity : parity);    //////////////////////

  end : send_par

  //send stop bit/bits
  
  fork

    for(int j = 0; j < (1 << mode[2]); j++) begin : send_stop

      repeat(baud_cycle) @(posedge uif.clk);
      uif.rxd <= !insert_ferr;
      //uif.rxd <= mode[11] ? insert_ferr : !insert_ferr;    //////////////////////

    end : send_stop

    if(!insert_ferr)  wait(uif.rts);

  join

  $display("Testbench sent character \"%s\" ", character,     ({insert_perr, insert_ferr} == 2'b10)?  "with Parity Error"  :
                                                              ({insert_perr, insert_ferr} == 2'b01)?  "with Framing Error" :
                                                              ({insert_perr, insert_ferr} == 2'b11)?  "with Parity and Framing Errors" :
                                                                                                      "without errors"
          );
  $display("Time : %t", $realtime);

  rx_data_queue.push_back({insert_perr, insert_ferr,  character});
  //$finish;
  
endtask : send_uart_char
