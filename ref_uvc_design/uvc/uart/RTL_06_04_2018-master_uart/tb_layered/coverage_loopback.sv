covergroup uart_cg_loopback;
      option.per_instance = 1;

      txisel: coverpoint trans.mode[13:12] {

            bins txisel_0 = {2'b00};
            bins txisel_1 = {2'b01};
            option.at_least = 1;

      }   

      rxisel: coverpoint trans.mode[9:8] {

            bins rxisel0 = {2'b00};
            bins rxisel1 = {2'b01};
            bins rxisel2 = {2'b10};
            bins rxisel3 = {2'b11};
            option.at_least = 1;

      }

      fce: coverpoint trans.mode[4] {

            bins fce0 = {1'b0};
            bins fce1 = {1'b1};
            option.at_least = 1;

      }

      brg: coverpoint trans.mode[3] {

            bins brg0 = {1'b0};
            bins brg1 = {1'b1};
            option.at_least = 1;

      }

      stsel: coverpoint trans.mode[2] {

            bins stsel0 = {1'b0};
            bins stsel1 = {1'b1};
            option.at_least = 1;

      }

      pdsel: coverpoint trans.mode[1:0] {

            bins pdsel0 = {2'b00};
            bins pdsel1 = {2'b01};
            bins pdsel2 = {2'b10};
            bins pdsel3 = {2'b11};
            option.at_least = 1;

      }

      cross txisel, rxisel, fce, brg, stsel, pdsel;

endgroup 

