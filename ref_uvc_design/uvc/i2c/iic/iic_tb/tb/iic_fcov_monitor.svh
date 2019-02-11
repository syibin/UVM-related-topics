////////////////////////////////////////////////////////////////////
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

module iic_fcov_monitor(input bit dut_scl_out,  input bit dut_sda_out, input bit scl, input bit sda,input bit clk , input bit rst);

 import global_defs_pkg::*;

 //Data
 logic[8:0] iicRxReg=0;
 logic[7:0] iicData=0;
 logic[6:0] iicAddress=0;
 ui         iicByteCnt;
 ui         iicBitCnt;

 //Frame Properties
 bit iicAck = 1;
 bit iicRwb = 0;

 always @(posedge scl) begin
  iicRxReg[8:1] <= iicRxReg[7:0];
  iicRxReg[0]   <= sda;
 end

//Helper tasks

 task incIicByteCnt;
  iicByteCnt++;
 endtask

 task rstIicByteCnt;
  iicByteCnt<=0;
 endtask

 task captureAddress;
  iicAddress <= iicRxReg[8:2];
  iicRwb     <= iicRxReg[1];
 endtask

 task captureData;
  iicData <= iicRxReg[8:1];
 endtask

 task sampleIicFrame;
  cg_iicAddress_inst.sample();
  if (iicRwb==1) begin
   cg_master_rx_inst.sample();
  end else begin
   cg_master_tx_inst.sample();
  end
 endtask

 task rstIicBitCnt;
  iicBitCnt = 0;
 endtask;

 task incIicBitCnt;
  iicBitCnt = (iicBitCnt+1)%9;
 endtask

 task sampleArb;
  if (iicRwb) begin
   cg_master_rx_arb_h.sample();
  end else begin
   cg_master_tx_arb_h.sample();
  end
 endtask

 task sampleNackThenStart;
  cg_nackThenStart_h.sample();
 endtask

 task sampleNackThenStop;
  cg_nackThenStop_h.sample();
 endtask

////////////////////
////Sequences
////////////////////

 sequence iicStartSeq;
  @(posedge clk) 
    ($fell(sda) ##0 scl);
 endsequence

 sequence iicDutStartSeq;
  @(posedge clk) 
    ($fell(dut_sda_out) ##0 dut_scl_out);
 endsequence

 sequence iicStopSeq;
  @(posedge clk) 
   ( ($rose(sda) ##0 scl) );
 endsequence

 sequence iicDutStopSeq;
  @(posedge clk) 
   ( ($rose(dut_sda_out) ##0 dut_scl_out) );
 endsequence


 sequence iicXtOnlyStartSeq;
  //Need the [*3] hold time because the TB causes
  //DUT and cross traffic STARTs to coincide.
  $fell(sda) ##1 (!sda&&scl&&dut_scl_out&&dut_sda_out) [*1:$] ##1 (!sda&&!scl&&dut_scl_out&&dut_sda_out) [*3]; 
 endsequence

 sequence iicXtOnlyStopSeq;
  dut_scl_out&&dut_sda_out&&!scl&&!sda ##1 (dut_scl_out&&dut_sda_out&&scl&&!sda) [*1:$] ##1 dut_scl_out&&dut_sda_out&&scl&&sda;
 endsequence


 sequence iicBitSeq;
  @(posedge clk) 
   !scl ##1 scl ##0 ( (sda [*1:$]) or (!sda[*1:$]) ) ##1 !scl ;
 endsequence 

 sequence iicByteSeq;
  @(posedge clk) 
  ##0 ( 1 [*1:$] ##0  iicBitSeq ) [*9] ;
 endsequence 

 //NACK sequence
 sequence nackSeq;
   ##1 1 [*1:$] ##0 $rose(scl) ##0 (iicByteCnt==0&&iicBitCnt==8&&sda&&scl) [*1:$] ##1 !scl;
 endsequence

 ////Frame 
 sequence iicDutFrameSeq;
  @(posedge clk) 
   ##0 first_match ( (iicByteSeq, captureAddress, incIicByteCnt) )
   ##0 ( first_match ( (iicByteSeq, captureData, incIicByteCnt) ) ) [*1:$]
   ##0 (((1[*1:$] ##0 iicDutStopSeq) or (1[*1:$] ##0 iicDutStartSeq)) );   
 endsequence


 ////Arbitration
 sequence iicArbCondSeq;
  @(posedge clk) 
  first_match(##1 1 [*1:$] ##0 $rose(scl) ##0 ( (!sda&&dut_sda_out&&iicBitCnt!=8) &&( (iicByteCnt==0) || (iicByteCnt>0&&iicRwb==0)  ) ) );
 endsequence


////////////////////
////Properties
////////////////////

///Bit count
 property rstIicBitCntProp;
  @(posedge clk) 
   iicStartSeq |-> (1, rstIicBitCnt);
 endproperty

 assert property (rstIicBitCntProp);

 property incIicBitCntProp;
  @(posedge clk) 
  first_match(iicBitSeq) |-> (1, incIicBitCnt);
 endproperty

 assert property (incIicBitCntProp);

 ////Byte count
 property rstByteCntProp;
  @(posedge clk) 
   iicDutStartSeq |-> (1, rstIicByteCnt);
 endproperty

 assert property (rstByteCntProp);


 //Frame Coverage
 property iicFrameProp;
  @(posedge clk) 
   iicDutStartSeq |=>   ( iicDutFrameSeq                                      , sampleIicFrame      )
                     or ( (nackSeq ##1 1[*1:$] ##0 iicDutStopSeq)             , sampleNackThenStop  )
                     or ( (nackSeq ##1 1[*1:$] ##0 iicDutStartSeq)            , sampleNackThenStart ) 
                     or ( iicArbCondSeq                                       , sampleArb           )
                     or ( 1 [*1:$] ##0 (iicStartSeq or iicStopSeq) );
 endproperty

 assert property (iicFrameProp);


////////////////////
////Covergroups
////////////////////

 covergroup cg_iicAddress;
  cp_rwb        : coverpoint iicRwb;
  cp_iicAddress : coverpoint {iicAddress, iicRwb}
  {
   bins generalCall        = {8'b0000_000_0};
   bins STARTByte          = {8'b0000_000_1};
   bins cbus               = {8'b0000_001_?};
   illegal_bins reserved1  = {8'b0000_010_?};  //Reserved for differnt bus format      
   illegal_bins reserved2  = {8'b0000_011_?};  //Reserved for future use.    
   bins hsMasterCode       = {8'b0000_1??_?}; 
   illegal_bins reserved3  = {8'b1111_1??_?};  //reserved for future use.
   bins tenBitAddressing   = {8'b1111_0??_?};
   bins sevenBitAddressing[10] = { [8'b0001_000_0:8'b1110_111_1] };
  }
 endgroup

 cg_iicAddress cg_iicAddress_inst = new;

 covergroup cg_master_tx;
  cp_iicAddress : coverpoint iicAddress 
  {
   illegal_bins reserved1          = {8'b0000_010};     //Reserved for differnt bus format      
   illegal_bins reserved2          = {8'b0000_011};     //Reserved for future use.    
   wildcard bins hsMasterCode      = {8'b0000_1??}; 
   wildcard illegal_bins reserved3 = {8'b1111_1??};    //reserved for future use.
   wildcard bins tenBitAddressing  = {8'b1111_0??};
   bins sevenBitAddressing[10]     = { [8'b0001_000:8'b1110_111] };
  }   
  cp_frameData   : coverpoint iicData;
  cp_frameLength : coverpoint iicByteCnt
  {
   bins shortest = {2};
   bins midle    = {[3:MAXFRAMELENGTH-2]};
   bins longest  = {MAXFRAMELENGTH-1};
  }    
 endgroup

 cg_master_tx cg_master_tx_inst = new;

 covergroup cg_master_rx;
  cp_iicAddress : coverpoint iicAddress 
  {
   illegal_bins reserved1          = {8'b0000_010};     //Reserved for differnt bus format      
   illegal_bins reserved2          = {8'b0000_011};     //Reserved for future use.    
   wildcard bins hsMasterCode      = {8'b0000_1??}; 
   wildcard illegal_bins reserved3 = {8'b1111_1??};    //reserved for future use.
   wildcard bins tenBitAddressing  = {8'b1111_0??};
   bins sevenBitAddressing[10]     = { [8'b0001_000:8'b1110_111] };
  }   
  cp_frameData   : coverpoint iicData;
  cp_frameLength : coverpoint iicByteCnt
  {
   bins shortest = {2};
   bins midle    = {[3:MAXFRAMELENGTH-2]};
   bins longest  = {MAXFRAMELENGTH-1};
  }    
 endgroup

 cg_master_rx cg_master_rx_inst = new;

 //Byte count at which DUT loses arbitration.
 covergroup cg_master_tx_arb;
  cp_arbitrationByte : coverpoint iicByteCnt
  {
   bins addressByte      = {0};                 
   bins firstDataByte    = {1};
   bins secondDataByte   = {2}; 
   bins thirdDataByte    = {3}; 
   bins fourthDataByte   = {4}; 
   bins fifthDataByte    = {5}; 
   bins sixthDataByte    = {6}; 
   bins seventhDataByte  = {7}; 
   bins eighthDataByte   = {8}; 
   bins ninthDataByte    = {9}; 
   bins tenthDataByte    = {10}; 
   bins otherDataByte    = {[11:MAXFRAMELENGTH-1]};
  }
 endgroup

 cg_master_tx_arb cg_master_tx_arb_h = new;

 //Byte count at which DUT loses arbitration.
 covergroup cg_master_rx_arb;
  cp_arbitrationByte : coverpoint iicByteCnt
  {
   bins addressByte      = {0};                 
   bins firstDataByte    = {1};
   bins secondDataByte   = {2}; 
   bins thirdDataByte    = {3}; 
   bins fourthDataByte   = {4}; 
   bins fifthDataByte    = {5}; 
   bins sixthDataByte    = {6}; 
   bins seventhDataByte  = {7}; 
   bins eighthDataByte   = {8}; 
   bins ninthDataByte    = {9}; 
   bins tenthDataByte    = {10}; 
   bins otherDataByte    = {[11:MAXFRAMELENGTH-1]};  
  }
 endgroup

 cg_master_rx_arb cg_master_rx_arb_h = new;


 ////////////////////
 ////Requirements &&  Protocol checks
 //////////////////////
 
 //DUT does not set its sda and scl lines low when the bus
 //is owned by another master.
 property waitUntilBusFreeProp;
  @(posedge clk) 
   iicXtOnlyStartSeq |-> dut_sda_out&&dut_scl_out [*1:$] ##0 iicXtOnlyStopSeq;
 endproperty

 assert property (waitUntilBusFreeProp);

 //When Master-TX receives NACK in address byte it can send a 
 //STOP or a Re-START.

 covergroup cg_nackThenStart;
  cp_nackThenStart : coverpoint 1'b1 {bins covered = {1,0};}
 endgroup

 cg_nackThenStart cg_nackThenStart_h = new;

 covergroup cg_nackThenStop;
  cp_nackThenStop : coverpoint 1'b1 {bins covered = {1,0};}
 endgroup

 cg_nackThenStop cg_nackThenStop_h = new;


 property withdrawWhenArbLostProp;
  @(posedge clk) 
   iicDutStartSeq |->    (iicArbCondSeq ##0 (dut_sda_out&&dut_scl_out) [*1:$] ##0 (iicXtOnlyStartSeq or iicXtOnlyStopSeq))
                      or ( ##1 1[*1:$] ##0 (iicDutStartSeq or iicDutStopSeq) );
 endproperty
 
 assert property (withdrawWhenArbLostProp);


endmodule

