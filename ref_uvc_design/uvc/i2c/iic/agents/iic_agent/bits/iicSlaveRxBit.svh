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

class iicSlaveRxBit extends iicBit;
 `uvm_object_utils(iicSlaveRxBit)
 
  extern function new(string name = "iicSlaveRxBit");
  extern virtual task doSCL();
  extern virtual task doSDA();
 
endclass

function iicSlaveRxBit::new(string name = "iicSlaveRxBit");
 super.new(name);
endfunction


task iicSlaveRxBit::doSCL;
 `uvm_info("iicSlaveRxBit", "called doSCL", UVM_HIGH)
 m_iicIf.scl_out <= 1;
 wait(m_iicIf.scl_in==0);
 if ($urandom_range(100)<m_clockStretchingProbability) begin
  m_iicIf.scl_out <= 0;
  #m_sclLowTime;
  `uvm_info(m_name, $psprintf("Stretching clock by %d.", m_clockStretchDelta),UVM_LOW);
  #m_clockStretchDelta;
  m_iicIf.scl_out <= 1;
 end 
 @(posedge m_iicIf.scl_in);
 @(negedge m_iicIf.scl_in);
 `uvm_info("iicSlaveRxBit", "finished doSCL", UVM_HIGH)
endtask


task iicSlaveRxBit::doSDA;
 `uvm_info("iicSlaveRxBit", "called doSDA", UVM_HIGH)
 m_iicIf.sda_out <= 1;
 `uvm_info("iicSlaveRxBit", "finished doSDA", UVM_HIGH)
endtask
