////  Author: Carsten Thiele                                     ////
////          carsten.thiele@enquireservicesltd.co.uk            ////
////                                                             ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2011                                          ////
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

`include "iicIf.sv"

package iic_agent_pkg;

import uvm_pkg::*;
import global_defs_pkg::*;

`include "uvm_macros.svh"

`include "iic_agent_global_defs.svh"
`include "iic_agent_config.svh";

`include "iicSlaveAddress.svh"

//Bits
`include "bits/iicBit.svh"
`include "bits/iicMasterTxBit.svh"
`include "bits/iicMasterRxBit.svh"
`include "bits/iicMasterStartBit.svh"
`include "bits/iicMasterStopBit.svh"
`include "bits/iicSlaveStartBit.svh"
`include "bits/iicSlaveRxBit.svh"
`include "bits/iicSlaveTxBit.svh"
`include "bits/iicSlaveStopBit.svh"

//Driver, Sequencer
`include "iic_seq_item.svh"
`include "iic_driver_base.svh"
`include "iic_driver.svh"
`include "iic_sequencer.svh"
`include "iic_agent.svh"


endpackage