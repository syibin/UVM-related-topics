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

//Values taken from table 7 on page 36 of v 2.1 of the IIC bus spec.

//Table defines the value for Cb is a maximum of 100pF.

function void setHighSpeedTiming;

 m_fSclMin     = 0;    //kHz   - SCL frequency 
 m_fSclMax     = 3400; //kHz  

 m_tSuStaMin   = 160;  //ns     - set-up time for repeated START condition.
 //tSuStaMax = n/a;  //      - max limit is not applicable

 m_fHdStaMin   = 160;  //ns    - Hold time (repeated) START
 //fHdStaMax = n/a;  //      - max limit is not applicable

 m_tLowMin     = 160;  //ns    
 //tLowMax   = n/a;  //      - max limit is not applicable

 m_tHighMin    = 160;  //ns    - high period of SCL clock
 //tHighMax  = n/a;  //      - max limit is not applicable

 m_tSuDatMin   = 10;   //ns    - data set-up time
 //tSuDatMax = n/a;  //      - max limit is not applicable

 m_tHdDatMin   = 0;    //ns    - Data hold time. Note : See note 3
 m_tHdDatMax   = 70;   //ns    -                  

  //SDA and SCL rise and fall time checking left to STA.

 m_tSuStoMin   = 160;  //ns     - set-up time for STOP
 //tSuStoMax = n/a;    //      - max limit is not applicable

 //Capacitive load foreach bus line not subject to checking by TB.
 //Noise margins not subject to checking by TB.


endfunction

