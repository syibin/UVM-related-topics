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

class iicMasterStopBit extends iicMasterTxBit;
 `uvm_object_utils(iicMasterStopBit)

 extern virtual task doSDA();
 extern function new(string name = "iicMasterStopBit");
 extern virtual task detectStartCondition();
 extern virtual task detectStopCondition();
 extern virtual task doRxBit();

endclass

function iicMasterStopBit::new(string name = "iicMasterStopBit");
 super.new(name);
endfunction

task iicMasterStopBit::doSDA;
 `uvm_info("iicMasterStopBit", "called doSDA", UVM_HIGH)
 #m_sdaChangePoint;
 m_iicIf.sda_out <= m_iicBitTx;
 @(posedge m_iicIf.scl_in);
 #m_tSuStoMin;
 m_iicIf.sda_out <= 1'b1;
 if (m_iicIf.scl_in==0) begin
  `uvm_fatal("iicMasterStopBit","SCL not high during stop bit.")
 end else
 `uvm_info("iicMasterStopBit", "finished doSDA", UVM_HIGH)
endtask

task iicMasterStopBit::doRxBit;
 //nothing to receive for STOP bit.
endtask

task iicMasterStopBit::detectStartCondition();
 //Cant happen here.
 wait(0);
endtask


task iicMasterStopBit::detectStopCondition();
 //This bit is about doing the STOP condition.
 wait(0);
endtask
