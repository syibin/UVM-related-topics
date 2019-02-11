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

class iicSlaveRxFrameSeq extends iicFrameSeq;
 `uvm_object_utils(iicSlaveRxFrameSeq)

 typedef enum {START, ADDRESS, DATA, ACK} frameState_t;
 frameState_t m_frameState;

 extern function new(string name = "iicSlaveRxFrameSeq");
 extern virtual task body;

endclass


task iicSlaveRxFrameSeq::body;
 super.body;

 m_iicIf.frameType = "SlaveRX";

 `uvm_info(m_name, $psprintf("START iicSlaveRxFrameSeq. Length = %d",m_frameLength),UVM_LOW)

 forever begin

  if (m_startDetected) begin
   m_frameState = ADDRESS;
  end 

  if (m_stopDetected) begin
   m_frameState = START;
  end 

  case (m_frameState)
   START : begin
    m_iicIf.frameState = "START";
    sendBitSeq(m_iicSlaveStartSeq);
    m_frameState = ADDRESS;
   end
   ADDRESS : begin
    m_iicIf.frameState = "ADDRESS";
    sendBitSeq(m_iicSlaveRxByteSeq);
    if (m_iicSlaveRxByteSeq.m_byte[7:1]!=m_iicAddress) begin
     m_frameState = START;
    end else if (m_iicSlaveRxByteSeq.m_byte[0]!= 1'b0) begin
     m_frameState = START;
    end else begin
     m_frameState = ACK;
    end
   end
   DATA : begin
    m_iicIf.frameState = "DATA";
    sendBitSeq(m_iicSlaveRxByteSeq);      
    m_frameState = ACK;
    m_localSequencer.m_ap.write({1'b0,m_iicSlaveRxByteSeq.m_byte}); 
   end
   ACK : begin
    m_iicIf.frameState = "ACK";
    if ($urandom_range(100)<=m_ackProbability) begin
     //Send ACK
     m_iicSlaveTxBitSeq.m_iicBitTx = 1'b0;
     m_frameState = DATA;
     m_byteNumber++;
    end else begin
     //Send NACK
     m_iicSlaveTxBitSeq.m_iicBitTx = 1'b1; 
     m_frameState = START;
    end 
    sendBitSeq(m_iicSlaveTxBitSeq);
   end
   default : begin
    `uvm_fatal(m_name,"illegal state.")
   end
  endcase

 end

 `uvm_info(m_name, "FINISHED iicSlaveRxFrameSeq",UVM_LOW)

endtask

function iicSlaveRxFrameSeq::new(string name = "iicSlaveRxFrameSeq");
 super.new(name);
 m_name = name;
endfunction

