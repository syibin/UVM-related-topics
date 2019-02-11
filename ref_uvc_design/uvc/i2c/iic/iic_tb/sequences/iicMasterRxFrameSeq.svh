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

class iicMasterRxFrameSeq extends iicMasterFrameSeq;
 `uvm_object_utils(iicMasterRxFrameSeq)

 typedef enum {START, ADDRESS, DATA, ADDRESS_ACK, DATA_ACK, STOP, FINISHED} frameState_t;
 frameState_t m_frameState = START;

 extern function new(string name = "iicMasterRxFrameSeq");
 extern virtual task body;

endclass

function iicMasterRxFrameSeq::new(string name = "iicMasterRxFrameSeq");
 super.new(name);
 m_name = name;
endfunction

task iicMasterRxFrameSeq::body;
 super.body;

 m_iicIf.frameType = "MasterRx";

 m_frameState = START;

 wait(m_iicIf.busIsFree);

 `uvm_info(m_name, $psprintf("START iicMasterRxFrameSeq. Length = %d",m_frameLength),UVM_LOW)

 forever begin

  case (m_frameState)
   START : begin
    m_iicIf.frameState = "START"; //debug
    //m_iicMasterStartSeq.start(m_sequencer);  
    sendBitSeq(m_iicMasterStartSeq);
    m_frameState = ADDRESS;
   end 
   ADDRESS : begin
    m_iicIf.frameState = "ADDRESS";
    m_iicMasterTxByteSeq.m_byte[7:1] = m_iicAddress;
    m_iicMasterTxByteSeq.m_byte[0]   = 1'b1; //read
    sendBitSeq(m_iicMasterTxByteSeq);
    if (m_startDetected||m_stopDetected)
     break;
    if (m_arbitrationLost) begin
     m_frameState = FINISHED;
    end else begin
     m_frameState = ADDRESS_ACK; 
     m_localSequencer.m_ap.write({1'b1,8'b0}); //Reset SCBD
    end  
   end
   DATA : begin
    m_iicIf.frameState = "DATA";
    sendBitSeq(m_iicMasterRxByteSeq);
    if (m_startDetected||m_stopDetected)
     break;
    m_frameState = DATA_ACK; 
    m_localSequencer.m_ap.write({1'b0,m_iicMasterRxByteSeq.m_byte}); 
   end
   ADDRESS_ACK : begin
    m_iicIf.frameState = "ADDRESS_ACK";
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
   DATA_ACK : begin
    m_iicIf.frameState = "DATA_ACK";
    if (m_byteNumber==m_frameLength-1) begin 
     m_iicMasterTxBitSeq.m_iicBitTx = 1'b1;
     m_frameState = STOP;
    end else begin
     m_iicMasterTxBitSeq.m_iicBitTx = 1'b0;
     m_frameState = DATA;
    end
    sendBitSeq(m_iicMasterTxBitSeq);
    if (m_startDetected||m_stopDetected) begin
     break;
    end
    m_byteNumber++;
   end
   STOP : begin
    m_iicIf.frameState = "STOP"; //debug
    if (m_relinquishBus) begin
     //Send STOP
     //If the frame is only one byte long and the slave sent
     //an ACK then we MUST send a STOP.
     m_iicMasterStopSeq.m_iicBitTx=1'b0;
    end else begin
     //Rising edge on SDA when SCL == 1
     m_iicMasterStopSeq.m_iicBitTx=1'b1;
     m_iicIf.busIsFree <= 1'b1;  //Otherwise the re-start frame can't start.
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
  endcase

 end //forever

 `uvm_info(m_name, "FINISHED iicMasterRxFrameSeq",UVM_LOW)


endtask
