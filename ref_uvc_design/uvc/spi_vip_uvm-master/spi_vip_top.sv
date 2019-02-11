module spi_vip_top;

    import uvm_pkg::*;
    import spi_test_pkg::*;
    import spi_agent_pkg::*;
           
    logic clock;
    logic reset_n;
    
    spi_interface spi_vif();
    
    spi_master dut1(
        .clk(clock),
        .reset_n(spi_vif.reset_n),
        .enable(spi_vif.enable),
        .cpol(spi_vif.cpol),
        .cpha(spi_vif.cpha),
        .clk_div(spi_vif.clk_div),
        .tx_data(spi_vif.tx_data),
        .miso(spi_vif.miso),
        .sclk(spi_vif.sclk),
        .ss_n(spi_vif.ss_n),
        .mosi(spi_vif.mosi),
        .busy(spi_vif.busy),
        .rx_data(spi_vif.rx_data));
        
        
    
    initial begin
        uvm_config_db #(virtual spi_interface)::set(null, "*", "spi_vif", spi_vif);
    
        run_test("spi_test");
    end
    
  //
  // Clock and reset initial block:
  //
  
initial begin 
  clock = 0;
  
  /*reset_n = 0;
  repeat(8) begin
    #10ns clock = ~clock;
  end
  reset_n = 1;
  repeat(8) begin
    #10ns clock = ~clock;
  end*/
  
  //Start clock
  forever begin
    #10ns clock = ~clock;
  end
  end
    
 endmodule
 