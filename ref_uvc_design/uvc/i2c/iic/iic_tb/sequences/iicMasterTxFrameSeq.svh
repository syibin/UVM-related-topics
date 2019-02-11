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

class iicMasterTxFrameSeq extends iicMasterFrameSeq;
 `uvm_object_utils(iicMasterTxFrameSeq)

 extern function new(string name = "iicMasterTxFrameSeq");
 extern virtual task body;

endclass

function iicMasterTxFrameSeq::new(string name = "iicMasterTxFrameSeq");
 super.new(name);
 m_name = name;
endfunction

task iicMasterTxFrameSeq::body;
 super.body;

 `uvm_info(m_name, "Starting iicMasterTxFrameSeq.", UVM_LOW);

 m_iicIf.frameType = "MasterTX";

 wait(m_iicIf.busIsFree);

 m_byteNumber = 0;
 
 forever begin

  case (m_frameState)
   START : begin
    m_iicIf.frameState = "START";
    //m_iicMasterStartSeq.start(m_sequencer);  
    sendBitSeq(m_iicMasterStartSeq);
    m_frameState = ADDRESS;
   end
   ADDRESS : begin
    m_iicIf.frameState = "ADDRESS";
    m_iicMasterTxByteSeq.m_byte[7:1] = m_iicAddress;
    m_iicMasterTxByteSeq.m_byte[0]   = 1'b0; //write
    sendBitSeq(m_iicMasterTxByteSeq);
    if (m_startDetected||m_stopDetected)
     break;
    if (m_arbitrationLost) begin
     m_frameState = FINISHED;
    end else begin
     m_localSequencer.m_ap.write({1'b1,8'b0}); //reset SCBD
     m_frameState = ACK; 
    end
   end
   DATA : begin
    m_iicIf.frameState = "DATA";
    //m_iicMasterTxByteSeq.m_byte = $urandom_range(255,0);
    m_iicMasterTxByteSeq.m_byte = m_frameData[m_byteNumber];
    sendBitSeq(m_iicMasterTxByteSeq);
    if (m_startDetected||m_stopDetected)
     break;
    if (m_arbitrationLost) begin
     m_frameState = FINISHED;
    end else begin
     m_frameState = ACK; 
     m_localSequencer.m_ap.write({1'b0,m_iicMasterTxByteSeq.m_byte}); 
    end 
   end
   ACK : begin
    m_iicIf.frameState = "ACK";
    sendBitSeq(m_iicMasterRxBitSeq);
    if (m_startDetected||m_stopDetected)
     break;
    if (m_ack) begin
     m_frameState = STOP;
    end else if (m_byteNumber==m_frameLength-1) begin
     m_frameState = STOP;
    end else begin
     m_frameState = DATA;
     m_byteNumber++;
    end
   end
   STOP : begin
    m_iicIf.frameState = "STOP";
    if (m_relinquishBus) begin
     //Send STOP
     //If the frame is only one byte long and the slave sent
     //an ACK then we MUST send a STOP.
     m_iicMasterStopSeq.m_iicBitTx=1'b0;
    end else begin
     //End frame without STOP -> Restart
     m_iicIf.busIsFree <= 1'b1; //Otherwise the re-start frame can't start.
     m_iicMasterStopSeq.m_iicBitTx=1'b1;
    end
    sendBitSeq(m_iicMasterStopSeq);
    m_frameState = FINISHED;    
   end
   FINISHED : begin
    m_iicIf.frameState = "FINISHED";
    m_iicIf.scl_out <= 1'b1;
    m_iicIf.sda_out <= 1'b1;
    break;
   end
   default : begin
    `uvm_fatal(m_name,"illegal state.")
   end
  endcase;

 end //forever

 `uvm_info(m_name, "Finished iicMasterTxFrameSeq.", UVM_LOW);
 
endtask



