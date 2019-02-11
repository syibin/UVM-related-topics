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

class iicTest_MasterRx_Vseq extends iicTestBaseVseq;
 `uvm_object_utils(iicTest_MasterRx_Vseq)

 //// Methods
 //

 extern function new(string name = "iicTest_MasterRx_Vseq");
 extern virtual function void setupMasterSeqList;
 extern virtual function void randomizeSequences;

endclass


function iicTest_MasterRx_Vseq::new(string name = "iicTest_MasterRx_Vseq");
 super.new(name);
 m_name = name;
endfunction



function void iicTest_MasterRx_Vseq::randomizeSequences;

 if (!m_dutTrafficVseq.randomize with {m_numberOfFrames==1;}) 
  `uvm_fatal(m_name, "Failed to randomize the DUT traffic vseq.")

 if (!m_xtTrafficVseq.randomize with {m_numberOfFrames==1;}) 
  `uvm_fatal(m_name, "Failed to randomize the cross traffic vseq.")


 if (!m_iicSlaveTx1FrameSeq.randomize() with {
                                        m_relinquishBus==1;
                                        m_ackProbability==100;
                                        m_clockStretchingProbability==0;
                                            }
 )
 `uvm_fatal(m_name, "Failed to randomize m_iicSlaveTx1FrameSeq.")

 if (!m_iicSlaveTx2FrameSeq.randomize() with {
                                        m_relinquishBus==1;
                                        m_ackProbability==100;
                                        m_clockStretchingProbability==0;
                                            }
 )
 `uvm_fatal(m_name, "Failed to randomize m_iicSlaveTx2FrameSeq.")


 if (!m_iicSlaveRx1FrameSeq.randomize() with {
                                        m_relinquishBus==1;
                                        m_ackProbability==100;
                                        m_clockStretchingProbability==0;
                                            }
 )
 `uvm_fatal(m_name, "Failed to randomize m_iicSlaveRx1FrameSeq.") 

 if (!m_iicSlaveRx2FrameSeq.randomize() with {
                                        m_relinquishBus==1;
                                        m_ackProbability==100;
                                        m_clockStretchingProbability==0;
                                            }
 )
 `uvm_fatal(m_name, "Failed to randomize m_iicSlaveRx2FrameSeq.") 


endfunction



function void iicTest_MasterRx_Vseq::setupMasterSeqList;
 //DUT Master Sequence List
 m_dutMasterSeqsList.push_back(m_wbMasterRxFrameSeq);
 m_dutTrafficVseq.m_masterSeqsList = m_dutMasterSeqsList;
 //xT Master sequence list
 m_xtMasterSeqsList.push_back(m_iicMasterRxFrameSeq);
 m_xtTrafficVseq.m_masterSeqsList = m_xtMasterSeqsList;
 
endfunction

