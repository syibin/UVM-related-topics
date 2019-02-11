`ifndef SPI_ITEM
`define SPI_ITEM
import uvm_pkg::*;

class spi_item extends uvm_sequence_item;
    `uvm_object_utils(spi_item)    
    //Control Info
    rand bit cpol;
    rand bit cpha;
    rand bit [3:0] clk_div;
    
    //Payload member
    rand bit[15:0] tx_data;
    rand bit[15:0] miso_data;
    
    //Analysis member
     logic[31:0] nedge_mosi;
     logic[31:0] pedge_mosi;
     logic[31:0] nedge_miso;
     logic[31:0] pedge_miso;
     logic[31:0] rx_data;
     logic cs_n;
     
    function new(string name = "spi_item");
        super.new(name);
    endfunction
        
    //Constraintler
    
endclass
`endif