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

class iicSlaveStartBit extends iicBit;
 `uvm_object_utils(iicSlaveStartBit)

 extern function new(string name = "iicSlaveStartBit");
 extern virtual task doSCL();
 extern virtual task doSDA();
 extern virtual task doRxBit();
 extern virtual task detectStartCondition();
 extern virtual task detectStopCondition();
 extern virtual function void setTiming();
 
endclass

function iicSlaveStartBit::new(string name = "iicSlaveStartBit");
 super.new(name);
 m_bitTimeout=0;
endfunction

task iicSlaveStartBit::doSCL;
 `uvm_info("iicSlaveStartBit", "called doSCL", UVM_HIGH)
 //clock controlled by master.
 `uvm_info("iicSlaveStartBit", "finished doSCL", UVM_HIGH)
endtask

task iicSlaveStartBit::doSDA;
 `uvm_info("iicSlaveStartBit", "called doSDA", UVM_HIGH)
 forever begin
  //@(negedge m_iicIf.sda_in);
  wait(m_iicIf.sda_in==0);
  if (m_iicIf.scl_in==1)
    break;
  wait(m_iicIf.sda_in==1);
 end
 `uvm_info("iicSlaveStartBit", "finished doSDA", UVM_HIGH)
endtask


task iicSlaveStartBit::doRxBit;
 //nothing to receive for start bit.
endtask

task iicSlaveStartBit::detectStartCondition();
 //This bit is about detecting the START condition.
 wait(0);
endtask


task iicSlaveStartBit::detectStopCondition();
 //Can't happen here.
 wait(0);
endtask

function void iicSlaveStartBit::setTiming();
 super.setTiming();
 m_bitTimeout=0;
endfunction

