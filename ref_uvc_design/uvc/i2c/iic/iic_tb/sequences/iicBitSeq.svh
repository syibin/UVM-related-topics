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

class iicBitSeq extends uvm_sequence#(iic_seq_item);
 `uvm_object_utils(iicBitSeq)

 string        m_name;

 //Bit Control
 iicBitType_t  bitType;
 bit           m_iicBitTx;
 bit           m_iicBitRx;
 bit           m_ack;
 ui            m_clockStretchingProbability   =0;
 //Bit Control and Status
 //Bit Status
 bit           m_stopDetected                 =0;
 bit           m_startDetected                =0;
 bit           m_arbitrationLost              =0;

 //Bit
 bit[7:0]      m_byte;
 iic_seq_item  m_iic_seq_item; 

 extern function new(string name = "iicBitSeq");
 extern task sendSeqItem;
 extern virtual task body;

endclass

function iicBitSeq::new(string name = "iicBitSeq");
 super.new(name);
 m_name = name;
endfunction

task iicBitSeq::body;
 m_iic_seq_item   = iic_seq_item::type_id::create("m_iic_seq_item");
 m_iic_seq_item.m_clockStretchingProbability = m_clockStretchingProbability; 
endtask

task iicBitSeq::sendSeqItem;
 start_item(m_iic_seq_item);
 finish_item(m_iic_seq_item);
 m_stopDetected    = m_iic_seq_item.m_stopDetected;
 m_startDetected   = m_iic_seq_item.m_startDetected;
 m_arbitrationLost = m_iic_seq_item.m_arbitrationLost;
 m_iicBitRx        = m_iic_seq_item.m_iicBitRx;
 m_iicBitTx        = m_iic_seq_item.m_iicBitTx;
 m_ack             = m_iic_seq_item.m_iicBitRx;
endtask
