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

class iicSlaveTxFrameSeq extends iicFrameSeq;
 `uvm_object_utils(iicSlaveTxFrameSeq)

 typedef enum {START, ADDRESS, DATA, ADDRESS_ACK, DATA_ACK} frameState_t;
 frameState_t m_frameState = START;

 extern function new(string name = "iicSlaveTxFrameSeq");
 extern virtual task body;

endclass

function iicSlaveTxFrameSeq::new(string name = "iicSlaveTxFrameSeq");
 super.new(name);
 m_name = name;
endfunction

task iicSlaveTxFrameSeq::body;
 super.body;

 m_iicIf.frameType = "SlaveTX";

 `uvm_info(m_name, $psprintf("FINISHED iicSlaveTxFrameSeq. Length = %d.",m_frameLength), UVM_LOW)


 forever begin

  if (m_startDetected) begin
   m_frameState = ADDRESS;
  end 

  if (m_stopDetected) begin
   m_frameState = START;
  end 

  case (m_frameState)
   START : begin
    m_byteNumber=0;
    m_iicIf.frameState = "START";
    sendBitSeq(m_iicSlaveStartSeq);
    m_frameState = ADDRESS;
   end
   ADDRESS : begin
    m_iicIf.frameState = "ADDRESS";
    sendBitSeq(m_iicSlaveRxByteSeq);
    if (m_iicSlaveRxByteSeq.m_byte[7:1]!=m_iicAddress) begin
     m_frameState = START;
    end else if (m_iicSlaveRxByteSeq.m_byte[0]!= 1'b1) begin
     m_frameState = START;
    end else begin
     //ACK address
     m_frameState = ADDRESS_ACK;
    end
   end
   DATA : begin
    m_iicIf.frameState = "DATA";
    m_iicSlaveTxByteSeq.m_byte = $urandom_range(255,0);
    //m_iicSlaveTxByteSeq.m_byte = m_frameData[m_byteNumber];
    sendBitSeq(m_iicSlaveTxByteSeq);
    m_frameState = DATA_ACK; 
    m_localSequencer.m_ap.write({1'b0,m_iicSlaveTxByteSeq.m_byte}); 
   end
   ADDRESS_ACK : begin
    //Slave (this seq.) ACKs or NACKs address.
    m_iicIf.frameState = "ADDRESS_ACK";
    if ($urandom_range(100)<=m_ackProbability) begin
     //Send ACK
     m_frameState = DATA;
     m_iicSlaveTxBitSeq.m_iicBitTx = 1'b0;
     m_byteNumber++;
    end else begin
     //Send NACK
     m_iicSlaveTxBitSeq.m_iicBitTx = 1'b1; 
     m_frameState = START;
    end 
    sendBitSeq(m_iicSlaveTxBitSeq);    
   end
   DATA_ACK : begin
    //Master ACKs or NACKS data.
    m_iicIf.frameState = "DATA_ACK";
    sendBitSeq(m_iicSlaveRxBitSeq);
    if (m_ack) begin
     m_frameState = START;
    end else begin
      m_frameState = DATA;
      m_byteNumber++;
    end
   end
   default : begin
    `uvm_fatal(m_name,"illegal state.")
   end
  endcase;

 end //forever

 `uvm_info(m_name, "FINISHED iicSlaveTxFrameSeq.", UVM_LOW)


endtask



