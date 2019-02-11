class u0_xtn extends uvm_sequence_item;
  
  //`include "u0_xtn_defines.sv"

  bit  rst;
  typedef enum bit [1:0] {RST, WR, RD} cmd_e;
  rand cmd_e cmd;
  
  rand logic read;
  rand logic write;
       logic txir;         // transmitter interrupt request
       logic txack;        // Acknowledge for txir from CPU
  // rand logic rxir;         // receiver interrupt request
  // rand logic rxack;        // rxir acknowledge
       logic tcir;         // transmitter complete interrupt request
       logic tcack;        // ack for transmitter complete
       logic txdata;       // UART data out
  rand logic rxdata;       // UART data in
  rand logic [7:0] addr; 
  rand logic [7:0] din ; 
  logic [7:0] dout; 

  // CSR Registers
  // UCSRnA  : 'hC0
  logic         RXCn;    // USART Receive Complete  
  logic         TXCn;    // USART Transmit Complete 
  logic         UDREn;   // USART Date Register Empty
  logic         FEn  ;   // USART Frame Error       
  logic         DORn ;   // USART Data OverRun      
  logic         UPEn ;   // USART Parity Error       
  logic         U2Xn;    // Double USART Transmission speed
  logic         MPCMn;   // Multi-processor Communication Mode

  // UCSRnA  : 'hC1
  logic         RXCIEn;  // RX Complete Interrupt Enable 
  logic         TXCIEn;  // TX Complete Interrupt Enable 
  logic         UDRIEn;  // USART Data Register Empty Interrupt Enable
  logic         RXENn ;  // Receiver Enable 
  logic         TXEn;    // Transmitter Enable 
  logic         UCSZ2n;  // Character size 
  logic         RXB8n;   // Receive Data Bit 8
  logic         TXB8n;   // Transmit Data Bit 8

  // UCSRnA  : 'hC2
  logic [1:0]   UMSELn;  // USART Mode Select. Fixed to Async USART. 'b00.
  logic [1:0]   UPMn;    // Parity Mode. 
  logic         USBSn;   // Stop Bit Select.
  logic [1:0]   UCSZn;   // Character size 
  logic         UCPOLn;  // Stop Bit Select.


  logic [11:0]  UBBRn;   // UBBRnH[11:8] & UNNRnL[7:0]
  // logic [07:0]  UBBRLn;  // UNNRnL[7:0]
  // logic [03:0]  UBBRHn;  // UBBRnH[11:8] 

  // Factory registration
  `uvm_object_utils_begin(u0_xtn)
    // `uvm_field_enum( cmd_e, cmd, UVM_ALL_ON)
    `uvm_field_int( read  , UVM_ALL_ON)
    `uvm_field_int( write , UVM_ALL_ON)
    // `uvm_field_int( txack , UVM_ALL_ON)
    // `uvm_field_int( rxack , UVM_ALL_ON)
    // `uvm_field_int( tcack , UVM_ALL_ON)
    `uvm_field_int( din   , UVM_ALL_ON)
    `uvm_field_int( dout  , UVM_ALL_ON)
    `uvm_field_int( txdata, UVM_ALL_ON)
    // `uvm_field_int( rxdata, UVM_ALL_ON)
    `uvm_field_int( addr  , UVM_ALL_ON)
    // `uvm_field_int( U2Xn  , UVM_ALL_ON)
    // `uvm_field_int( TXEn  , UVM_ALL_ON)  // Will be controlled in the driver
    // `uvm_field_int( UCSZn , UVM_ALL_ON)
    // `uvm_field_int( UPMn  , UVM_ALL_ON)
    // `uvm_field_int( USBSn , UVM_ALL_ON)
    // `uvm_field_int( UBBRn , UVM_ALL_ON)
  `uvm_object_utils_end 

  // Constructor
  function new(string name="u0_xtn");
    super.new(name);
  endfunction 

  // Constraints 
  constraint valid_data_c { 
                            din  inside {[0:'hff]};
                            }
  constraint valid_cmd_c  { read != write;}


endclass 
