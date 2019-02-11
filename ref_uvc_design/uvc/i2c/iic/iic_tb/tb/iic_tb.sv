/////////////////////////////////////////////////////////////////////
////                                                             ////
////  I2C verification environment using the UVM                 ////
////                                                             ////
////                                                             ////
////  Author: Carsten Thiele                                     ////
////          carsten.thiele@enquireservicesltd.co.uk            ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2012                                          ////
////          Enquire Services                                   ////
////          carsten.thiele@enquireservicesltd.co.uk            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

module top;
 import uvm_pkg::*;
 import iic_agent_pkg::*;
 import wb_agent_pkg::*;
 import iic_test_pkg::*;

 iicIf iicIf1();
 iicIf iicIf2();
 iicIf iicIf3();
 iicIf iicIf4();
 iicIf iicIf5();

 wbIf  wbIf();

 wire scl, sda;

 wire dut_scl_o, dut_scl_oen, dut_sda_o, dut_sda_oen;

 initial begin
  uvm_config_db#(virtual iicIf)::set(null,"*","iicIf1", iicIf1);
  uvm_config_db#(virtual iicIf)::set(null,"*","iicIf2", iicIf2);
  uvm_config_db#(virtual iicIf)::set(null,"*","iicIf3", iicIf3);
  uvm_config_db#(virtual iicIf)::set(null,"*","iicIf4", iicIf4);
  uvm_config_db#(virtual iicIf)::set(null,"*","iicIf5", iicIf5);
  uvm_config_db#(virtual wbIf)::set(null,"*","wbIf", wbIf);
 end

 pullup(scl);
 pullup(sda);

 bufif0(scl, 1'b0, iicIf1.scl_out);
 bufif0(sda, 1'b0, iicIf1.sda_out);
 bufif0(scl, 1'b0, iicIf2.scl_out);
 bufif0(sda, 1'b0, iicIf2.sda_out);
 bufif0(scl, 1'b0, iicIf3.scl_out);
 bufif0(sda, 1'b0, iicIf3.sda_out);
 bufif0(scl, 1'b0, iicIf4.scl_out);
 bufif0(sda, 1'b0, iicIf4.sda_out);
 bufif0(scl, 1'b0, iicIf5.scl_out);
 bufif0(sda, 1'b0, iicIf5.sda_out);
 bufif0(scl, dut_scl_o, dut_scl_oen);
 bufif0(sda, dut_sda_o, dut_sda_oen);

 assign iicIf1.scl_in = scl;
 assign iicIf1.sda_in = sda; 
 assign iicIf1.rst    = wbIf.rst;

 assign iicIf2.scl_in = scl; 
 assign iicIf2.sda_in = sda; 
 assign iicIf2.rst    = wbIf.rst;
 
 assign iicIf3.scl_in = scl; 
 assign iicIf3.sda_in = sda; 
 assign iicIf3.rst    = wbIf.rst; 

 assign iicIf4.scl_in = scl; 
 assign iicIf4.sda_in = sda; 
 assign iicIf4.rst    = wbIf.rst; 

 assign iicIf5.scl_in = scl; 
 assign iicIf5.sda_in = sda; 
 assign iicIf5.rst    = wbIf.rst; 

 i2c_master_top dut(
  .wb_clk_i(wbIf.clk),
  .wb_rst_i(wbIf.rst),
  .arst_i(wbIf.arst),
  .wb_adr_i(wbIf.addr),
  .wb_dat_i(wbIf.dat_o),
  .wb_dat_o(wbIf.dat_i),
  .wb_we_i(wbIf.we),
  .wb_stb_i(wbIf.stb),
  .wb_cyc_i(wbIf.cyc),
  .wb_ack_o(wbIf.ack),
  .wb_inta_o(wbIf.inta),

  .scl_pad_i(scl),
  .scl_pad_o(dut_scl_o),
  .scl_padoen_o(dut_scl_oen),

  .sda_pad_i(sda),
  .sda_pad_o(dut_sda_o),
  .sda_padoen_o(dut_sda_oen)  
 );

 iic_fcov_monitor iic_fcov_monitor_inst(dut_scl_oen, dut_sda_oen, scl,sda, wbIf.clk, wbIf.rst);


 initial begin
  wbIf.rst   <= 1'b1;
  wbIf.arst  <= 1'b0;
  repeat(100) @(posedge wbIf.clk);
  wbIf.rst   <= 1'b0;
  wbIf.arst  <= 1'b1;  
 end

 initial run_test();

endmodule
