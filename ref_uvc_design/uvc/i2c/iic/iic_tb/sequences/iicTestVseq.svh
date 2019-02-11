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

class iicTestVseq extends iicBaseVseq;
 `uvm_object_utils(iicTestVseq)

 //// Methods
 //

 extern function new(string name = "iicTestVseq");
 extern virtual task body;
 extern virtual function void printSettings;
 extern virtual function void randomizeSequences;


 //// Data
 //

 //Randomised data
 rand iicBusSpeedType m_iicBusSpeed;
 rand ui  m_sclFrequencyXt;       //kHz
 rand ui  m_sclFrequencyDut;      //kHz
 rand ui  m_sclFrequencyDutSlave; //kHz
 rand iicSlaveAddress m_slaveAddressDevice1;
 rand iicSlaveAddress m_slaveAddressDevice2;

 // Non - randomized data

 //DUT and cross traffic vseqs.
 iicDutTrafficBaseVseq m_dutTrafficVseq;
 //iicTrafficBaseVseq m_xtTrafficVseq;

 //// Constraints
 // 

 constraint c_sclFrequencyXt {
  if (m_iicBusSpeed==slowSpeed) {
   m_sclFrequencyXt inside {[10:100]};
  } else {
   m_sclFrequencyXt inside {[101:400]};
  }
  solve m_iicBusSpeed before m_sclFrequencyXt;
 }

 constraint c_sclFrequencyDut {
  if (m_iicBusSpeed==slowSpeed) {
   m_sclFrequencyDut inside {[10:100]};
  } else {
   m_sclFrequencyDut inside {[101:400]};
  }
  solve m_iicBusSpeed before m_sclFrequencyDut;
 }

 constraint c_sclFrequencyDutSlave {
  if (m_iicBusSpeed==slowSpeed) {
   m_sclFrequencyDutSlave inside {[10:100]};
  } else {
   m_sclFrequencyDutSlave inside {[101:400]};
  }
  solve m_iicBusSpeed before m_sclFrequencyDutSlave;
 }

 constraint c_slaveAddressDevice2 {
  m_slaveAddressDevice2.m_slaveAddress != m_slaveAddressDevice1.m_slaveAddress;
  solve m_slaveAddressDevice1 before m_slaveAddressDevice2;
 }

endclass


function iicTestVseq::new(string name = "iicTestVseq");
 super.new(name);
 m_name = name;
endfunction



task iicTestVseq::body;

 super.body;

 printSettings;

 //Frequencies
 m_wb_agent_config.m_sclFrequency = m_sclFrequencyDut;                //DUT Master
 m_iic_agent3_config.m_iicIf.setBusFrequency(m_sclFrequencyDutSlave); //DUT Slave
 m_iic_agent1_config.m_iicIf.setBusFrequency(m_sclFrequencyXt);       //xT  Master
 m_iic_agent2_config.m_iicIf.setBusFrequency(m_sclFrequencyXt);       //xT  Slave

 //Map out which seuqences are available on which agent and which
 //slave addresses they should use.

 //DUT Master
 m_dutMasterSeqList = {"wbMasterTxFrameSeq","wbMasterRxFrameSeq"};
 m_dutSlaveAddressList}
 

 //Cross traffic sequnces
 m_xtMasterSeqList

 m_xtMasterSeqList  = {"iicMasterTxFrameSeq", "iicMaterRxFrameSeq"};



 //
 m_iic_agent1_config
 //Device addersses (iic bus slave addreses)
 //xT Master
 m_iic_agent1_config.m_iicIf.m_slaveAddressDevice1 = m_slaveAddressDevice1;
 m_iic_agent1_config.m_iicIf.m_slaveAddressDevice2 = m_slaveAddressDevice2;
 //xT Slave
 m_iic_agent2_config.m_iicIf.m_slaveAddress = m_slaveAddressDevice1;
 m_iic_agent2_config.m_iicIf.m_slaveAddressDevice2 = m_slaveAddressDevice2;
 
 //DUT Master
 m_wb_agent_config.m_slaveAddressDevice1 = m_slaveAddressDevice1;
 m_wb_agent_config.m_slaveAddressDevice2 = m_slaveAddressDevice2;
 //


 m_iic_agent2_config.m_iicIf.m_iicSlaveAddress = m_slaveAddressDevice1;
 m_iic_agent3_config.m_iicIf.m_iicSlaveAddress = m_slaveAddressDevice2;
 

 m_dutTrafficVseq =  iicDutTrafficBaseVseq::type_id::create("m_dutTrafficVseq");
 randomizeSequences;
 m_dutTrafficVseq.start(m_sequencer);

endtask


function void iicTestVseq::printSettings;
 $display(""); 
 $display("**** RANDOMISED SETTINGS iicBaseVseq");
 $display("m_iicBusSpeed           = %d",m_iicBusSpeed.name());
 $display("m_sclFrequencyXt        = %d",m_sclFrequencyXt);
 $display("m_sclFrequencyDut       = %d",m_sclFrequencyDut);
 $display("m_sclFrequencyDutSlave  = %d",m_sclFrequencyDutSlave);
 $display(""); 
endfunction


function void iicTestVseq::randomizeSequences;
 if (!m_dutTrafficVseq.randomize)
  `uvm_fatal(m_name, "Failed to randomize the DUT traffic vseq.")
endfunction
