`include "includes.sv"

module uart_top_tb;

    bit clk;

    always #5 clk = ~clk;

    uart_interface uif(clk);

    initial begin

        repeat(20) @(posedge clk);
        uif.rst_n <= 1'b1;

    end

    uart_top #( .APB_ADDR_WIDTH   ( 8                  ),
                .APB_BASE_ADDRESS ( `UART_BASE_ADDRESS ))
    uart_u    (
                .clk          ( clk       ),
                .rst_n        ( uif.rst_n     ),

                // APB register's interface

                .apb_addr_i   ( uif.paddr     ),
                .apb_sel_i    ( uif.psel      ),
                .apb_en_i     ( uif.penable   ),
                .apb_wr_i     ( uif.pwrite    ),
                .apb_wdata_i  ( uif.pwdata    ),
                .apb_strb_i   ( uif.pstrb     ),
                .apb_rdata_o  ( uif.prdata    ),
                .apb_ready_o  ( uif.pready    ),
                .apb_err_o    ( uif.pslverr   ),

                //interrupt

                .int_o        ( uif.interrupt ),

                // external interface

                `ifdef DRIVER
                  int_o       (vua),
                `endif

                .cts_i        ( uif.cts       ),
                .txd_o        ( uif.txd       ),
                .rxd_i        ( uif.rxd       ),
                .rts_o        ( uif.rts       ),
                .rx_trig_o    ( uif.rx_trig_o ),
                .tx_trig_o    ( uif.tx_trig_o )
);

testcase_combined tc(uif);


initial begin

   $dumpfile("dump.vcd");
   $dumpvars;

end

endmodule
