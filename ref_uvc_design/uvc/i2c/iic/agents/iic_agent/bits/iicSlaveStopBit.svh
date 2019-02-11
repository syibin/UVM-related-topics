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

class iicSlaveStopBit extends iicBit;
 `uvm_object_utils(iicSlaveStopBit)

 extern function new(string name = "iicSlaveStopBit");
 extern virtual task doSCL();
 extern virtual task doSDA();
 
endclass

function iicSlaveStopBit::new(string name = "iicSlaveStopBit");
 super.new( name);
endfunction

task iicSlaveStopBit::doSCL;
 `uvm_info("iicSlaveStopBit", "called doSCL", UVM_HIGH)
 //clock controlled by master.
 `uvm_info("iicSlaveStopBit", "finished doSCL", UVM_HIGH)
endtask

task iicSlaveStopBit::doSDA;
 `uvm_info("iicSlaveStopBit", "called doSDA", UVM_HIGH)
 if ($urandom_range(100)<=m_clockStretchingProbability) begin
  wait(m_iicIf.scl_in==0); 
  `uvm_info(m_name, $psprintf("%t : stretching clock by %d.", $time,m_clockStretchDelta),UVM_LOW);
  m_iicIf.scl_out <= 0;
  #m_sclLowTime;
  #m_clockStretchDelta;
  m_iicIf.scl_out <= 1;
 end 
 forever begin
  @(posedge m_iicIf.sda_in);
   if (m_iicIf.scl_in==1)
    break;
 end
 `uvm_info("iicSlaveStopBit", "finished doSDA", UVM_HIGH)
endtask

