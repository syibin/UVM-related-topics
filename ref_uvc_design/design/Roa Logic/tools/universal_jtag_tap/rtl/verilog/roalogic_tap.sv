/////////////////////////////////////////////////////////////////
//                                                             //
//    ██████╗  ██████╗  █████╗                                 //
//    ██╔══██╗██╔═══██╗██╔══██╗                                //
//    ██████╔╝██║   ██║███████║                                //
//    ██╔══██╗██║   ██║██╔══██║                                //
//    ██║  ██║╚██████╔╝██║  ██║                                //
//    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝                                //
//          ██╗      ██████╗  ██████╗ ██╗ ██████╗              //
//          ██║     ██╔═══██╗██╔════╝ ██║██╔════╝              //
//          ██║     ██║   ██║██║  ███╗██║██║                   //
//          ██║     ██║   ██║██║   ██║██║██║                   //
//          ███████╗╚██████╔╝╚██████╔╝██║╚██████╗              //
//          ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝              //
//                                                             //
//    JTAG Debug                                               //
//    Generic IEEE 1149.1-2001 compliant TAP controller        //
//                                                             //
/////////////////////////////////////////////////////////////////
//                                                             //
//     Copyright (C) 2015-2017 ROA Logic BV                    //
//                                                             //
//  Acknowledgement:                                           //
//    Based on the IEEE 1149.1-2001 Specification and the      //
//    works of Nathan Yawn and Igor Mohor.                     //
//                                                             //
//   This source file may be used and distributed without      //
// restriction provided that this copyright statement is not   //
// removed from the file and that any derivative work contains //
// the original copyright notice and the associated disclaimer.//
//                                                             //
//     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     //
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   //
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   //
// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      //
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         //
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    //
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   //
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        //
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  //
// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  //
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  //
// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         //
// POSSIBILITY OF SUCH DAMAGE.                                 //
//                                                             //
/////////////////////////////////////////////////////////////////

 
module roalogic_jtag_tap #(
  parameter [31:0] JTAG_IDCODE = 32'h149511c3,
// 0001             version
// 0100100101010001 part number (IQ)
// 00011100001      manufacturer id (flextronics)
// 1                required by standard

  parameter [31:0] JTAG_USERCODE = 32'h0
)
(
  //Power-on-Reset. NOT SYSTEM RESET
  input      power_on_resetn,

  // JTAG pins
  input      jtag_trstn,      //Test Reset (active low)
             jtag_tms,        //Test Mode Select
             jtag_tck,        //Test Clock
             jtag_tdi,        //Test Data In
  output reg jtag_tdo,        //Test Data Out
             jtag_tdo_oe,     //Test Data Output-enable 


  //JTAG states relevant for debugging
  output     tap_TestLogicReset,
             tap_CaptureDR,
             tap_ShiftDR,
             tap_PauseDR,
             tap_UpdateDR,

  //serial TDx link
  output     dbg_sel,
  input      dbg_tdo,
  output     dbg_tdi
);

  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  //Tap states, according to IEEE 1149.1-2001
  typedef enum logic [3:0] { TestLogicReset = 4'h0,
                             RunTestIdle    = 4'h1,
                             SelectDRScan   = 4'h2,
                             CaptureDR      = 4'h3,
                             ShiftDR        = 4'h4,
                             Exit1DR        = 4'h5,
                             PauseDR        = 4'h6,
                             Exit2DR        = 4'h7,
                             UpdateDR       = 4'h8,
                             SelectIRScan   = 4'h9,
                             CaptureIR      = 4'ha,
                             ShiftIR        = 4'hb,
                             Exit1IR        = 4'hc,
                             PauseIR        = 4'hd,
                             Exit2IR        = 4'he,
                             UpdateIR       = 4'hf
                           } tap_states;
 
  typedef enum logic [3:0] { //Mandatory: BYPASS,EXTEST,PRELOAD,SAMPLE
                             EXTEST         = 4'h0, //Mandatory, should not be '0'!!
                             SAMPLE_PRELOAD = 4'h1, //per 1149.1-2001 a merged instruction
                             IDCODE         = 4'h2,
                             USERCODE       = 4'h6,
                             SAMPLE         = 4'h3, //Mandatory
                             PRELOAD        = 4'h5, //Mandatory
                             DEBUG          = 4'h8,
                             MBIST          = 4'h9,
                             BYPASS         = 4'hf  //Mandatory
                           } tap_instructions;


  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic                               tap_resetn;     //active low reset

  tap_states                          tap_state;      //TAP Controller states

  logic [$bits(tap_instructions)-1:0] instruction_sr; //Instruction Shift Register
  tap_instructions                    instruction;    //Instruction Register

  logic                               bypass_sel,
                                      idcode_sel,
                                      usercode_sel;

  logic                               bypass_sr;     //just 1 bit
  logic [                       31:0] idcode_sr,     //Device ID Shift Register
                                      usercode_sr;   //User ID Shift Register

  logic                               bypass_tdo,
                                      instruction_tdo,
                                      idcode_tdo,
                                      usercode_tdo;



  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //TRSTn is optional. Use PowerOnReset to ensure valid state
  //Do NOT USE SYSTEM RESET
  assign tap_resetn = ~(~jtag_trstn | ~power_on_resetn);


  assign dbg_tdi = jtag_tdi;



  /*
   * TAP Controller State Machine (Section 6. Figure 6.1)
   */
  always @(posedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn) tap_state <= TestLogicReset;
    else
      case (tap_state)
          TestLogicReset: if (!jtag_tms) tap_state <= RunTestIdle;
          RunTestIdle   : if ( jtag_tms) tap_state <= SelectDRScan;
          SelectDRScan  : if ( jtag_tms) tap_state <= SelectIRScan;
                          else           tap_state <= CaptureDR;
          CaptureDR     : if (!jtag_tms) tap_state <= ShiftDR;
                          else           tap_state <= Exit1DR;
          ShiftDR       : if ( jtag_tms) tap_state <= Exit1DR;
          Exit1DR       : if (!jtag_tms) tap_state <= PauseDR;
                          else           tap_state <= UpdateDR;
          PauseDR       : if ( jtag_tms) tap_state <= Exit2DR;
          Exit2DR       : if ( jtag_tms) tap_state <= UpdateDR;
                          else           tap_state <= ShiftDR;
          UpdateDR      : if ( jtag_tms) tap_state <= SelectDRScan;
                          else           tap_state <= RunTestIdle;
          SelectIRScan  : if ( jtag_tms) tap_state <= TestLogicReset;
                          else           tap_state <= CaptureIR;
          CaptureIR     : if (!jtag_tms) tap_state <= ShiftIR;
                          else           tap_state <= Exit1IR;
          ShiftIR       : if ( jtag_tms) tap_state <= Exit1IR;
          Exit1IR       : if (!jtag_tms) tap_state <= PauseIR;
                          else           tap_state <= UpdateIR;
          PauseIR       : if ( jtag_tms) tap_state <= Exit2IR;
          Exit2IR       : if ( jtag_tms) tap_state <= UpdateIR;
                          else           tap_state <= ShiftIR;
          UpdateIR      : if ( jtag_tms) tap_state <= SelectDRScan;
                          else           tap_state <= RunTestIdle;
          default       :                tap_state <= TestLogicReset;
      endcase


  //assign states
  assign tap_TestLogicReset = tap_state == TestLogicReset;
  assign tap_CaptureDR      = tap_state == CaptureDR;
  assign tap_ShiftDR        = tap_state == ShiftDR;
  assign tap_PauseDR        = tap_state == PauseDR;
  assign tap_UpdateDR       = tap_state == UpdateDR;
  


  /*
   * Instruction Register (Section 7)
   */
   //instruction shift register
   always @(posedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn) instruction_sr <= 'h0;
    else
      case (tap_state)
         CaptureIR:   instruction_sr <= { {$bits(instruction_sr)-2{1'b0}}, 2'b01 }; //LSBs must be 01
         ShiftIR  :   instruction_sr <= { jtag_tdi, instruction_sr[$bits(instruction_sr)-1:1] };
      endcase


  //parallel output (on negedge of TCK per IEEE spec)
  always @(negedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn)    instruction <= IDCODE;
    else
      case (tap_state)
         TestLogicReset: instruction <= IDCODE;
         UpdateIR      : instruction <= tap_instructions'(instruction_sr);
      endcase


  assign instruction_tdo = instruction_sr[0];


  //select DR register
  assign bypass_sel   = instruction == BYPASS;
  assign idcode_sel   = instruction == IDCODE;
  assign usercode_sel = instruction == USERCODE;
  assign dbg_sel      = instruction == DEBUG;


  /*
   * BYPASS (Section 8.4)
   */
  always @(posedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn) bypass_sr <= 1'b0;
    else
      case (tap_state)
         TestLogicReset:                 bypass_sr <= 1'b0;
         CaptureDR     : if (bypass_sel) bypass_sr <= 1'b0;
         ShiftDR       : if (bypass_sel) bypass_sr <= jtag_tdi;
      endcase

  assign bypass_tdo = bypass_sr;


  /*
   * IDCODE (Section 8.13)
   */
  always @(posedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn) idcode_sr <= JTAG_IDCODE;
    else
      case (tap_state)
         TestLogicReset: idcode_sr <= JTAG_IDCODE;
         CaptureDR     : if (idcode_sel) idcode_sr <= JTAG_IDCODE;
         ShiftDR       : if (idcode_sel) idcode_sr <= {jtag_tdi, idcode_sr[$bits(idcode_sr)-1:1]};
      endcase

  assign idcode_tdo = idcode_sr[0];


  /*
   * USERCODE (Section 8.14)
   */
  always @(posedge jtag_tck,negedge tap_resetn)
    if (!tap_resetn) usercode_sr <= JTAG_USERCODE;
    else
      case (tap_state)
         TestLogicReset: usercode_sr <= JTAG_USERCODE;
         CaptureDR     : if (usercode_sel) usercode_sr <= JTAG_USERCODE;
         ShiftDR       : if (usercode_sel) usercode_sr <= {jtag_tdi, usercode_sr[$bits(usercode_sr)-1:1]};
      endcase

  assign usercode_tdo = usercode_sr[0];


  /*
   * Generate TDO
   */
  always @(negedge jtag_tck)
    if (tap_state == ShiftIR) jtag_tdo <= instruction_tdo;
    else
      case (instruction)
         BYPASS        : jtag_tdo <= bypass_tdo;
         EXTEST        : jtag_tdo <= 1'b0;
         SAMPLE        : jtag_tdo <= 1'b0;
         PRELOAD       : jtag_tdo <= 1'b0;
         SAMPLE_PRELOAD: jtag_tdo <= 1'b0;
         DEBUG         : jtag_tdo <= dbg_tdo;
         IDCODE        : jtag_tdo <= idcode_tdo;
         USERCODE      : jtag_tdo <= usercode_tdo;
         default       : jtag_tdo <= bypass_tdo;
      endcase


  //negedge? posedge?
  always @(negedge jtag_tck)
    jtag_tdo_oe <= (tap_state == ShiftIR) | (tap_state == ShiftDR);
endmodule
