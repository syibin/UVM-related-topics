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

class iic_seq_item extends uvm_sequence_item;
 `uvm_object_utils(iic_seq_item)

 //Control
 iicBitType_t  m_bitType;
 bit           m_iicBitTx;
 bit           m_iicBitRx;
 ui            m_clockStretchingProbability   =0;
 //Status
 bit           m_stopDetected                 =0;
 bit           m_startDetected                =0;
 bit           m_arbitrationLost              =0;
 

 extern virtual function void do_copy (uvm_object rhs);

endclass


function void iic_seq_item::do_copy (uvm_object rhs);
 iic_seq_item originalItem;
 super.do_copy(rhs);
 if(rhs == null) return;
 if(!$cast(originalItem, rhs) ) return;

 m_iicBitTx                   = originalItem.m_iicBitTx;
 m_iicBitRx                   = originalItem.m_iicBitRx;
 m_bitType                    = originalItem.m_bitType;      
 m_stopDetected               = originalItem.m_stopDetected;
 m_startDetected              = originalItem.m_startDetected;
 m_arbitrationLost            = originalItem.m_arbitrationLost;
 m_clockStretchingProbability = originalItem.m_clockStretchingProbability;

endfunction
