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

class iicMasterTxBit extends iicBit;

 `uvm_object_utils(iicMasterTxBit)


 extern function new(string name = "iicMasterTxBit");
 extern virtual task doSCL();
 extern virtual task doSDA();
 extern virtual task doRxBit();

endclass


function iicMasterTxBit::new(string name = "iicMasterTxBit");
 super.new(name);

endfunction

task iicMasterTxBit::doSCL;
 `uvm_info("iicMasterTxBit", "called doSCL", UVM_HIGH)
 m_iicIf.scl_out <= 0;
 #m_sclLowTime;
 m_iicIf.scl_out <= 1;
 wait( m_iicIf.scl_in==1);
 fork 
  @(negedge m_iicIf.scl_in);
  #m_sclHighTime;
 join_any
 m_iicIf.scl_out <= 0;
 `uvm_info("iicMasterTxBit", "finished doSCL", UVM_HIGH)
endtask

task iicMasterTxBit::doSDA;
 `uvm_info("iicMasterTxBit", "called doSDA", UVM_HIGH)
 #m_sdaChangePoint;
 m_iicIf.sda_out <= m_iicBitTx;
 @(posedge m_iicIf.scl_in);
 `uvm_info("iicMasterTxBit", "finished doSDA", UVM_HIGH)
endtask

task iicMasterTxBit::doRxBit();
 `uvm_info(m_name, "called doRxBit", UVM_HIGH)
 super.doRxBit;
 if (m_iicBitTx!=m_iicBitRx) begin
  m_arbitrationLost = 1;
 end
 `uvm_info(m_name, "finished doRxBit", UVM_HIGH)
endtask
