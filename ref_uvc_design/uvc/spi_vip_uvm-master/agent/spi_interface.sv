interface spi_interface;
    logic clk;
    logic reset_n;
    logic enable;
    logic cpol;
    logic cpha;
    logic [3:0] clk_div;
    logic [15:0] tx_data;
    logic miso;
    logic sclk;
    logic ss_n;
    logic mosi;
    logic busy;
    logic [15:0] rx_data;

    /*default clocking cb @(posedge clk);
        default input #1 output #1;
        input negedge reset_n;
        input enable, cpol, cpha, clk_div, tx_data, miso;
        output ss_n, mosi, busy, rx_data;
    endclocking*/

endinterface