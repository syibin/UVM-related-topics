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

class wbFrameSeq extends uvm_sequence#(wb_seq_item);
 `uvm_object_utils(wbFrameSeq)

`define PRERlo_REG_ADDR    3'h0
`define PRERhi_REG_ADDR    3'h1
`define CTR_REG_ADDR       3'h2
`define TXR_REG_ADDR       3'h3
`define RXR_REG_ADDR       3'h3
`define CR_REG_ADDR        3'h4
`define SR_REG_ADDR        3'h4

 typedef enum {START, ADDRESS, DATA, ACK, STOP, FINISHED} frameState_t;
 frameState_t m_frameState;

 //// Data
 //

 // Randomized data
 rand bit[7:0]        m_frameData[MAXFRAMELENGTH];
 rand ui              m_frameLength;
 rand bit             m_relinquishBus;


 //Non randomized data
 bit[6:0]        m_iicAddress ; //!!Must be set by code that starts this sequence.
 wb_seq_item     m_wb_seq_item;
 ui              m_byteNumber;
 string          m_name;
 bit[7:0]        m_data;
 bit             m_ack;
 bit[7:0]        m_status=0;
 bit[15:0]       m_prescale;
 wb_agent_config m_wb_agent_config;
 virtual wbIf    m_wbIf;
 ui              m_wbFrequency;
 ui              m_sclFrequency;
 static bit      m_dutInitialised = 0;
 bit             m_arbitrationLost=0;

 wb_sequencer    m_localSequencer;        


 extern function new(string name = "wbFrameSeq");
 extern task body;
 extern virtual task setupDut;
 extern virtual task sendStart;
 extern virtual task sendAddress(bit rwb);
 extern virtual task sendStop;
 extern virtual task sendData;
 extern virtual task rcvDataAck;
 extern virtual task rcvDataNack;
 extern virtual task waitInterrupt;

 ////Constraints
 //
 constraint c_frameLength  {m_frameLength inside {[2:MAXFRAMELENGTH]}; }

endclass

function wbFrameSeq::new(string name = "wbFrameSeq");
 super.new(name); 
 m_name = name;
endfunction


task wbFrameSeq::body;
 //Sequencer handle for scoreboarding.
 $cast(m_localSequencer, m_sequencer);

 //Get config
 if (!uvm_config_db#(wb_agent_config)::get(m_sequencer, "", "wb_agent_config", m_wb_agent_config))
  `uvm_fatal(m_name, "Could not get handle for wb_agent_config.")
 m_wbIf = m_wb_agent_config.m_wbIf;
 
 m_wbFrequency  = m_wb_agent_config.m_wbFrequency;  //kHz
 m_sclFrequency = m_wb_agent_config.m_sclFrequency;  //kHz 

 m_wb_seq_item = wb_seq_item::type_id::create("m_wb_seq_item");
 if (!m_dutInitialised)
  setupDut;

 m_byteNumber = 0;
 if (m_frameLength==0) begin
  m_wbIf.frameState = "FINISHED";
  return;
 end
 m_frameState = START;

endtask

task wbFrameSeq::setupDut;

 `uvm_info(m_name, "Wishbone setupDut.", UVM_LOW)

 m_wbIf.comment = "setupDut";

 //Wait for end of reset.
 wait(!m_wbIf.rst);
 repeat(10) @(posedge m_wbIf.clk);

 //Clock pre-scaler.

 if (m_sclFrequency==0)
  `uvm_fatal(m_name, "m_sclFrequence is 0.")
 
 m_prescale      = (m_wbFrequency*10**3) / (5*m_sclFrequency*10**3) - 1;
 m_wb_seq_item.txn_type  = WRITE;
 //Write low byte
 m_wb_seq_item.addr      = `PRERlo_REG_ADDR;
 m_wb_seq_item.data      = m_prescale[7:0];
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 
 repeat(1) @(posedge m_wbIf.clk);
 //Write high byte
 m_wb_seq_item.addr      = `PRERhi_REG_ADDR;
 m_wb_seq_item.data      = m_prescale[15:8];
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 
 repeat(1) @(posedge m_wbIf.clk);

 //Enable device
 m_wb_seq_item.txn_type  = WRITE;
 m_wb_seq_item.addr     = `CTR_REG_ADDR;
 m_wb_seq_item.data      = 8'h0;
 m_wb_seq_item.data[7]   = 1'b1; //Enable core
 m_wb_seq_item.data[6]   = 1'b1; //Enable interrupt
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 
 repeat(1) @(posedge m_wbIf.clk);

 m_dutInitialised = 1;

endtask

task wbFrameSeq::waitInterrupt;
 m_wbIf.comment = "waitInterrupt";

 wait(m_wbIf.inta);

 //Read Status Register
 m_wb_seq_item.addr      = `SR_REG_ADDR;
 m_wb_seq_item.txn_type  = READ; 
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 
 m_status                = m_wb_seq_item.data;
 m_ack                   = m_wb_seq_item.data[7];
 m_arbitrationLost       = m_wb_seq_item.data[5];

 //Clear interrupt
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE; 
 m_wb_seq_item.data      = 8'h0;
 m_wb_seq_item.data[0]   = 1'b1;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 

 wait(!m_wbIf.inta);

endtask

task wbFrameSeq::sendStart;
 `uvm_info(m_name, "Wishbone sendStart.", UVM_LOW)

 m_wbIf.comment = "sendStart";

 //Set WR and STA bits
 m_wb_seq_item.data = 8'h0;
 m_wb_seq_item.data[7] = 1'b1; //STA
 m_wb_seq_item.data[4] = 1'b1; //WR
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 m_wbIf.comment = "";

endtask

task wbFrameSeq::sendAddress(bit rwb);
 `uvm_info(m_name, "Start wishbone sendAddress.", UVM_LOW)

 m_wbIf.comment = "sendAddress";
 m_wbIf.data    = $psprintf("%h",{m_iicAddress,rwb});

 //Write slave address to Transmit Register
 m_wb_seq_item.data[7:1] = m_iicAddress;
 m_wb_seq_item.data[0]   = rwb;
 m_data                  = m_wb_seq_item.data;
 m_wb_seq_item.addr      = `TXR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 //Set WR and STA bits
 m_wb_seq_item.data = 8'h0;
 m_wb_seq_item.data[7] = 1'b1; //STA
 m_wb_seq_item.data[4] = 1'b1; //WR
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 waitInterrupt;  //Also reads status register.

 m_wbIf.comment = "";

 `uvm_info(m_name, "Finished wishbone sendAddress.", UVM_LOW)

endtask

task wbFrameSeq::sendData;

 `uvm_info(m_name, "Wishbone sendData.", UVM_LOW)

 m_wbIf.comment = "sendData";
 m_wbIf.data    = $psprintf("%h",m_wb_seq_item.data);

 m_data                  = m_wb_seq_item.data;
 m_wb_seq_item.addr      = `TXR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE; 
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item); 

 //Set WR bits
 m_wb_seq_item.data      = 8'h0;
 m_wb_seq_item.data[4]   = 1'b1; //WR
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 waitInterrupt; //Also reads status register.

 m_wbIf.comment = "";

endtask

task wbFrameSeq::sendStop;

 `uvm_info(m_name, "Wishbone sendStop.", UVM_LOW)

 m_wbIf.comment = "sendStop";
 //m_wbIf.data    = $psprintf("%h",m_wb_seq_item.data);

 //m_data                  = m_wb_seq_item.data;
 //m_wb_seq_item.addr      = `TXR_REG_ADDR;
 //m_wb_seq_item.txn_type  = WRITE; 
 //start_item(m_wb_seq_item);
 //finish_item(m_wb_seq_item); 

 m_wb_seq_item.data = 8'h0;
 m_wb_seq_item.data[6] = 1'b1; //STO
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);


 waitInterrupt;  //Also reads status register.

endtask


task wbFrameSeq::rcvDataNack;
 m_wb_seq_item.data = 8'h0;
 m_wb_seq_item.data[5] = 1'b1; //RD
 m_wb_seq_item.data[3] = 1'b1; //NACK
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 waitInterrupt; //Also reads status register.

 //Read data received.
 m_wb_seq_item.addr      = `RXR_REG_ADDR;
 m_wb_seq_item.txn_type  = READ; 
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 m_wbIf.comment = "";

endtask


task wbFrameSeq::rcvDataAck;
 m_wb_seq_item.data = 8'h0;
 m_wb_seq_item.data[5] = 1'b1; //RD
 m_wb_seq_item.data[3] = 1'b0; //ACK
 m_wb_seq_item.addr      = `CR_REG_ADDR;
 m_wb_seq_item.txn_type  = WRITE;
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 waitInterrupt; //Also reads status register.

 //Read data received.
 m_wb_seq_item.addr      = `RXR_REG_ADDR;
 m_wb_seq_item.txn_type  = READ; 
 start_item(m_wb_seq_item);
 finish_item(m_wb_seq_item);

 m_wbIf.comment = "";

endtask





