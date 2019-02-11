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

class iicSlaveTxBit extends iicBit;
 `uvm_object_utils(iicSlaveTxBit)

  //ui m_sclLowTime;    //ns
  //ui m_sclHighTime;   //ns
  //ui m_sdaChangePoint; //ns -Time after SCL low where SDA can change.
 
  extern function new(string name = "iicSlaveTxBit");
  extern virtual task doSCL();
  extern virtual task doSDA();
  extern virtual task doRxBit();
  
endclass

function iicSlaveTxBit::new(string name = "iicSlaveTxBit");
 super.new(name);
endfunction

task iicSlaveTxBit::doSCL;
 `uvm_info("iicSlaveTxBit", "called doSCL", UVM_HIGH)
 //the default slave rx bit does not stretch SCL.
 m_iicIf.scl_out <= 1;
 if ($urandom_range(100)<=m_clockStretchingProbability) begin
  `uvm_info(m_name, $psprintf("%t : stretching clock by %d.", $time,m_clockStretchDelta),UVM_LOW);
  m_iicIf.scl_out <= 0;
  #m_sclLowTime;
  #m_clockStretchDelta;
  m_iicIf.scl_out <= 1;
 end 
 `uvm_info("iicSlaveTxBit", "finished doSCL", UVM_HIGH)
endtask

task iicSlaveTxBit::doSDA;
 `uvm_info(m_name, "called doSDA", UVM_HIGH)
 wait(m_iicIf.scl_in==0);
  //Don't have control over clock.Safest thing
  //is to put out the new data on the falling clock edge.
 //#m_sdaChangePoint;
 m_iicIf.sda_out <= m_iicBitTx;
 @(posedge m_iicIf.scl_in);
 @(negedge m_iicIf.scl_in);
 `uvm_info(m_name, "finished doSDA", UVM_HIGH)
endtask

task iicSlaveTxBit::doRxBit();
 `uvm_info(m_name, "called doRxBit", UVM_HIGH)
 super.doRxBit;
 `uvm_info(m_name, "finished doRxBit", UVM_HIGH)
endtask
