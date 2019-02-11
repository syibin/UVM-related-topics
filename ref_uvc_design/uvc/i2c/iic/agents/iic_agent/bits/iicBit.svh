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


virtual class iicBit extends uvm_object;

 `uvm_object_utils(iicBit)


 //Parameters that must be set by the class that create the iicBit
 virtual iicIf   m_iicIf;
 bit             m_startDetected                   = 0;
 bit             m_stopDetected                    = 0;
 bit             m_arbitrationLost                 = 0;
 ui              m_clockStretchingProbability      = 0;

 
 //Internal variables.
 ui              m_clockStretchDelta; //ns
 ui              m_sclFrequency;   //kHz
 ui              m_fSclMin;        //ns
 ui              m_fSclMax;        //ns
 ui              m_fHdStaMin;      //ns
 ui              m_tLowMin;        //ns
 ui              m_tHighMin;       //ns
 ui              m_tSuStaMin;      //ns
 ui              m_tHdDatMin;      //ns
 ui              m_tHdDatMax;      //ns
 ui              m_tSuDatMin;      //ns
 ui              m_tSuStoMin;      //ns
 ui              m_tBufMin;        //ns
 ui              m_sclLowTime;     //ns
 ui              m_sclHighTime;    //ns
 ui              m_sdaChangePoint; //ns -Time after SCL low where SDA can change. 
 ui              m_bitTimeout;
 bit             m_iicBitTx;    
 bit             m_iicBitRx;
 string          m_name;
 busSpeed_t      m_speed;




 extern function new(string name = "iicBit");
 extern virtual function void setTiming();
 extern virtual task doBit();
 extern virtual task doRxBit();
 extern virtual task detectStartCondition();
 extern virtual task detectStopCondition();

 pure virtual task doSCL();
 pure virtual task doSDA(); 

endclass


function iicBit::new( string name = "iicBit");
 super.new(name);

 //m_iicBitRx=1;  //Pass by default.
 //m_iicBitTx=1; 

 m_name = name;

endfunction

task iicBit::doBit();
 `uvm_info(m_name, "called doBit", UVM_HIGH)

 m_iicIf.scl_out              <= 1;
 m_iicIf.sda_out              <= 1;
 m_iicIf.hscs_en              <= 1;

 m_iicIf.iicBitName = m_name;

 setTiming();

 //action
 fork
  begin
   if (m_bitTimeout != 0) begin
    #m_bitTimeout;
    `uvm_fatal(m_name, "Bit timeout"); 
   end else begin
    wait(0);
   end
  end
  detectStartCondition();
  detectStopCondition();
  fork
   doSCL(); 
   doSDA(); 
   doRxBit();
  join
 join_any
 disable fork;

 `uvm_info(m_name, "finished doBit", UVM_HIGH)

endtask

function void iicBit::setTiming;

 //setup
 m_sclFrequency    = m_iicIf.m_sclFrequency;
 m_bitTimeout      = m_iicIf.m_bitTimeout;

 m_sclFrequency    = m_iicIf.m_sclFrequency;  
 m_fSclMin         = m_iicIf.m_fSclMin;       
 m_fSclMax         = m_iicIf.m_fSclMax;       
 m_fHdStaMin       = m_iicIf.m_fHdStaMin;     
 m_tLowMin         = m_iicIf.m_tLowMin;       
 m_tHighMin        = m_iicIf.m_tHighMin;      
 m_tSuStaMin       = m_iicIf.m_tSuStaMin;     
 m_tHdDatMin       = m_iicIf.m_tHdDatMin;     
 m_tHdDatMax       = m_iicIf.m_tHdDatMax;     
 m_tSuDatMin       = m_iicIf.m_tSuDatMin;     
 m_tSuStoMin       = m_iicIf.m_tSuStoMin;     
 m_tBufMin         = m_iicIf.m_tBufMin;       
 m_sclLowTime      = m_iicIf.m_sclLowTime;    
 m_sclHighTime     = m_iicIf.m_sclHighTime;   
 m_sdaChangePoint  = m_iicIf.m_sdaChangePoint; 
 m_bitTimeout      = m_iicIf.m_bitTimeout;


 assert(m_clockStretchingProbability<=100) else
  `uvm_fatal(m_name, $psprintf("m_clockStretchingProbability must be between 0 and 100. Actual value = %d",m_clockStretchingProbability))
 m_clockStretchDelta = ($urandom_range(100)<m_clockStretchingProbability) 
                       ? $urandom_range(P_CLOCKSTRETCHFACTOR*m_sclLowTime)
                       : 0;

endfunction


task iicBit::doRxBit();
 `uvm_info(m_name, "called doRxBit", UVM_HIGH)
 @(posedge m_iicIf.scl_in);
 m_iicBitRx = m_iicIf.sda_in;
 `uvm_info(m_name, "finished doRxBit", UVM_HIGH)
endtask

task iicBit::detectStopCondition;
 forever begin
  @(posedge m_iicIf.sda_in);
  if (m_iicIf.scl_in==1) begin
   `uvm_info(m_name, "STOP detected", UVM_HIGH);
   m_stopDetected=1;
   break;
  end   
 end
endtask

task iicBit::detectStartCondition;
 forever begin
  @(negedge m_iicIf.sda_in);
  if (m_iicIf.scl_in==1) begin
   `uvm_info(m_name, "START/Repeat-START detected", UVM_HIGH);
   m_startDetected=1;
   break;
  end   
 end
endtask


