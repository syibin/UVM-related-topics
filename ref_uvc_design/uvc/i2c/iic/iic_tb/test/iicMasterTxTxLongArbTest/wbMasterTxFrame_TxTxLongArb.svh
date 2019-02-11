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

class wbMasterTxFrameSeq_TxTxLongArb extends wbMasterTxFrameSeq;
 `uvm_object_utils(wbMasterTxFrameSeq_TxTxLongArb)

 rand ui m_arbitrationPoint;

 extern function new(string name = "wbMasterTxFrameSeq_TxTxLongArb");

 constraint c_arbitrationPoint {
  m_arbitrationPoint < 11;
 }

 constraint c_frameData {
  foreach (m_frameData[i]) {
   if (i<m_arbitrationPoint)
    m_frameData[i] == 8'hff;
   else
    m_frameData[i] == 8'h00;   
  }
  solve m_arbitrationPoint before m_frameData;
 }

endclass

function wbMasterTxFrameSeq_TxTxLongArb::new(string name = "wbMasterTxFrameSeq_TxTxLongArb");
 super.new(name);
endfunction


