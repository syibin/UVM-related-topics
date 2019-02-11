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

class iic_driver_base extends uvm_driver#(iic_seq_item);

 `uvm_component_utils(iic_driver_base)

 uvm_analysis_port #(bit[7:0]) m_ap;

 string m_name;
 iicBit m_bit;
 virtual iicIf  m_iicIf;

 extern function new(string name = "iic_driver_base", uvm_component parent = null);
 extern task run_phase(uvm_phase phase);
 extern function void build_phase(uvm_phase phase);
 extern virtual function void createBit();

endclass

function iic_driver_base::new(string name = "iic_driver_base", uvm_component parent = null);
 super.new(name,parent);
 m_name = name;
endfunction

function void iic_driver_base::build_phase(uvm_phase phase);
 super.build_phase(phase);
 m_ap = new("m_ap", this);
endfunction


task iic_driver_base::run_phase(uvm_phase phase);

 m_iicIf.scl_out <= 1;
 m_iicIf.sda_out <= 1;

 forever begin
  seq_item_port.get_next_item(req);
  //Setup bit.
  createBit;
  m_bit.m_iicIf                            = m_iicIf;
  m_bit.m_iicBitTx                         = req.m_iicBitTx;
  m_bit.m_clockStretchingProbability       = req.m_clockStretchingProbability;
  //Do bit.
  m_bit.doBit();
  //Return status to sequence.
  req.m_iicBitRx                           = m_bit.m_iicBitRx;
  req.m_stopDetected                       = m_bit.m_stopDetected;
  req.m_startDetected                      = m_bit.m_startDetected;
  req.m_arbitrationLost                    = m_bit.m_arbitrationLost;
  seq_item_port.item_done();
 end

endtask

function void iic_driver_base::createBit();

 case (req.m_bitType)
  iicMasterStartBitType      : m_bit  = iicMasterStartBit::type_id::create("iicMasterStartBit");
  iicMasterStopBitType       : m_bit  = iicMasterStopBit::type_id::create("iicMasterStopBit");
  iicSlaveRxBitType          : m_bit  = iicSlaveRxBit::type_id::create("iicSlaveRxBit");
  iicSlaveTxBitType          : m_bit  = iicSlaveTxBit::type_id::create("iicSlaveTxBit");
  iicSlaveStartBitType       : m_bit  = iicSlaveStartBit::type_id::create("icSlaveStartBit");
  iicMasterTxBitType         : m_bit  = iicMasterTxBit::type_id::create("iicMasterTxBit");
  iicMasterRxBitType         : m_bit  = iicMasterRxBit::type_id::create("iicMasterRxBit");
  iicSlaveStopBitType        : m_bit  = iicSlaveStopBit::type_id::create("iicSlaveStopBit");
  default                    : `uvm_fatal(m_name, "unknown bit type.")
 endcase
 
endfunction





