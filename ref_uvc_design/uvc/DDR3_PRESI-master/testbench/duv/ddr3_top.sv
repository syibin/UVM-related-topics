////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
////////////////////////////////////////////////////////////////////////////////

module ddr3_top;

ddr3_interface i();

ddr3 dut(
    .rst_n(i.rst_n),
    .ck(i.ck),
    .ck_n(i.ck_n),
    .cke(i.cke),
    .cs_n(i.cs_n),
    .ras_n(i.ras_n),
    .cas_n(i.cas_n),
    .we_n(i.we_n),
    .dm_tdqs(i.dm_tdqs),
    .ba(i.ba),
    .addr(i.addr),
    .dq(i.dq),  
    .dqs(i.dqs_n),
    .dqs_n(i.dqs_n),
    .tdqs_n(i.tdqs_n),
    .odt(i.odt)
);

endmodule


