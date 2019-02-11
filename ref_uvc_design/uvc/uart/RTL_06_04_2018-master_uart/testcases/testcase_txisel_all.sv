class transaction_mode extends transaction;
  
  constraint mod_cnst { 
                        mode              dist {

                                                  32'h0000_0090 := 1,
                                                  32'h0000_1090 := 2,
                                                  32'h0000_2090 := 2,
                                                  32'h0000_3090 := 1

                                                };
                        interrupts_config ==  3'b001;  //For TX MODE
                		    ins_errors        ==  2'b00;
                        block_sel         ==  2'b00;
                        special           ==  2'b00;
                      }
  
endclass : transaction_mode


program testcase_combined(uart_interface uif);

    int              num;
    environment      env;
    transaction_mode tr_mode;

    initial begin

        env = new(uif);

        repeat(50) begin

            tr_mode       = new();
            env.gen.trans = tr_mode; 
            num           = $urandom_range(5, 10);
            env.drv.LOOPBACK_CHARACTER_NUM = num;
            env.drv.loop_count             = num;
            env.gen.repeat_count           = num;
            env.gen.signal_generate();
            env.drv.run_sim_control();

        end

    end

endprogram : testcase_combined
