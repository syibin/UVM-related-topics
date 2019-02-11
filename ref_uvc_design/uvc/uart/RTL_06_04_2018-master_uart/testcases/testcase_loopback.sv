class transaction_mode extends transaction;
  
  constraint mod_cnst { 
                        mode              inside {

                                                            /***************RX MODES***************/
                                                  /*[32'h0000_0080:32'h0000_009F], [32'h0000_0180:32'h0000_019F], 
                                                  [32'h0000_0280:32'h0000_029F], [32'h0000_0380:32'h0000_039F],

                                                  [32'h0000_0880:32'h0000_089F], [32'h0000_0980:32'h0000_099F],
                                                  [32'h0000_0A80:32'h0000_0A9F], [32'h0000_0B80:32'h0000_0B9F]*/


                                                            /***************TX MODES***************/    
                                                                //[32'h0000_1090:32'h0000_1090]


                                                          /* **************LOOPBACK MODES************** */
                                                  [32'h0000_00A0:32'h0000_00BF], [32'h0000_01A0:32'h0000_01BF],
                                                  [32'h0000_02A0:32'h0000_02BF], [32'h0000_03A0:32'h0000_03BF],

                                                  [32'h0000_10A0:32'h0000_10BF], [32'h0000_11A0:32'h0000_11BF],
                                                  [32'h0000_12A0:32'h0000_12BF], [32'h0000_13A0:32'h0000_13BF]

                                                 };

                        interrupts_config ==  3'b000;  //For RX/LOOPBACK MODE
                		    ins_errors        ==  2'b00;
                        block_sel         ==  2'b10;
                        special           ==  2'b00;
                      }
  
endclass : transaction_mode


program testcase_combined(uart_interface uif);

    int              num;
    environment      env;
    transaction_mode tr_mode;

    initial begin

        env = new(uif);

        repeat(2560) begin //////////////////////////////// 256

            tr_mode       = new();
            env.gen.trans = tr_mode; 
            num           = $urandom_range(5, 5); //////////////////////////////// 20, 50
            env.drv.LOOPBACK_CHARACTER_NUM = num;
            env.scb.LOOPBACK_CHARACTER_NUM = num;
            env.drv.loop_count             = num;
            env.scb.loop_count             = num;
            env.gen.repeat_count           = num;
            env.gen.signal_generate();
            env.drv.run_sim_control();
            env.scb.scb_control();

        end

    end

endprogram : testcase_combined
