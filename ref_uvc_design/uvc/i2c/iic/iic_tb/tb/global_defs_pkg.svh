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

package global_defs_pkg;
 typedef int unsigned ui;

//DUT reg map.
`define PRERlo_REG_ADDR    3'h0
`define PRERhi_REG_ADDR    3'h1
`define CTR_REG_ADDR       3'h2
`define TXR_REG_ADDR       3'h3
`define RXR_REG_ADDR       3'h3
`define CR_REG_ADDR        3'h4
`define SR_REG_ADDR        3'h4

//typedef enum {dutStream, xtStream} stream_t;
parameter ui MAXFRAMELENGTH = 100;
parameter ui MAXRETRIES     = 100;
parameter ui P_CLOCKSTRETCHFACTOR = 4;
parameter ui P_TESTRUNOUT = 10000; //10 us. 
parameter ui P_TESTRUNIN  =  5000;  //500 ns. 
parameter ui P_MAXINTERFRAMEDELAY_XT =10; //SCL clock periods.
parameter ui P_MINTERFRAMEDELAY_XT =10; //SCL clock periods.
parameter ui P_MAXINTERFRAMEDELAY_DUT=10;
parameter ui P_MININTERFRAMEDELAY_DUT=10;
parameter ui P_DEFAULTWBFREQUENCY= 50000; //10 MHz.
parameter ui P_ZEROARBMIX = 1;
parameter ui P_ONEARBMIX = 100;
parameter ui P_BITTIMEOUT = 200_00000; //20ms



endpackage

