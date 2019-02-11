module ram_top(
               hclk                ,
               hresetn             ,
               hsel_s              ,
               haddr_s             ,
               hburst_s            ,
               htrans_s            ,
               hrdata_s            ,
               hwdata_s            ,
               hwrite_s            ,
               hready_s            ,
               hresp_s
               );

input               hclk           ;
input               hresetn        ;
input               hsel_s         ;
input     [19:0]     haddr_s        ;
input     [2:0]     hburst_s       ;
input     [1:0]     htrans_s       ;
input     [31:0]    hwdata_s       ;
input               hwrite_s       ;

output    [1:0]     hresp_s        ;
output    [31:0]    hrdata_s       ;
output              hready_s       ;

wire      [31:0]    ram_rdata      ;
wire      [17:0]     ram_addr       ;
wire      [31:0]    ram_wdata      ;
wire                ram_write      ;

ram_ahbif U_ram_ahbif(
               .hclk          (hclk          ),
               .hresetn       (hresetn       ),
               .hsel_s        (hsel_s        ),
               .haddr_s       (haddr_s       ),
               .hburst_s      (hburst_s      ),
               .htrans_s      (htrans_s      ),
               .hrdata_s      (hrdata_s      ),
               .hwdata_s      (hwdata_s      ),
               .hwrite_s      (hwrite_s      ),
               .hready_s      (hready_s      ),
               .hresp_s       (hresp_s       ),
               .ram_rdata     (ram_rdata     ),
               .ram_addr      (ram_addr      ),
               .ram_wdata     (ram_wdata     ),
               .ram_write     (ram_write     )
                 );

ram_infer U_ram_infer(
               .q             (ram_rdata     ),
               .a             (ram_addr      ),
               .d             (ram_wdata     ),
               .we            (ram_write     ),
               .clk           (hclk          )
                 );

endmodule