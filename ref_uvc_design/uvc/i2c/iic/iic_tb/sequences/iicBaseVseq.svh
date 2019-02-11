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

class iicBaseVseq extends uvm_sequence;
 `uvm_object_utils(iicBaseVseq) 

 //// Methods
 //

 extern function new(string name = "iicBaseVseq");
 extern virtual task body;
 //extern virtual function void printSettings;
 extern virtual function void get_sequencers;

 //// Data
 //

 // Non - randomized data

 //Agents' Sequencers
 iic_sequencer m_xtMasterSequencer;
 iic_sequencer m_device1Sequencer;
 iic_sequencer m_device2Sequencer;
 iic_sequencer m_device3Sequencer;
 iic_sequencer m_device4Sequencer;
 wb_sequencer  m_dutMasterSequencer;

 //Agents' configs
 iic_agent_config     m_iic_agent1_config;
 iic_agent_config     m_iic_agent2_config;
 iic_agent_config     m_iic_agent3_config;
 iic_agent_config     m_iic_agent4_config;
 iic_agent_config     m_iic_agent5_config;
 wb_agent_config      m_wb_agent_config;

 string               m_name;

endclass


function iicBaseVseq::new(string name = "iicBaseVseq");
 super.new(name);
 m_name = name;
endfunction


task iicBaseVseq::body;

 get_sequencers();

 if (!uvm_config_db#(iic_agent_config)::get(m_xtMasterSequencer,"", "iic_agent_config", m_iic_agent1_config))
  `uvm_fatal(m_name,"Could not get handle to iic_agent1_config.")  

 if (!uvm_config_db#(iic_agent_config)::get(m_device1Sequencer,"", "iic_agent_config", m_iic_agent2_config))
  `uvm_fatal(m_name,"Could not get handle to iic_agent2_config.")

 if (!uvm_config_db#(iic_agent_config)::get(m_device2Sequencer,"", "iic_agent_config", m_iic_agent3_config))
  `uvm_fatal(m_name,"Could not get handle to iic_agent3_config.")

 if (!uvm_config_db#(iic_agent_config)::get(m_device3Sequencer,"", "iic_agent_config", m_iic_agent4_config))
  `uvm_fatal(m_name,"Could not get handle to iic_agent4_config.")

 if (!uvm_config_db#(iic_agent_config)::get(m_device4Sequencer,"", "iic_agent_config", m_iic_agent5_config))
  `uvm_fatal(m_name,"Could not get handle to iic_agent5_config.")

 if (!uvm_config_db#(wb_agent_config)::get(m_dutMasterSequencer,"", "wb_agent_config", m_wb_agent_config))
  `uvm_fatal(m_name,"Could not get handle to wb_agent_config.") 
 
endtask


function void iicBaseVseq::get_sequencers();
 //Code nicked from Mentor's UVM cookbook.

 uvm_component tmp[$];

 //find the IIC device1 sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_iic_agent1.m_iic_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find iic device1 sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device1 sequencer")
 else
  $cast(m_xtMasterSequencer, tmp[0]);

 //find the IIC device2 sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_iic_agent2.m_iic_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find iic device2 sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device2 sequencer")
 else
  $cast(m_device1Sequencer, tmp[0]);

 //find the IIC device3 sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_iic_agent3.m_iic_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find iic device3 sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device3 sequencer")
 else
  $cast(m_device2Sequencer, tmp[0]);

 //find the IIC device4 sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_iic_agent4.m_iic_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find iic device4 sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device4 sequencer")
 else
  $cast(m_device3Sequencer, tmp[0]);

 //find the IIC device5 sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_iic_agent5.m_iic_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find iic device5 sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device5 sequencer")
 else
  $cast(m_device4Sequencer, tmp[0]);

 //find the wishbone  sequencer in the testbench
 tmp.delete(); //Make sure the queue is empty
 uvm_top.find_all("*m_wb_agent.m_wb_sequencer", tmp);
 if (tmp.size() == 0)
  `uvm_fatal(m_name, "Failed to find wishbone sequencer")
 else if (tmp.size() > 1)
  `uvm_fatal(m_name, "Matched too many components when looking for iic device2 sequencer")
 else
  $cast(m_dutMasterSequencer, tmp[0]);

endfunction





