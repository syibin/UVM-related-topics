class transaction_mode extends transaction;
  
  constraint mod_cnst { 
                        mode  inside {

                                                /***************RX MODES***************/
                                          [32'h0000_0080:32'h0000_009F], [32'h0000_0180:32'h0000_019F], 
                                          [32'h0000_0280:32'h0000_029F], [32'h0000_0380:32'h0000_039F]/*,

                                          [32'h0000_0880:32'h0000_089F], [32'h0000_0980:32'h0000_099F],
                                          [32'h0000_0A80:32'h0000_0A9F], [32'h0000_0B80:32'h0000_0B9F]*/

                                      };

                        interrupts_config ==  3'b001;  //For TX MODE
                		ins_errors        ==  2'b00;
                        block_sel         ==  2'b00;
                        special           ==  2'b11;
                        mode[4]           ==  1'b1;    //Flow Control Enabled
                        mode[1:0]         ==  2'b00;
                        mode[2]           ==  1'b0;
                      }
  
endclass : transaction_mode


program testcase_combined(uart_interface uif);

    int              num;
    environment      env;
    transaction_mode tr_mode;

    initial begin

        env = new(uif);

        repeat(1250) begin

            tr_mode       = new();
            env.gen.trans = tr_mode; 
            num           = $urandom_range(5, 10);
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
