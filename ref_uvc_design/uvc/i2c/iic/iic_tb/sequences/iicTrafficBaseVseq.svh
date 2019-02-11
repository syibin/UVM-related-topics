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

class frameData extends uvm_object;
 `uvm_object_utils(frameData)

  rand bit[7:0] m_data[MAXFRAMELENGTH];

endclass

virtual class iicTrafficBaseVseq extends iicBaseVseq;

 `uvm_object_utils(iicTrafficBaseVseq)

 //// Data
 //
 // Random data
 rand ui  m_numberOfFrames;

 // Non - randomised data

 ui          m_frameNumber;
 
 //// Methods
 //
 extern function new(string name = "iicTrafficBaseVseq");
 extern virtual task body;
 extern function void printSettings;


 //// Constraints
 //
 constraint c_numberOfFrames {m_numberOfFrames inside {[1:100]};}

endclass


function iicTrafficBaseVseq::new(string name = "iicTrafficBaseVseq");
 super.new(name);
 m_name = name;
endfunction

task iicTrafficBaseVseq::body;
 super.body;

 printSettings;

endtask


function void iicTrafficBaseVseq::printSettings;
 $display(""); 
 $display("**** RANDOMISED SETTINGS %s",m_name);
 $display("m_numberOfFrames      = %d",m_numberOfFrames);
 $display(""); 
endfunction

