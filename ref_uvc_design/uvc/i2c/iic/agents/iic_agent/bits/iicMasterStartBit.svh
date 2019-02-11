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

class iicMasterStartBit extends iicBit;
 `uvm_object_utils(iicMasterStartBit)

 extern function new(string name = "iicMasterStartBit");
 extern virtual task doSCL();
 extern virtual task doSDA();
 extern virtual task doRxBit();
 extern virtual task detectStartCondition();
 extern virtual task detectStopCondition();

endclass

function iicMasterStartBit::new(string name = "iicMasterStartBit");
 super.new(name);
endfunction

task iicMasterStartBit::doSCL;
 `uvm_info("iicMasterStartBit", "called doSCL", UVM_HIGH)
 //#m_tBufMin;
 wait (m_iicIf.sda_out==1'b0);
 #m_fHdStaMin;
 `uvm_warning(m_name,"Extended start bit hold time for DUT compatibility.")
  m_iicIf.scl_out <= 0; 
 `uvm_warning(m_name,"Extended start bit hold time for DUT compatibility.")
 #m_sdaChangePoint;

 `uvm_info("iicMasterStartBit", "finished doSCL", UVM_HIGH)
endtask

task iicMasterStartBit::doSDA;
 `uvm_info("iicMasterStartBit", "called doSDA", UVM_HIGH)
 m_iicIf.sda_out <= 0; 
 `uvm_info("iicMasterStartBit", "finished doSDA", UVM_HIGH)
endtask

task iicMasterStartBit::doRxBit();
  //left intentionally blank.
  //doRxBit in iicBit waits for rising clock edge.
  //This does not happen for a start bit. The base
  //funciton needs to be overrriden with this function
  //that does nothing.
endtask

task iicMasterStartBit::detectStartCondition();
 //This bit is about sending the START condition.
 wait(0);
endtask


task iicMasterStartBit::detectStopCondition();
 //Can't happen here.
 wait(0);
endtask
