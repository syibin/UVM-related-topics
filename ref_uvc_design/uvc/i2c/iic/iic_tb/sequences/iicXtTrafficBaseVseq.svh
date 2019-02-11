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


class iicXtTrafficBaseVseq extends iicTrafficBaseVseq;
 `uvm_object_utils(iicXtTrafficBaseVseq)

 //// Data
 //

  //Set by calling sequence
  iicFrameSeq           m_masterSeqsList[$];


  // Randomized data
 
  // Non - randomized data

  iicFrameSeq           m_iicMasterTxFrameSeq;
  iicFrameSeq           m_iicMasterRxFrameSeq;
  iicFrameSeq           m_masterSeq;
  ui                    m_interFrameDelay;

  bit                   m_relinquishBus=1;


 //// Methods
 //
 extern function new(string name = "iicXtTrafficBaseVseq");
 extern virtual task body;
 extern virtual function void randomizeSequences;

endclass

function iicXtTrafficBaseVseq::new(string name = "iicXtTrafficBaseVseq");
 super.new(name);
 m_name = name;
endfunction


task iicXtTrafficBaseVseq::body;
 super.body;

 for (m_frameNumber=0; m_frameNumber<m_numberOfFrames; m_frameNumber++) begin

  //Randomly select master sequence to run.
  m_masterSeq = m_masterSeqsList[$urandom_range(m_masterSeqsList.size()-1)];

  //Randomize the m_masterSeq sequence.
  randomizeSequences;
  m_masterSeq.start(m_xtMasterSequencer);

  m_interFrameDelay = $urandom_range(P_MAXINTERFRAMEDELAY_XT,P_MINTERFRAMEDELAY_XT);
  #(m_interFrameDelay*m_iic_agent1_config.m_iicIf.m_sclClockPeriod);
   

 end 
 
endtask


function void iicXtTrafficBaseVseq::randomizeSequences;

  //Randomize sequences and send.
  if (m_masterSeq==null)
   `uvm_fatal(m_name, "Null handle for master sequence.")
  if (m_frameNumber==m_numberOfFrames-1) begin
   if (!m_masterSeq.randomize() with {
                                    m_relinquishBus == 1;
                                    m_forceArbitrationEvent == 0;
                                     }
   )
   `uvm_fatal(m_name,"Failed to randomize master frame sequence.")
  end else begin
   if (!m_relinquishBus) begin
    //xT still owns the bus. Can't therfore wait for a DUT
    //frame to start in order to force arbitration.
    if (!m_masterSeq.randomize() with {
                                  m_forceArbitrationEvent == 0;
                                      }
    )
     `uvm_fatal(m_name,"Failed to randomize master frame sequence.")
   end else begin
    if (!m_masterSeq.randomize())
     `uvm_fatal(m_name,"Failed to randomize master frame sequence.")
   end
  end
  m_relinquishBus = m_masterSeq.m_relinquishBus;
endfunction


