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

`ifndef iicSlaveAddress_h
`define iicSlaveAddress_h

class iicSlaveAddress extends uvm_object;
 `uvm_object_utils(iicSlaveAddress)

 rand bit[6:0] m_slaveAddress;
 string        m_name;

 function new(string name = "iicSlaveAddress");
  super.new(name);
  m_name = name;
 endfunction

 constraint slaveAddress_c {
  m_slaveAddress[6:0] != 7'h0;     //General Call or START byte
  m_slaveAddress[6:0] != 7'h1;     //CBUS address
  m_slaveAddress[6:0] != 7'h2;     //Reserved for different bus format
  m_slaveAddress[6:0] != 7'h3;     //Reserved for future purpose
  m_slaveAddress[6:2] != 5'h1;     //Hs-mode master code
  m_slaveAddress[6:2] != 5'b11111; //Reserved for future purpose.
  m_slaveAddress[6:2] != 5'b11110; //10-bit slave addressing
 }

endclass


`endif