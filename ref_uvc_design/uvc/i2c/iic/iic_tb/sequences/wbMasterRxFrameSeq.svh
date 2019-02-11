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

class wbMasterRxFrameSeq extends wbFrameSeq;
 `uvm_object_utils(wbMasterRxFrameSeq)

 extern function new(string name = "wbMasterRxFrameSeq");
 extern task body;

endclass

function wbMasterRxFrameSeq::new(string name = "wbMasterRxFrameSeq");
 super.new(name);
endfunction

task wbMasterRxFrameSeq::body;
 super.body;

 m_wbIf.frameType = "Master RX";

 forever begin

  case (m_frameState) 
   START : begin
    //m_wbIf.frameState = "START";
    //sendStart;
    //m_frameState = ADDRESS;
    m_frameState = ADDRESS;
   end
   ADDRESS : begin
    m_wbIf.frameState = "ADDRESS";
    sendAddress(.rwb(1'b1)); //RD
    if (m_arbitrationLost) begin
     m_frameState = FINISHED;
    end else if (m_ack || m_frameLength==1) begin
     m_frameState = STOP;
    end else begin
     m_localSequencer.m_ap.write({1'b1,8'b0}); 
     m_frameState = DATA;
     m_byteNumber++;
    end
   end
   DATA : begin
    m_wbIf.frameState = "DATA";
    if(m_byteNumber==m_frameLength-1) begin
     rcvDataNack;
     m_frameState = STOP;
    end else begin
     rcvDataAck;
     m_byteNumber++;
    end  
    m_localSequencer.m_ap.write({1'b0,m_wb_seq_item.data}); 
   end
   ACK : begin
    //Note used
    `uvm_fatal(m_name,"illegal state : ACK.")   
   end
   STOP : begin
    m_wbIf.frameState = "STOP";
    if (m_relinquishBus) begin
     //Send STOP
     //If the frame is only one byte long and the slave sent
     //an ACK then we MUST send a STOP.
     sendStop;
    end 
    m_frameState = FINISHED;    
   end
   FINISHED : begin
    m_wbIf.frameState = "FINISHED";
    break;
   end
   default : begin
    `uvm_fatal(m_name,"illegal state.")
   end 
  endcase

 end //forever

 m_wbIf.comment = "FINISHED";

endtask

