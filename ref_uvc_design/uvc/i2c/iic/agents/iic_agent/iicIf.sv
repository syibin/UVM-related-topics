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

interface iicIf;
 import uvm_pkg::*;
 import global_defs_pkg::*;
`include "uvm_macros.svh"
`include "iic_agent_global_defs.svh"

 //IIC interface signals
 logic scl_out;
 logic scl_in;
 logic sda_out;
 logic sda_in;
 logic hscs_en;   //high speed current source enable
 bit   busIsFree=1;
 logic rst;


 //Debug
 string iicByteName;
 string iicBitName;
 string arbitration;
 string frameType;
 string frameState;
 string debugStr4;

 //Timing 
 ui         m_sclFrequency;
 ui         m_sclClockPeriod;
 ui         m_fSclMin;
 ui         m_fSclMax;
 ui         m_fHdStaMin;
 ui         m_tLowMin;
 ui         m_tHighMin;
 ui         m_tSuStaMin;
 ui         m_tHdDatMin;
 ui         m_tHdDatMax;
 ui         m_tSuDatMin;
 ui         m_tSuStoMin;
 ui         m_tBufMin;
 ui         m_sclLowTime;     //ns
 ui         m_sclHighTime;    //ns
 ui         m_sdaChangePoint; //ns -Time after SCL low where SDA can change. 
 busSpeed_t m_speed;
 ui         m_bitTimeout = P_BITTIMEOUT; 

 function void setBusFrequency(ui sclFrequency);
  m_sclFrequency = sclFrequency; //in kHz
  if ( m_sclFrequency>0 && m_sclFrequency<=100 ) begin
   m_speed = slow_e; 
   setSlowSpeedTiming();
  end else if (m_sclFrequency>100 && m_sclFrequency<=400) begin
   m_speed = fast_e; 
   setFastSpeedTiming();
  end else if (m_sclFrequency>400 && m_sclFrequency<=3400) begin
   m_speed = high_e;
   setHighSpeedTiming();
  end else
  `uvm_fatal("iicBit", $psprintf("SCL frquency setting illegal : %d kHz",m_sclFrequency))

  //Create a SCL with 1:1 duty cycle
  m_sclLowTime     = ( 10 ** 6/(2 * m_sclFrequency) ) ; //ns
  m_sclHighTime    = m_sclLowTime;                      //ns
  //Default bit set-up time is m_sclLowTime/2
  m_sdaChangePoint = m_sclLowTime/2;                    //ns

  m_sclClockPeriod = ( (10**9)/m_sclFrequency) / 1000;  // ns

 endfunction

 always @(negedge sda_in )  begin
  //START condition
  if (rst==0)
   if (scl_in==1) begin
    #m_fHdStaMin;
    busIsFree<=0;
   end
 end
 always @(posedge sda_in) begin
  //STOP condition
  if (rst==0) begin
   if (scl_in==1) begin
    #m_tBufMin;
    busIsFree<=1;
   end
  end
 end

 
`include "iicBitTimingS.sv"
`include "iicBitTimingF.sv"
`include "iicBitTimingH.sv"

endinterface