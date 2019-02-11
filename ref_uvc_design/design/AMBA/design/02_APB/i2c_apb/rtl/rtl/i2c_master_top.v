// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "i2c_master_defines.v"

module i2c_master_top(
	pclk,presetn,psel,penable,pwrite,paddr,pwdata,prdata,arst_i,
	scl_pad_i, scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o );

	// parameters
	parameter ARST_LVL = 1'b0; // asynchronous reset level

	//
	// inputs & outputs
	//

    // APB signals
    input         arst_i;
    input         pclk;       // master clock input
    input         presetn;    //synchronous active low reset    
    input         psel;       //slave sel
    input         penable;    //enable
    input         pwrite;     //transmit direction
    input   [2:0] paddr;      //lower address bits
    input   [7:0] pwdata;     //write data
    output  [7:0] prdata;     //read data
           
	reg [7:0] prdata;

	// I2C signals
	// i2c clock line
	input  scl_pad_i;       // SCL-line input
	output scl_pad_o;       // SCL-line output (always 1'b0)
	output scl_padoen_o;    // SCL-line output enable (active low)

	// i2c data line
	input  sda_pad_i;       // SDA-line input
	output sda_pad_o;       // SDA-line output (always 1'b0)
	output sda_padoen_o;    // SDA-line output enable (active low)


	//
	// variable declarations
	//

	// registers
	reg  [15:0] prer; // clock prescale register
	reg  [ 7:0] ctr;  // control register
	reg  [ 7:0] txr;  // transmit register
	wire [ 7:0] rxr;  // receive register
	reg  [ 7:0] cr;   // command register
	wire [ 7:0] sr;   // status register

	// done signal: command completed, clear command register
	wire done;

	// core enable signal
	wire core_en;
	wire ien;

	// status register signals
	wire irxack;
	reg  rxack;       // received aknowledge from slave
	reg  tip;         // transfer in progress
	reg  irq_flag;    // interrupt pending flag
	wire i2c_busy;    // bus busy (start signal detected)
	wire i2c_al;      // i2c bus arbitration lost
	reg  al;          // status register arbitration lost bit

	//
	// module body
	//

	// generate internal reset
	wire rst_i = arst_i ^ ARST_LVL;

	// generate APB signals
	wire wren = pwrite & psel & penable;  

	// assign DAT_O
	always @(posedge pclk)
	begin                                            
	    case (paddr)
	    3'b000: prdata <= #1 prer[ 7:0];
	    3'b001: prdata <= #1 prer[15:8];
	    3'b010: prdata <= #1 ctr;
	    3'b011: prdata <= #1 rxr; 
	    3'b100: prdata <= #1 sr;  
	    3'b101: prdata <= #1 txr; // write is transmit register (txr)
	    3'b110: prdata <= #1 cr;// write is command register (cr)
	    3'b111: prdata <= #1 0;   // reserved
	    endcase
	end                                              

	// generate registers
	always @(posedge pclk or negedge rst_i)     
	  if (!rst_i)                                 
	    begin                                     
	        prer <= #1 16'hffff;                  
	        ctr  <= #1  8'h0;                     
	        txr  <= #1  8'h0;                     
	    end                                       
	  else if (!presetn)                          
	    begin                                     
	        prer <= #1 16'hffff;                  
	        ctr  <= #1  8'h0;                     
	        txr  <= #1  8'h0;                    
	    end                                      
	  else                                        
	    if (wren)                              
	      case (paddr) // synopsys parallel_case      
	         3'b000 : prer [ 7:0] <= #1 pwdata;  
	         3'b001 : prer [15:8] <= #1 pwdata;
	         3'b010 : ctr         <= #1 pwdata;
	         3'b011 : txr         <= #1 pwdata;
	         default: ;                                  
	      endcase                                        

	// generate command register (special case)
	always @(posedge pclk or negedge rst_i)   
	  if (!rst_i)                                 
	    cr <= #1 8'h0;                            
	  else if (!presetn)                          
	    cr <= #1 8'h0;                               
	  else if (wren)                               
	    begin                                     
	        if (core_en & (paddr == 3'b110) )  
	          cr <= #1 pwdata;
	    end                                      
	  else                                        
	    begin                                     
	        if (done | i2c_al)                    
	          cr[7:4] <= #1 4'h0;           // clear command bits when done   
	                                        // or when aribitration lost
	        cr[2:1] <= #1 2'b0;             // reserved bits                  
	        cr[0]   <= #1 1'b0;             // clear IRQ_ACK bit              
	    end                                                                  


	// decode command register
	wire sta  = cr[7];
	wire sto  = cr[6];
	wire rd   = cr[5];
	wire wr   = cr[4];
	wire ack  = cr[3];
	wire iack = cr[0];

	// decode control register
	assign core_en = ctr[7];
	assign ien = ctr[6];

	// hookup byte controller block
	i2c_master_byte_ctrl byte_controller (
		.clk      ( pclk     ),
		.rst      ( !presetn     ),
		.nReset   ( rst_i        ),
		.ena      ( core_en      ),
		.clk_cnt  ( prer         ),
		.start    ( sta          ),
		.stop     ( sto          ),
		.read     ( rd           ),
		.write    ( wr           ),
		.ack_in   ( ack          ),
		.din      ( txr          ),
		.cmd_ack  ( done         ),
		.ack_out  ( irxack       ),
		.dout     ( rxr          ),
		.i2c_busy ( i2c_busy     ),
		.i2c_al   ( i2c_al       ),
		.scl_i    ( scl_pad_i    ),
		.scl_o    ( scl_pad_o    ),
		.scl_oen  ( scl_padoen_o ),
		.sda_i    ( sda_pad_i    ),
		.sda_o    ( sda_pad_o    ),
		.sda_oen  ( sda_padoen_o )
	);

	// status register block + interrupt request signal
	always @(posedge pclk or negedge rst_i)
	  if (!rst_i)
	    begin
	        al       <= #1 1'b0;
	        rxack    <= #1 1'b0;
	        tip      <= #1 1'b0;
	        irq_flag <= #1 1'b0;
	    end
	  else if (!presetn)
	    begin
	        al       <= #1 1'b0;
	        rxack    <= #1 1'b0;
	        tip      <= #1 1'b0;
	        irq_flag <= #1 1'b0;
	    end
	  else
	    begin
	        al       <= #1 i2c_al | (al & ~sta);
	        rxack    <= #1 irxack;
	        tip      <= #1 (rd | wr);
	        irq_flag <= #1 (done | i2c_al | irq_flag) & ~iack; // interrupt request flag is always generated
	    end
	
	// assign status register bits
	assign sr[7]   = rxack;
	assign sr[6]   = i2c_busy;
	assign sr[5]   = al;
	assign sr[4:2] = 3'h0; // reserved
	assign sr[1]   = tip;
	assign sr[0]   = irq_flag;

endmodule
