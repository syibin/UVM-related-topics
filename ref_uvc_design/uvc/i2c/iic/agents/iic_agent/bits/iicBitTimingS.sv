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

//Values taken from table 5 on page 32 of v 2.1 of the IIC bus spec.

function void setSlowSpeedTiming;

 m_fSclMin     = 0;      //kHz   - SCL frequency 
 m_fSclMax     = 100;    //kHz  

 m_fHdStaMin   = 4000;   //ns    - Hold time (repeated) START
 //fHdStaMax = n/a;    //      - max limit is not applicable

 m_tLowMin     = 4700;   //ns    
 //tLowMax   = n/a;    //      - max limit is not applicable

 m_tHighMin    = 4000;   //ns    - high period of SCL clock
 //tHighMax  = n/a;    //      - max limit is not applicable
  
 m_tSuStaMin   = 4700;   //ns    - set-up time for repeated START condition.
 //tSuStaMax = n/a;    //      - max limit is not applicable

 m_tHdDatMin   = 0;      //ns    - Data hold time. Note : See footnote 2 of table 5.
 m_tHdDatMax   = 3450;   //ns    - 

 m_tSuDatMin   = 250;      //ns  - data set-up time
 //tSuDatMax = n/a;    //      - max limit is not applicable

  //SDA and SCL rise and fall time checking left to STA.

 m_tSuStoMin   = 4000;   //ns    - set-up time for STOP
 //tSuStoMax = n/a;    //      - max limit is not applicable

 m_tBufMin     = 4700;   //ns    - bus free time between a STOP and START condition.
 //tBufMax   = n/a;    //ns    - max limit is not applicable

 //Capacitive load foreach bus line not subject to checking by TB.
 //Noise margins not subject to checking by TB.

endfunction


