class transaction_mode extends transaction;
  
  constraint mod_cnst { 
                        mode[15:0]      inside {

                                                            /***************RX MODES***************/

                                                            [16'h0080:16'h009F], [16'h0180:16'h019F], 
                                                            [16'h0280:16'h029F], [16'h0380:16'h039F]/*,

                                                  [32'h0000_0080:32'h0000_009F], [32'h0000_0180:32'h0000_019F], 
                                                  [32'h0000_0280:32'h0000_029F], [32'h0000_0380:32'h0000_039F]/,

                                                  [32'h0000_0880:32'h0000_089F], [32'h0000_0980:32'h0000_099F],
                                                  [32'h0000_0A80:32'h0000_0A9F], [32'h0000_0B80:32'h0000_0B9F]*/


                                                            /***************TX MODES***************/    
                                                                //[32'h0000_1090:32'h0000_1090]


                                                          /* **************LOOPBACK MODES************** */
                                                  /*[32'h0000_00A0:32'h0000_00BF], [32'h0000_01A0:32'h0000_01BF],
                                                  [32'h0000_02A0:32'h0000_02BF], [32'h0000_03A0:32'h0000_03BF]

                                                  [32'h0000_08A0:32'h0000_08BF], [32'h0000_09A0:32'h0000_09BF],
                                                  [32'10000_0AA0:32'h0000_0ABF], [32'h0000_0BA0:32'h0000_0BBF]*/

                                                };

                        mode[31:16]       ==  16'h19;
                        mode[3]           ==  1'b0;
                        interrupts_config ==  3'b010;  //For RX/LOOPBACK MODE
                		    ins_errors        ==  2'b00;
                        block_sel         ==  2'b01;
                        special           ==  2'b00;
                      }
  
endclass : transaction_mode


program testcase_combined(uart_interface uif);

    int              num;
    environment      env;
    transaction_mode tr_mode;

    initial begin

        env = new(uif);

        repeat(256) begin //////////////////////////////// 256

            tr_mode       = new();
            env.gen.trans = tr_mode; 
            num           = $urandom_range(5, 5); //////////////////////////////// 20, 50
            env.drv.LOOPBACK_CHARACTER_NUM = num;
            env.drv.loop_count             = num;
            env.gen.repeat_count           = num;
            env.gen.signal_generate();
            env.drv.run_sim_control();

        end

    end

endprogram : testcase_combined
