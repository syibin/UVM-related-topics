//*****************************************************************************
//	DESIGN	NAME	:	uart_receiver
//	FILE	NAME	:	uart_receiver.v
//	DESIGNER		:	Andrey B. Didenko
//
//	The module is UART's top level.
//  It contains APB register access manager, block of operational registers,
//  UART Transmitter and Receiver.
//*****************************************************************************

module uart_top #( parameter APB_ADDR_WIDTH    = 8,
                   parameter APB_BASE_ADDRESS  = 32'h0
                 )
(

// clock and reset
input  wire                          clk,
input  wire                          rst_n,

// APB register's interface
input  wire [APB_ADDR_WIDTH - 1 : 0] apb_addr_i,
input  wire                          apb_sel_i,
input  wire                          apb_en_i,
input  wire                          apb_wr_i,
input  wire                   [31:0] apb_wdata_i,
input  wire                    [3:0] apb_strb_i,

output wire                   [31:0] apb_rdata_o,
output wire                          apb_ready_o,
output wire                          apb_err_o,

// interrupt
output wire                    [2:0] int_o,

// external interface
input  wire                          cts_i,
output wire                          txd_o,

input  wire                          rxd_i,
output wire                          rts_o,

// triggers
output wire                          rx_trig_o,
output wire                          tx_trig_o

);


// wires
wire [31:0] rdat        ;
wire  [5:0] rreq        ;
wire [31:0] wdat        ;
wire  [5:0] wreq        ;
wire  [3:0] wstr        ;
wire        tsr_empty   ;
wire        tsr_push    ;
wire  [7:0] tsr_byte    ;
wire        txbrk       ;
wire        rsr_empty   ;
wire        rsr_full    ;
wire  [7:0] rsr_byte    ;
wire        ferr        ;
wire        perr        ;
wire        rsr_pull    ;
wire        cts         ;
wire        enable      ;
wire        brg_sample  ;
wire        brgh        ;
wire        rxinv       ;
wire        txinv       ;
wire        lpback      ;
wire        stsel       ;
wire  [1:0] pdsel       ;
wire        cts_w       ;
wire        txd_w       ;
wire        rxd_w       ;
wire        rts_w       ;



/**************************************************************************************************
*                                 Register access manager                                         *
**************************************************************************************************/
uart_apb_slave #( .AWIDTH     ( APB_ADDR_WIDTH    ),
                  .DWIDTH     ( 32                ),
                  .BASE_ADDR	( APB_BASE_ADDRESS  )
                )
uart_apb_slave_u (
  // system
  .clk          ( clk         ),
  .rst_n        ( rst_n       ),

  // APB
  .apb_addr_i   ( apb_addr_i  ),
  .apb_sel_i    ( apb_sel_i   ),
  .apb_en_i     ( apb_en_i    ),
  .apb_wr_i     ( apb_wr_i    ),
  .apb_wdata_i  ( apb_wdata_i ),
  .apb_strb_i   ( apb_strb_i  ),

  .apb_rdata_o  ( apb_rdata_o ),
  .apb_ready_o  ( apb_ready_o ),
  .apb_err_o    ( apb_err_o   ),

  // read apb_manager
  .rerr_i       ( 1'b0        ),
  .rdat_i       ( rdat        ),

  .rreq_o       ( rreq        ),

  // write apb_manager
  .werr_i       ( 1'b0        ),

  .wdat_o       ( wdat        ),
  .wreq_o       ( wreq        ),
  .wstr_o       ( wstr        )
);


/**************************************************************************************************
*                                       UART registers                                            *
**************************************************************************************************/
uart_regs regs_regs_u(
  //---- Clock & Reset ----------------------
  .clk          ( clk         ),
  .rst_n        ( rst_n       ),

  //---- Interrupt request ------------------
  .int_o        ( int_o       ),

  //---- Regs access interface---------------
  .rg_wreq_i    ( wreq        ),
  .rg_rreq_i    ( rreq        ),
  .rg_wdat_i    ( wdat        ),
  .rg_wstr_i    ( wstr        ),

  .rg_rdat_o    ( rdat        ),

  //---- Transmitter data Interface ---------
  .tsr_empty_i  ( tsr_empty   ),

  .tsr_push_o   ( tsr_push    ),
  .tsr_byte_o   ( tsr_byte    ),
  .txbrk_o      ( txbrk       ),

  //---- Receiver data Interface ------------
  .rsr_empty_i  ( rsr_empty   ),
  .rsr_full_i   ( rsr_full    ),
  .rsr_byte_i   ( rsr_byte    ),
  .ferr_i       ( ferr        ),
  .perr_i       ( perr        ),

  .rsr_pull_o   ( rsr_pull    ),

  //---- modes ------------------------------
  .cts_i        ( cts         ),

  .enable_o     ( enable      ),
  .brg_sample_o ( brg_sample  ),
  .brgh_o       ( brgh        ),
  .rxinv_o      ( rxinv       ),
  .txinv_o      ( txinv       ),
  .lpback_o     ( lpback      ),
  .stsel_o      ( stsel       ),
  .pdsel_o      ( pdsel       ),

  //---- triggers ---------------------------
  .rx_trig_o    ( rx_trig_o   ),
  .tx_trig_o    ( tx_trig_o   )

);


/**************************************************************************************************
*                                     UART Transmitter                                            *
**************************************************************************************************/
uart_transmitter uart_transmitter_u(
  //---- Clock & Reset ----------------------
  .clk          ( clk         ),
  .rst_n        ( rst_n       ),

  //---- Transmitter data Interface ---------
  .tsr_push_i   ( tsr_push    ),
  .tsr_byte_i   ( tsr_byte    ),
  .txbrk_i      ( txbrk       ),

  .tsr_empty_o  ( tsr_empty   ),

  //---- modes ------------------------------
  .enable_i     ( enable      ),
  .brg_sample_i ( brg_sample  ),
  .brgh_i       ( brgh        ),
  .stsel_i      ( stsel       ),
  .pdsel_i      ( pdsel       ),

  .cts_o        ( cts         ),

  //---- external interface -----------------
  .cts_i        ( cts_w       ),

  .txd_o        ( txd_w       )

);


/**************************************************************************************************
*                                       UART Receiver                                             *
**************************************************************************************************/
uart_receiver uart_receiver_u(
  //---- Clock & Reset ----------------------
  .clk          ( clk         ),
  .rst_n        ( rst_n       ),

  //---- Receiver data Interface ---------
  .rsr_pull_i   ( rsr_pull    ),

  .rsr_empty_o  ( rsr_empty   ),
  .rsr_full_o   ( rsr_full    ),
  .rsr_byte_o   ( rsr_byte    ),
  .ferr_o       ( ferr        ),
  .perr_o       ( perr        ),

  //---- modes ------------------------------
  .enable_i     ( enable      ),
  .brg_sample_i ( brg_sample  ),
  .brgh_i       ( brgh        ),
  .pdsel_i      ( pdsel       ),

  //---- external interface -----------------
  .rxd_i        ( rxd_w       ),

  .rts_o        ( rts_w       )

);


/**************************************************************************************************
*                                        Loopback logic                                           *
**************************************************************************************************/
assign rxd_w = lpback? txd_w : (rxinv? !rxd_i : rxd_i);
assign cts_w = lpback? rts_w : cts_i;

assign txd_o = txd_w;
assign rts_o = rts_w;


endmodule
