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
//    JTAP TAP Controller                                      //
//    Altera Virtual JTAG TAP Controller                       //
//                                                             //
/////////////////////////////////////////////////////////////////
//                                                             //
//     Copyright (C) 2015 ROA Logic BV                         //
//                                                             //
//    This confidential and proprietary software is provided   //
//  under license. It may only be used as authorised by a      //
//  licensing agreement from ROA Logic BV.                     //
//  No parts may be copied, reproduced, distributed, modified  //
//  or adapted in any form without prior written consent.      //
//  This entire notice must be reproduced on all authorised    //
//  copies.                                                    //
//                                                             //
//    TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT      //
//  SHALL ROA LOGIC BE LIABLE FOR ANY INDIRECT, SPECIAL,       //
//  CONSEQUENTIAL OR INCIDENTAL DAMAGES WHATSOEVER (INCLUDING, //
//  BUT NOT LIMITED TO, DAMAGES FOR LOSS OF PROFIT, BUSINESS   //
//  INTERRUPTIONS OR LOSS OF INFORMATION) ARISING OUT OF THE   //
//  USE OR INABILITY TO USE THE PRODUCT WHETHER BASED ON A     //
//  CLAIM UNDER CONTRACT, TORT OR OTHER LEGAL THEORY, EVEN IF  //
//  ROA LOGIC WAS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.  //
//  IN NO EVENT WILL ROA LOGIC BE LIABLE TO ANY AGGREGATED     //
//  CLAIMS MADE AGAINST ROA LOGIC GREATER THAN THE FEES PAID   //
//  FOR THE PRODUCT                                            //
//                                                             //
/////////////////////////////////////////////////////////////////


module altera_virtual_tap #(
  parameter        DEBUG_CMD     = 4'h8
)
(
  output     tck,

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
  // Variables
  //
  logic [3:0] ir; //contents of IR register


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  //Instantiate Altera Virtual TAP controller
  sld_virtual_jtag #(
    .sld_auto_instance_index ( "YES" ),
    .sld_ir_width            (     4 ) //Width of IR-register. Our CMD=4bits, so 4
  )
  altera_virtual_tap (
    .tck               ( tck                ),
    .tdo               ( dbg_tdo            ), //from debug controller
    .tdi               ( dbg_tdi            ), //to debug controller

    //To confuse the heck out of everybody, ir_in is an output
    .ir_in             ( ir                 ), //IR contents

    .jtag_state_tlr    ( tap_TestLogicReset ),
    .virtual_state_cdr ( tap_CaptureDR      ),
    .virtual_state_sdr ( tap_ShiftDR        ),
    .virtual_state_pdr ( tap_PauseDR        ),
    .virtual_state_udr ( tap_UpdateDR       )
  );

  assign dbg_sel = (ir == DEBUG_CMD);
endmodule

