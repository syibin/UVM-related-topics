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


class iicDutTrafficBaseVseq extends iicTrafficBaseVseq;
 `uvm_object_utils(iicDutTrafficBaseVseq)

 //// Data
 //

  //Set by calling sequence
  wbFrameSeq           m_masterSeqsList[$];


  // Randomized data
 
  // Non - randomized data

  wbFrameSeq           m_wbMasterTxFrameSeq;
  wbFrameSeq           m_wbMasterRxFrameSeq;
  wbFrameSeq           m_masterSeq;
  ui                   m_interFrameDelay;


 //// Methods
 //
 extern function new(string name = "iicDutTrafficBaseVseq");
 extern virtual task body;
 extern virtual function void randomizeSequences;

endclass

function iicDutTrafficBaseVseq::new(string name = "iicDutTrafficBaseVseq");
 super.new(name);
 m_name = name;
endfunction


task iicDutTrafficBaseVseq::body;
 super.body;

 for (m_frameNumber=0; m_frameNumber<m_numberOfFrames; m_frameNumber++) begin

  //Randomly select master sequence to run.
  m_masterSeq = m_masterSeqsList[$urandom_range(m_masterSeqsList.size()-1)];

  //Randomize the m_masterSeq sequence.
  randomizeSequences;
  m_masterSeq.start(m_dutMasterSequencer);

  m_interFrameDelay = $urandom_range(P_MAXINTERFRAMEDELAY_DUT,P_MININTERFRAMEDELAY_DUT);
  #(m_interFrameDelay*m_iic_agent1_config.m_iicIf.m_sclClockPeriod);

 end 
 
endtask


function void iicDutTrafficBaseVseq::randomizeSequences;

  //Randomize sequences and send.
  if (m_masterSeq==null)
   `uvm_fatal(m_name, "Null handle for master sequence.")
  if (m_frameNumber==m_numberOfFrames-1) begin
   if (!m_masterSeq.randomize() with {
                                    m_relinquishBus == 1;
                                     }
   )
    `uvm_fatal(m_name,"Failed to randomize master frame sequence.")
  end else begin
   if (!m_masterSeq.randomize())
    `uvm_fatal(m_name,"Failed to randomize master frame sequence.")
  end
endfunction


