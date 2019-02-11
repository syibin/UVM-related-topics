//------------------------------------
//APB (Advanced peripheral Bus) Interface 
//
//------------------------------------
`ifndef APB_IF_SV
`define APB_IF_SV

interface i2c_if;

  logic [15:0] sig_a;
  logic [15:0] sig_b;
	logic sig_ab_valid;
	logic sig_ab_ready;

	logic sig_clk;
	logic sig_rst;
    
  logic [32:0] sig_z;
	logic sig_z_valid;
  
  logic [15:0] sig_a_real;
  logic [15:0] sig_b_real;
  

endinterface: seqMult_if

`endif
