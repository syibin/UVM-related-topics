
// Testbench for AHB-Lite master emulator
`timescale 1ns / 100ps

module test_uart_transmit;

    `include "ahb_lite.vh"
    `include "uart.vh"
    `include "uart_defines.v"

    assign UART_SRX = UART_STX;

    ahb_lite_uart16550 uart
    (
        .HCLK       (   HCLK        ),
        .HRESETn    (   HRESETn     ),
        .HADDR      (   HADDR       ),
        .HBURST     (   HBURST      ),
        .HSEL       (   HSEL        ),
        .HSIZE      (   HSIZE       ),
        .HTRANS     (   HTRANS      ),
        .HWDATA     (   HWDATA      ),
        .HWRITE     (   HWRITE      ),
        .HRDATA     (   HRDATA      ),
        .HREADY     (   HREADY      ),
        .HRESP      (   HRESP       ),

        .UART_SRX   (   UART_SRX    ),  // UART serial input signal
        .UART_STX   (   UART_STX    ),  // UART serial output signal
        .UART_RTS   (   UART_RTS    ),  // UART MODEM Request To Send
        .UART_CTS   (   UART_CTS    ),  // UART MODEM Clear To Send
        .UART_DTR   (   UART_DTR    ),  // UART MODEM Data Terminal Ready
        .UART_DSR   (   UART_DSR    ),  // UART MODEM Data Set Ready
        .UART_RI    (   UART_RI     ),  // UART MODEM Ring Indicator
        .UART_DCD   (   UART_DCD    ),  // UART MODEM Data Carrier Detect

        //UART internal
        .UART_BAUD  (   UART_BAUD   ),  // UART baudrate output
        .UART_INT   (   UART_INT    )   // UART interrupt
    );

    parameter Tclk = 20;
    always #(Tclk/2) HCLK = ~HCLK;

    initial begin
        begin

            HRESETn = 0;
            @(posedge HCLK);
            @(posedge HCLK);
            HRESETn = 1;

            @(posedge HCLK);
            //uart init & transmit 1 byte 0xF1

            // 1 working
            // ahbPhaseFst((`UART_REG_LC   << 2),   1, St_x);

            ahbPhaseFst((`UART_REG_LC   << 2),   1, St_x);
            ahbPhase   ((`UART_REG_MC   << 2),   1, 8'b11);     //8n1
            ahbPhase   ((`UART_REG_LC   << 2),   1, 8'b11);     //DTR + RTS
            
            // ahbPhase   ((`UART_REG_IE   << 2),   1, 8'b11);     //8n1
            // ahbPhase   ((`UART_REG_FC   << 2),   1, 8'b0);      //no interrupt
            // ahbPhase   ((`UART_REG_MC   << 2),   1, 8'b0);      //no fifo
            // ahbPhase   ((`UART_REG_LC   << 2),   0, 8'b11);     //DTR + RTS
            

            ahbPhase    ((`UART_REG_DL1  << 2),  1, 8'b11 | (1 << 7));
            ahbPhase    ((`UART_REG_DL2  << 2),  1, 8'd2);
            ahbPhase    ((`UART_REG_LC   << 2),   1, 8'b0);
            ahbPhase    ((`UART_REG_TR   << 2),   1, 8'b11);
            ahbPhase    ((`UART_REG_LS   << 2),   0, 8'h22);
            ahbPhase    ((`UART_REG_LS   << 2),   0, St_x);
            
            //waiting for transmit finish
            repeat(400)
                ahbPhase((`UART_REG_LS  << 2), 0, St_x);
            
            //reading input
            ahbPhase    ((`UART_REG_RB   << 2), 0, St_x);
            ahbPhase    ((`UART_REG_RB   << 2), 0, St_x);

            ahbPhaseLst ((`UART_REG_RB   << 2), 0, St_x);

            @(posedge HCLK);
            @(posedge HCLK);
        end
        $stop;
        $finish;
    end

endmodule