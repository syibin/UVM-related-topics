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
//    JTAG TAP Controller                                      //
//    Technology independent top-level                         //
//                                                             //
/////////////////////////////////////////////////////////////////
//                                                             //
//     Copyright (C) 2016-2017 ROA Logic BV                    //
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


module universal_jtag_tap #(
  parameter        TECHNOLOGY  = "ALTERA",
  parameter [31:0] JTAG_IDCODE = 32'h149511c3,
// 0001             version
// 0100100101010001 part number (IQ)
// 00011100001      manufacturer id (flextronics)
// 1                required by standard

  parameter [31:0] JTAG_USERCODE = 32'h0
)
(
  //Power-on-Reset. NOT SYSTEM RESET (only used for ASIC target)
  input      power_on_resetn,

  // JTAG pins (only used for ASIC target)
  input      jtag_trstn,      //Test Reset (active low)
             jtag_tms,        //Test Mode Select
             jtag_tck,        //Test Clock
             jtag_tdi,        //Test Data In
  output reg jtag_tdo,        //Test Data Out
             jtag_tdo_oe,     //Test Data Output-enable 


  //JTAG states relevant for debugging
  output     tap_tck,
             tap_TestLogicReset,
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
  localparam DEBUG_CMD = 4'h8;


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

generate
  if (TECHNOLOGY == "ALTERA" ||
      TECHNOLOGY == "Altera" ||
      TECHNOLOGY == "altera" )
  begin
      altera_virtual_tap #(
        .DEBUG_CMD ( DEBUG_CMD )
      )
      altera_tap (
        .tck                ( tap_tck            ),
        .tap_TestLogicReset ( tap_TestLogicReset ),
        .tap_CaptureDR      ( tap_CaptureDR      ),
        .tap_ShiftDR        ( tap_ShiftDR        ),
        .tap_PauseDR        ( tap_PauseDR        ),
        .tap_UpdateDR       ( tap_UpdateDR       ),
        .dbg_sel            ( dbg_sel            ),
        .dbg_tdo            ( dbg_tdo            ),
        .dbg_tdi            ( dbg_tdi            ) );
  end
  else if (TECHNOLOGY == "XILINX" ||
           TECHNOLOGY == "Xilinx" ||
           TECHNOLOGY == "xilinx" )
  begin
  end
  else //Generic/ASIC TAP Controller
  begin
      roalogic_jtag_tap #(
        .JTAG_IDCODE   ( JTAG_IDCODE   ),
        .JTAG_USERCODE ( JTAG_USERCODE )
      )
      roalogic_tap (
        .power_on_resetn    ( power_on_resetn    ),

        .jtag_trstn         ( jtag_trstn         ),
        .jtag_tck           ( jtag_tck           ),
        .jtag_tms           ( jtag_tms           ),
        .jtag_tdi           ( jtag_tdi           ),
        .jtag_tdo           ( jtag_tdo           ),
        .jtag_tdo_oe        ( jtag_tdo_oe        ), 

        .tap_TestLogicReset ( tap_TestLogicReset ),
        .tap_CaptureDR      ( tap_CaptureDR      ),
        .tap_ShiftDR        ( tap_ShiftDR        ),
        .tap_PauseDR        ( tap_PauseDR        ),
        .tap_UpdateDR       ( tap_UpdateDR       ),

        .dbg_sel            ( dbg_sel            ),
        .dbg_tdo            ( dbg_tdo            ),
        .dbg_tdi            ( dbg_tdi            ) );

      //route JTAG TCK as tap_tck
      assign tap_tck = jtag_tck;
  end
endgenerate

endmodule
