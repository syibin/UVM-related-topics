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

class iicFrameSeq extends uvm_sequence;
 `uvm_object_utils(iicFrameSeq)

 typedef enum {START, ADDRESS, DATA, ACK, STOP, FINISHED} frameState_t;
 frameState_t m_frameState = START;


  //Random properties
 rand bit[7:0]    m_frameData[MAXFRAMELENGTH];
 rand ui          m_frameLength;
 rand bit         m_relinquishBus; 
 rand ui          m_ackProbability;
 rand ui          m_clockStretchingProbability;
 rand bit         m_forceArbitrationEvent;
 rand ui          m_interFrameDelay;


 //Local properties
 bit[6:0]         m_iicAddress;        //!!Must be set by code that starts this sequence.
 iic_seq_item     m_iic_seq_item;
 iic_agent_config m_iic_agent_config;
 virtual iicIf    m_iicIf;
 ui               m_sclClockPeriod;
 string           m_name;
 ui               m_byteNumber;
 bit              m_stopDetected;    
 bit              m_startDetected;   
 bit              m_arbitrationLost; 
 bit              m_ack;     
 iic_sequencer    m_localSequencer;     

 //Sequences
 iicMasterStartSeq   m_iicMasterStartSeq;
 iicMasterStopSeq    m_iicMasterStopSeq;
 iicSlaveStartSeq    m_iicSlaveStartSeq;
 iicSlaveStopSeq     m_iicSlaveStopSeq;
 iicMasterTxBitSeq   m_iicMasterTxBitSeq;
 iicMasterRxBitSeq   m_iicMasterRxBitSeq;
 iicSlaveTxBitSeq    m_iicSlaveTxBitSeq;
 iicSlaveRxBitSeq    m_iicSlaveRxBitSeq;
 iicMasterTxByteSeq  m_iicMasterTxByteSeq;
 iicMasterRxByteSeq  m_iicMasterRxByteSeq;
 iicSlaveRxByteSeq   m_iicSlaveRxByteSeq;
 iicSlaveTxByteSeq   m_iicSlaveTxByteSeq;


 ////Constraints
 //
 constraint c_frameLength  {m_frameLength inside {[2:MAXFRAMELENGTH]}; }
 constraint c_ackProbability {m_ackProbability inside {[0:100]};} 
 constraint c_clockStretchingProbability {m_clockStretchingProbability inside {[0:100]};}
 constraint c_forceArbitrationEvent{
  m_forceArbitrationEvent dist {0 := P_ZEROARBMIX, 1 := P_ONEARBMIX };
 }


 /// Methods
 //
 
 extern function new(string name = "iicFrameSeq");
 extern virtual task body;
 extern virtual task sendBitSeq(iicBitSeq iicBitSeqToSend);

endclass

function iicFrameSeq::new(string name = "iicFrameSeq");
 super.new(name);
 m_name = name;
endfunction

task iicFrameSeq::body;
 //Sequencer for scoreboarding
 $cast(m_localSequencer, m_sequencer);

 //Create helper sequences
 m_iicMasterTxBitSeq = iicMasterTxBitSeq::type_id::create("m_iicMasterTxBitSeq");
 m_iicMasterRxBitSeq = iicMasterRxBitSeq::type_id::create("m_iicMasterRxBitSeq");
 m_iicSlaveTxBitSeq = iicSlaveTxBitSeq::type_id::create("m_iicSlaveTxBitSeq");
 m_iicSlaveRxBitSeq = iicSlaveRxBitSeq::type_id::create("m_iicSlaveRxBitSeq");
 //
 m_iicMasterStartSeq  = iicMasterStartSeq::type_id::create("m_iicMasterStartSeq");  
 m_iicMasterStopSeq   = iicMasterStopSeq::type_id::create("m_iicMasterStopSeq");  
 m_iicSlaveStartSeq   = iicSlaveStartSeq::type_id::create("m_iicSlaveStartSeq");
 m_iicSlaveStopSeq    = iicSlaveStopSeq::type_id::create("m_iicSlaveStopSeq");    
 //
 m_iicMasterTxByteSeq = iicMasterTxByteSeq::type_id::create("m_iicMasterTxByteSeq");
 m_iicMasterRxByteSeq = iicMasterRxByteSeq::type_id::create("m_iicMasterRxByteSeq");
 //
 m_iicSlaveRxByteSeq  = iicSlaveRxByteSeq::type_id::create("m_iicSlaveRxByteSeq");
 m_iicSlaveRxByteSeq.m_clockStretchingProbability = m_clockStretchingProbability;
 //
 m_iicSlaveTxByteSeq  = iicSlaveTxByteSeq::type_id::create("m_iicSlaveTxByteSeq");
 m_iicSlaveTxByteSeq.m_clockStretchingProbability = m_clockStretchingProbability;

 //Get config
 if (!uvm_config_db#(iic_agent_config)::get(m_sequencer, "", "iic_agent_config", m_iic_agent_config))
  `uvm_fatal(m_name, "Could not get handle for iic_agent_config.")
 m_iicIf          = m_iic_agent_config.m_iicIf;
 m_iic_seq_item   = iic_seq_item::type_id::create("m_iic_seq_item");
 m_sclClockPeriod = m_iicIf.m_sclClockPeriod; //in ns
 #10;
 wait(!m_iicIf.rst);

 //initialise
 m_byteNumber = 0;
 if (m_frameLength==0) begin
  m_iicIf.frameState = "FINISHED";
  return;
 end
 m_frameState = START;

endtask


task iicFrameSeq::sendBitSeq(iicBitSeq iicBitSeqToSend);
 iicBitSeqToSend.start(m_sequencer);
 m_stopDetected    = iicBitSeqToSend.m_stopDetected;
 m_startDetected   = iicBitSeqToSend.m_startDetected;
 m_arbitrationLost = iicBitSeqToSend.m_arbitrationLost;
 m_ack             = iicBitSeqToSend.m_ack;
endtask





