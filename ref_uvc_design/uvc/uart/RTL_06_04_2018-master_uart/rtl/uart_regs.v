//*****************************************************************************
//	DESIGN	NAME	:	uart_regs
//	FILE	NAME	:	uart_regs.v
//	DESIGNER		:	Andrey B. Didenko
//
//	The module implements internal UART registers.
//  It contains software accessible registers, BRG, receive and transmit FIFOs.
//  and control interface logic with uart_receiver and uart_transmitter modules.
//*****************************************************************************

module uart_regs
(
//---- Clock & Reset ----------------------
input	wire		      clk             ,
input	wire		      rst_n           ,

//---- Interrupt request ------------------
output  wire [2:0]        int_o           ,

//---- Regs access interface---------------
input   wire [5:0]        rg_wreq_i       ,
input   wire [5:0]        rg_rreq_i       ,
input	wire [31:0]	      rg_wdat_i       ,
input	wire [3:0]	      rg_wstr_i       ,

output	wire [31:0]       rg_rdat_o       ,

//---- Transmitter data Interface ---------
input   wire              tsr_empty_i     ,

output  wire              tsr_push_o      ,
output  wire [7:0]        tsr_byte_o      ,
output  wire              txbrk_o         ,

//---- Receiver data Interface ------------
input   wire              rsr_empty_i     ,
input   wire              rsr_full_i      ,
input   wire [7:0]        rsr_byte_i      ,
input   wire              ferr_i          ,
input   wire              perr_i          ,

output  wire              rsr_pull_o      ,

//---- modes ------------------------------
input   wire              cts_i           ,

output  wire              enable_o        ,
output  wire              brg_sample_o    ,
output  wire              brgh_o          ,
output  wire              rxinv_o         ,
output  wire              txinv_o         ,
output  wire              lpback_o        ,
output  wire              stsel_o         ,
output  wire [1:0]        pdsel_o         ,

//---- triggers ---------------------------
output  wire              rx_trig_o       ,
output  wire              tx_trig_o

//-----------------------------------------
);

//*****************************************************************************
//							Declarations
//*****************************************************************************

wire [31:0] rg_intf        ;
wire [31:0] rg_intc        ;
wire [31:0] rg_mode        ;
wire [31:0] rg_status      ;
wire [31:0] rg_rxbuf       ;
wire [31:0] rg_txbuf       ;
wire [31:0] wstr_b         ;
wire [31:0] rg_rdat_mux    ;
wire        tsr_push       ;
wire  [7:0] tsr_byte       ;
wire        rsr_pull       ;
wire        txfifo_empty   ;
wire        rxfifo_full    ;
wire        rxfifo_empty   ;
wire        txfifo_full    ;
wire        rg_intf_wreq   ;
wire        rg_intc_wreq   ;
wire        rg_mode_wreq   ;
wire        rg_status_wreq ;
wire        rg_txbuf_wreq  ;
wire        rg_intf_rreq   ;
wire        rg_intc_rreq   ;
wire        rg_mode_rreq   ;
wire        rg_status_rreq ;
wire        rg_rxbuf_rreq  ;
wire        rg_txbuf_rreq  ;
wire        trmt           ;
wire        txbf           ;
wire        ridle          ;
wire        perr           ;
wire        ferr           ;
wire        rxda           ;
wire  [3:0] txbuf_wr       ;
wire  [3:0] rxbuf_wr       ;
wire        erif_set       ;
wire        rxif_set       ;
wire        txif_set       ;
wire  [2:0] words_in_rxbuf ;
wire  [7:0] rbc            ;
wire        rbe            ;
wire        rbf            ;
wire  [7:0] tbc            ;
wire        tbe            ;
wire        tbf            ;

reg  [31:0] rg_rdat_mux_d  ;
reg         erif           ;
reg         rxif           ;
reg         txif           ;
reg         erie           ;
reg         rxie           ;
reg         txie           ;
reg  [15:0] brg            ;
reg         txinv          ;
reg   [1:0] txisel         ;
reg         rxinv          ;
reg   [1:0] rxisel         ;
reg         enable         ;
reg         lpback         ;
reg         fce            ;
reg         brgh           ;
reg         stsel          ;
reg   [1:0] pdsel          ;
reg         txbrk          ;
reg         oerr           ;
reg   [2:0] txbuf_wptr     ;
reg   [2:0] txbuf_rptr     ;
reg   [7:0] txbuf     [0:3];
reg   [2:0] rxbuf_wptr     ;
reg   [2:0] rxbuf_rptr     ;
reg   [7:0] rxbuf     [0:3];
reg   [1:0] rxsts     [0:3];
reg  [15:0] brg_cnt        ;
reg         tsr_empty_d    ;
reg         txfifo_empty_d ;
reg         txbrk_r        ;



//*****************************************************************************
//							Interface logic
//*****************************************************************************


assign enable_o   = enable                    ;
assign txinv_o    = txinv                     ;
assign rxinv_o    = rxinv                     ;
assign txbrk_o    = txbrk_r | txbrk & tsr_push;
assign lpback_o   = lpback                    ;
assign brgh_o     = brgh                      ;
assign stsel_o    = stsel                     ;
assign pdsel_o    = pdsel                     ;


assign tsr_push_o = tsr_push;
assign tsr_byte_o = tsr_byte;
assign rsr_pull_o = rsr_pull;

assign tsr_push   = tsr_empty_i & !txfifo_empty & (fce & !cts_i | !fce) & !txbrk_r;
assign rsr_pull   = rsr_full_i & !rxfifo_full;

//*****************************************************************************
//							Registers Access logic
//*****************************************************************************

assign rg_rdat_o = rg_rdat_mux_d;

assign rg_intf_wreq   = rg_wreq_i[0];
assign rg_intc_wreq   = rg_wreq_i[1];
assign rg_mode_wreq   = rg_wreq_i[2];
assign rg_status_wreq = rg_wreq_i[3];
assign rg_txbuf_wreq  = rg_wreq_i[5];

assign rg_intf_rreq   = rg_rreq_i[0];
assign rg_intc_rreq   = rg_rreq_i[1];
assign rg_mode_rreq   = rg_rreq_i[2];
assign rg_status_rreq = rg_rreq_i[3];
assign rg_rxbuf_rreq  = rg_rreq_i[4];
assign rg_txbuf_rreq  = rg_rreq_i[5];


assign wstr_b = {
                {8{rg_wstr_i[3]}},
                {8{rg_wstr_i[2]}},
                {8{rg_wstr_i[1]}},
                {8{rg_wstr_i[0]}}
                };


assign rg_rdat_mux = (rg_intf_rreq  )? rg_intf   :
                     (rg_intc_rreq  )? rg_intc   :
                     (rg_mode_rreq  )? rg_mode   :
                     (rg_status_rreq)? rg_status :
                     (rg_rxbuf_rreq )? rg_rxbuf  :
                     (rg_txbuf_rreq )? rg_txbuf  : 32'h0;

always @(posedge clk or negedge rst_n)
    if (!rst_n)          rg_rdat_mux_d <=	32'h0;
    else if (|rg_rreq_i) rg_rdat_mux_d <= rg_rdat_mux;


//*****************************************************************************
//							Interrupts
//*****************************************************************************

assign int_o = rg_intf[2:0] & rg_intc[2:0];


//*****************************************************************************
//              INTF Register
//
//	Location		Attribute		Field Name
//
//  [31:03]         Rsvd
//  [02]            R/W1C           ERIF
//  [01]            R/W1C           RXIF
//  [00]            R/W1C           TXIF
//*****************************************************************************

assign rg_intf =    {
                    29'h0  ,
                    erif   ,
                    rxif   ,
                    txif
                    };

always @(posedge clk or negedge rst_n)
    if (!rst_n)                                       erif  <= 1'b0;
    else if (erif_set)                                erif  <= 1'b1;
    else if (rg_intf_wreq & wstr_b[2] & rg_wdat_i[2]) erif  <= 1'b0;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                                       rxif  <= 1'b0;
    else if (rxif_set)                                rxif  <= 1'b1;
    else if (rg_intf_wreq & wstr_b[1] & rg_wdat_i[1]) rxif  <= 1'b0;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                                       txif  <= 1'b0;
    else if (txif_set)                                txif  <= 1'b1;
    else if (rg_intf_wreq & wstr_b[0] & rg_wdat_i[0]) txif  <= 1'b0;

always @(posedge clk or negedge rst_n)
    if (!rst_n) tsr_empty_d <= 1'b0;
    else        tsr_empty_d <= tsr_empty_i;

always @(posedge clk or negedge rst_n)
    if (!rst_n) txfifo_empty_d <= 1'b0;
    else        txfifo_empty_d <= txfifo_empty;


assign erif_set = (|rxbuf_wr) & (ferr_i | perr_i);
assign rxif_set = (rxisel == 2'b10)? (words_in_rxbuf == 3'd2) & rsr_pull :
                  (rxisel == 2'b11)? (words_in_rxbuf == 3'd3) & rsr_pull : rsr_pull;
assign txif_set = (txisel == 2'b01)? tsr_empty_i & !tsr_empty_d & txfifo_empty :
                  (txisel == 2'b10)? txfifo_empty & !txfifo_empty_d : tsr_push;

assign rx_trig_o = rxif_set;
assign tx_trig_o = txif_set;


//*****************************************************************************
//              INTC Register
//
//	Location		Attribute		Field Name
//
//  [31:03]         Rsvd
//  [02]            R/W             ERIE
//  [01]            R/W             RXIE
//  [00]            R/W             TXIE
//*****************************************************************************

assign rg_intc =    {
                    29'h0  ,
                    erie   ,
                    rxie   ,
                    txie
                    };

always @(posedge clk or negedge rst_n)
    if (!rst_n)                        erie  <= 1'b0;
    else if (rg_intc_wreq & wstr_b[2]) erie  <= rg_wdat_i[2];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                        rxie  <= 1'b0;
    else if (rg_intc_wreq & wstr_b[1]) rxie  <= rg_wdat_i[1];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                        txie  <= 1'b0;
    else if (rg_intc_wreq & wstr_b[0]) txie  <= rg_wdat_i[0];


//*****************************************************************************
//              MODE Register
//
//	Location		Attribute		Field Name
//
//  [31:16]         R/W             BRG
//  [15]            R/W             TXINV
//  [14]            Rsvd
//  [13:12]         R/W             TXISEL
//  [11]            R/W             RXINV
//  [10]            Rsvd
//  [09:08]         R/W             RXISEL
//  [07]            R/W             ENABLE
//  [06]            Rsvd
//  [05]            R/W             LPBACK
//  [04]            R/W             FCE
//  [03]            R/W             BRGH
//  [02]            R/W             STSEL
//  [01:00]         R/W             PDSEL
//*****************************************************************************

assign rg_mode =    {
                    brg     ,
                    txinv   ,
                    1'b0    ,
                    txisel  ,
                    rxinv   ,
                    1'b0    ,
                    rxisel  ,
                    enable  ,
                    1'b0    ,
                    lpback  ,
                    fce     ,
                    brgh    ,
                    stsel   ,
                    pdsel
                    };


always @(posedge clk or negedge rst_n)
    if (!rst_n)            brg <= 16'h0;
    else if (rg_mode_wreq) brg <= (brg & (~wstr_b[31:16]) | rg_wdat_i[31:16] & wstr_b[31:16]);

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         txinv  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[15]) txinv  <= rg_wdat_i[15];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         txisel  <= 2'b0;
    else if (rg_mode_wreq & wstr_b[13]) txisel  <= rg_wdat_i[13:12];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         rxinv  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[11]) rxinv  <= rg_wdat_i[11];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         rxisel  <= 2'b0;
    else if (rg_mode_wreq & wstr_b[9])  rxisel  <= rg_wdat_i[9:8];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         enable  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[7])  enable  <= rg_wdat_i[7];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         lpback  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[5])  lpback  <= rg_wdat_i[5];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         fce  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[4])  fce  <= rg_wdat_i[4];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         brgh  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[3])  brgh  <= rg_wdat_i[3];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         stsel  <= 1'b0;
    else if (rg_mode_wreq & wstr_b[2])  stsel  <= rg_wdat_i[2];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                         pdsel  <= 2'b0;
    else if (rg_mode_wreq & wstr_b[1])  pdsel  <= rg_wdat_i[1:0];

//*****************************************************************************
//              STATUS Register
//
//	Location		Attribute		Field Name
//
//  [31:24]         RO              TBC
//  [23:16]         RO              RBC
//  [15]            RO              TBE
//  [14]            RO              RBE
//  [13]            RO              TBF
//  [12]            RO              RBF
//  [11:09]         Rsvd
//  [08]            R/W             TXBRK
//  [07]            RO              CTS
//  [06]            RO              TRMT
//  [05]            RO              TXBF
//  [04]            RO              RIDLE
//  [03]            RO              PERR
//  [02]            RO              FERR
//  [01]            RO              OERR
//  [00]            RO              RXDA
//*****************************************************************************

assign rg_status =  {
                    tbc     ,
                    rbc     ,
                    tbe     ,
                    rbe     ,
                    tbf     ,
                    rbf     ,
                    3'h0    ,
                    txbrk   ,
                    cts_i   ,
                    trmt    ,
                    txbf    ,
                    ridle   ,
                    perr    ,
                    ferr    ,
                    oerr    ,
                    rxda
                    };

assign rxda     = !rxfifo_empty;
assign ridle    = rsr_empty_i;
assign txbf     = txfifo_full;
assign trmt     = tsr_empty_i & txfifo_empty;

assign perr     = rxsts[rxbuf_rptr[1:0]][0];
assign ferr     = rxsts[rxbuf_rptr[1:0]][1];

always @(posedge clk or negedge rst_n)
    if (!rst_n)                          txbrk  <= 1'b0;
    else if (rg_status_wreq & wstr_b[8]) txbrk  <= rg_wdat_i[8];
    else if (txbrk_r & tsr_empty_i)      txbrk  <= 1'b0;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                                oerr   <= 1'b0;
    else if (!oerr & rsr_full_i & rxfifo_full) oerr   <= 1'b1;
    else if (oerr & rxfifo_empty)              oerr   <= 1'b0;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                     txbrk_r <= 1'b0;
    else if (txbrk & tsr_push)      txbrk_r <= 1'b1;
    else if (txbrk_r & tsr_empty_i) txbrk_r <= 1'b0;



//*****************************************************************************
//              TX BUFFER
//*****************************************************************************
always @(posedge clk or negedge rst_n)
    if (!rst_n)                            txbuf_wptr  <= 3'b0;
    else if (rg_txbuf_wreq & !txfifo_full) txbuf_wptr  <= txbuf_wptr + 3'b1;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                            txbuf_rptr  <= 3'b0;
    else if (tsr_push)                     txbuf_rptr  <= txbuf_rptr + 3'b1;

assign txfifo_full  = (txbuf_wptr[2] ^ txbuf_rptr[2]) & (txbuf_wptr[1:0] == txbuf_rptr[1:0]);
assign txfifo_empty = !(txbuf_wptr[2] ^ txbuf_rptr[2]) & (txbuf_wptr[1:0] == txbuf_rptr[1:0]);

assign tsr_byte = txbuf[txbuf_rptr[1:0]];

assign rg_txbuf = tsr_byte;

genvar i;
generate
  for(i = 0; i < 4; i = i + 1) begin

    assign txbuf_wr[i] = rg_txbuf_wreq & wstr_b[0] & (txbuf_wptr[1:0] == i[1:0]);

    always @(posedge clk or negedge rst_n)
        if (!rst_n)           txbuf[i]  <= 8'h0;
        else if (txbuf_wr[i]) txbuf[i]  <= rg_wdat_i[7:0];

  end

endgenerate

assign tbc = {5'h0, (txbuf_wptr - txbuf_rptr)};
assign tbe = txfifo_empty;
assign tbf = txfifo_full;

//*****************************************************************************
//              RX BUFFER
//*****************************************************************************
always @(posedge clk or negedge rst_n)
    if (!rst_n)                             rxbuf_wptr  <= 3'b0;
    else if (rsr_pull)                      rxbuf_wptr  <= rxbuf_wptr + 3'b1;

always @(posedge clk or negedge rst_n)
    if (!rst_n)                             rxbuf_rptr  <= 3'b0;
    else if (rg_rxbuf_rreq & !rxfifo_empty) rxbuf_rptr  <= rxbuf_rptr + 3'b1;

assign rxfifo_full  = (rxbuf_wptr[2] ^ rxbuf_rptr[2]) & (rxbuf_wptr[1:0] == rxbuf_rptr[1:0]);
assign rxfifo_empty = !(rxbuf_wptr[2] ^ rxbuf_rptr[2]) & (rxbuf_wptr[1:0] == rxbuf_rptr[1:0]);

assign words_in_rxbuf = rxbuf_wptr - rxbuf_rptr;

assign rg_rxbuf     = rxbuf[rxbuf_rptr[1:0]];

genvar j;
generate

  for(j = 0; j < 4; j = j + 1) begin

    assign rxbuf_wr[j] = rsr_pull & (rxbuf_wptr[1:0] == j[1:0]);

    always @(posedge clk or negedge rst_n)
        if (!rst_n)           rxbuf[j]  <= 8'h0;
        else if (rxbuf_wr[j]) rxbuf[j]  <= rsr_byte_i;

    always @(posedge clk or negedge rst_n)
        if (!rst_n)           rxsts[j]  <= 8'h0;
        else if (rxbuf_wr[j]) rxsts[j]  <= {ferr_i, perr_i};


  end

endgenerate

assign rbc = {5'h0, (rxbuf_wptr - rxbuf_rptr)};
assign rbe = rxfifo_empty;
assign rbf = rxfifo_full;

//*****************************************************************************
//              BRG
//*****************************************************************************

assign brg_sample_o = !(|brg_cnt);

always @(posedge clk or negedge rst_n)
    if (!rst_n)            brg_cnt  <= 16'b0;
    else if (brg_sample_o) brg_cnt  <= brg;
    else if (|brg_cnt)     brg_cnt  <= brg_cnt - 16'b1;


///////////////////////////////////////////////////////////////////////////////
endmodule
