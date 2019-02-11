initial begin

	@(posedge hresetn);
	repeat (10) @(posedge hclk);

    // fill the slave buffer
	for (j=32'h0;j<32'h07FF;j=j+32'h1) begin
		ahbslv_inst.slave_mem[j] = j[7:0];
	end

    // set a slave delay of 5 cycles on 2nd data beat of each transfer
	ahbslv_inst.set_delay(1, 5);

    // generate some sample transfers by mst0
    // ahb_transfer(addr,size,burst,rn_w,count,store_rdata,comp_rdata,pass_fail)
	@(posedge hclk);

    // read all registers, should be 0
      ahbmst_inst.ahb_transfer(32'h10000000, BUS_32,INCR4,READ,32'h04,0,0,pass_fail);

    // write DMA source address
	ahbmst_inst.data_array[0] = 8'h00;
	ahbmst_inst.data_array[1] = 8'h00;
	ahbmst_inst.data_array[2] = 8'h00;
	ahbmst_inst.data_array[3] = 8'h40;  // 32'h40000000 
      ahbmst_inst.ahb_transfer(32'h10000004, BUS_32,SINGLE,WRITE,32'h01,0,0,pass_fail);

    // write DMA dest address
	ahbmst_inst.data_array[0] = 8'h00;
	ahbmst_inst.data_array[1] = 8'h00;
	ahbmst_inst.data_array[2] = 8'h01;
	ahbmst_inst.data_array[3] = 8'h40;  // 32'h40010000 
      ahbmst_inst.ahb_transfer(32'h10000008, BUS_32,SINGLE,WRITE,32'h01,0,0,pass_fail);
    
    // write block size (3) and count (7)
	ahbmst_inst.data_array[0] = 8'h07;
	ahbmst_inst.data_array[1] = 8'h00;
	ahbmst_inst.data_array[2] = 8'h03;
	ahbmst_inst.data_array[3] = 8'h00;  // 32'h00030007
	ahbmst_inst.ahb_transfer(32'h1000000c, BUS_32,SINGLE,WRITE,32'h01,0,0,pass_fail);

    // read all registers, should be what we wrote above
      ahbmst_inst.ahb_transfer(32'h10000000, BUS_32,INCR4,READ,32'h04,0,0,pass_fail);

    // delay a few cycles before beginning DMA
	repeat (30) @(posedge hclk);

    // start DMA
	ahbmst_inst.data_array[0] = 8'h04;
	ahbmst_inst.data_array[1] = 8'h00;
	ahbmst_inst.data_array[2] = 8'h00;
	ahbmst_inst.data_array[3] = 8'h00; // 32'h00000004
      ahbmst_inst.ahb_transfer(32'h10000000, BUS_32,SINGLE,WRITE,32'h01,0,0,pass_fail);

end
