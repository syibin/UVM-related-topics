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

package iic_test_pkg;
 import uvm_pkg::*;
 `include "uvm_macros.svh"

 import global_defs_pkg::*;
 import iic_agent_pkg::*;
 import wb_agent_pkg::*;
 import iic_env_pkg::*;
 import wb_seq_pkg::*;
 import iic_seq_pkg::*;
 import iic_vseq_pkg::*;

 `include "iic_test_base.svh"

 //Pipe cleaner test.
 `include "iicPcTest/iicPcTest.svh"

 //Master TX test
 `include "iicMasterTxTest/iicTest_MasterTx_Vseq.svh"
 `include "iicMasterTxTest/iicXtTraffic_MasterTx_Vseq.svh"
 `include "iicMasterTxTest/iicDutTraffic_MasterTx_Vseq.svh"
 `include "iicMasterTxTest/iicMasterTxTest.svh"

 //Master RX test
  `include "iicMasterRxTest/iicTest_MasterRx_Vseq.svh"
  `include "iicMasterRxTest/iicXtTraffic_MasterRx_Vseq.svh"
  `include "iicMasterRxTest/iicDutTraffic_MasterRx_Vseq.svh"
  `include "iicMasterRxTest/iicMasterRxTest.svh"

 //Master Tx vs Master Tx arbitration test
  `include "iicMasterTxTxArbTest/iicTest_MasterTxTxArb_Vseq.svh"
  `include "iicMasterTxTxArbTest/iicXtTraffic_MasterTxTxArb_Vseq.svh"
  `include "iicMasterTxTxArbTest/iicDutTraffic_MasterTxTxArb_Vseq.svh"
  `include "iicMasterTxTxArbTest/iicMasterTxTxArbTest.svh"

 //Master Tx vs Master Tx arbitration test
  `include "iicMasterTxTxLongArbTest/iicMasterTxFrameSeq_TxTxLongArb.svh"
  `include "iicMasterTxTxLongArbTest/wbMasterTxFrame_TxTxLongArb.svh"
  `include "iicMasterTxTxLongArbTest/iicTest_MasterTxTxLongArb_Vseq.svh"
  `include "iicMasterTxTxLongArbTest/iicXtTraffic_MasterTxTxLongArb_Vseq.svh"
  `include "iicMasterTxTxLongArbTest/iicDutTraffic_MasterTxTxLongArb_Vseq.svh"
  `include "iicMasterTxTxLongArbTest/iicMasterTxTxLongArbTest.svh"

 //Master Tx vs Master Rx arbitration test
  `include "iicMasterTxRxArbTest/iicTest_MasterTxRxArb_Vseq.svh"
  `include "iicMasterTxRxArbTest/iicXtTraffic_MasterTxRxArb_Vseq.svh"
  `include "iicMasterTxRxArbTest/iicDutTraffic_MasterTxRxArb_Vseq.svh"
  `include "iicMasterTxRxArbTest/iicMasterTxRxArbTest.svh"

 //Master Rx vs Master Tx arbitration test
  `include "iicMasterRxTxArbTest/iicTest_MasterRxTxArb_Vseq.svh"
  `include "iicMasterRxTxArbTest/iicXtTraffic_MasterRxTxArb_Vseq.svh"
  `include "iicMasterRxTxArbTest/iicDutTraffic_MasterRxTxArb_Vseq.svh"
  `include "iicMasterRxTxArbTest/iicMasterRxTxArbTest.svh"

 //Master Rx vs Master Rx arbitration test
  `include "iicMasterRxRxArbTest/iicTest_MasterRxRxArb_Vseq.svh"
  `include "iicMasterRxRxArbTest/iicXtTraffic_MasterRxRxArb_Vseq.svh"
  `include "iicMasterRxRxArbTest/iicDutTraffic_MasterRxRxArb_Vseq.svh"
  `include "iicMasterRxRxArbTest/iicMasterRxRxArbTest.svh"

 //Master Rx vs Master Rx arbitration test with both Masters always
 //addressing the same slave.
  `include "iicMasterRxRxSameAddressArbTest/iicMasterRxRxSameAddressArbTest.svh" 



endpackage
