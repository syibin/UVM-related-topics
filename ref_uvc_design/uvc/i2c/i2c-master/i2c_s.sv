module i2c_s (inout SDA, input SCL, input rst);
  
  // The 7-bits address that we want for our I2C slave
  parameter I2C_ADR = 7'h27;
  
  //////////////////////////
  // Now we are ready to count the I2C bits coming in
  logic [3:0] bitcnt;  // counts the I2C bits from 7 downto 0, plus an ACK bit
  logic data_phase;
  logic adr_phase;
  logic rw, sB;
  logic start_stop, start_stop_in;
  logic start_detect;
  logic start_resetter;
  logic start_rst;
  
  assign adr_phase = ~data_phase;

  assign start_rst = ~rst | start_resetter;
  
  always @ (posedge start_rst or negedge SDA)
  begin
    if (start_detect == 1) begin
      start_detect <= 1;
    end
    else begin
      if (start_rst)
        start_detect <= 1'b0;
      else
        start_detect <= 1'b1;
    end
  end
  
  always @ (negedge rst or posedge SCL)
  begin
    if (~rst)
      start_resetter <= 1'b0;
    else
      start_resetter <= start_detect;
  end

  always_ff @(negedge SCL or rst) begin
    if(~rst)
    begin
        bitcnt <= 4'h7;  // the bit 7 is received first
        data_phase <= 1'b0;
    end
    else
    begin
		if (bitcnt != 0 && !SCL)  begin
	      bitcnt <= bitcnt - 4'h1;
		end
		if (bitcnt == 0 && !SCL) begin
		  data_phase <= 1'b1;
		  bitcnt <= 4'd7;
		end
    end
  end
  
  //Sample data on the posedge
  always_ff @ (posedge SCL) begin

    //Check if it's ready yet
    if (start_detect == 1) begin
      


    end
    
  
  end
// and detect if the I2C address matches our own
//wire adr_phase = ~data_phase;
//reg adr_match, op_read, got_ACK;
//reg SDAr;  always @(posedge SCL) SDAr<=SDA;  // sample SDA on posedge since the I2C spec specifies as low as 0us hold-time on negedge
//reg [7:0] mem;
//wire op_write = ~op_read;
//
//always @(negedge SCL or negedge incycle)
//if(~incycle)
//begin
//    got_ACK <= 1'b0;
//    adr_match <= 1'b1;
//    op_read <= 1'b0;
//end
//else
//begin
//    if(adr_phase & bitcnt==7 & SDAr!=I2C_ADR[6]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==6 & SDAr!=I2C_ADR[5]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==5 & SDAr!=I2C_ADR[4]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==4 & SDAr!=I2C_ADR[3]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==3 & SDAr!=I2C_ADR[2]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==2 & SDAr!=I2C_ADR[1]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==1 & SDAr!=I2C_ADR[0]) adr_match<=1'b0;
//    if(adr_phase & bitcnt==0) op_read <= SDAr;
//    if(bit_ACK) got_ACK <= ~SDAr;  // we monitor the ACK to be able to free the bus when the master doesn't ACK during a read operation
//
//    if(adr_match & bit_DATA & data_phase & op_write) mem[bitcnt] <= SDAr;  // memory write
//end
//
//// and drive the SDA line when necessary.
//wire mem_bit_low = ~mem[bitcnt[2:0]];
//wire SDA_assert_low = adr_match & bit_DATA & data_phase & op_read & mem_bit_low & got_ACK;
//wire SDA_assert_ACK = adr_match & bit_ACK & (adr_phase | op_write);
//wire SDA_low = SDA_assert_low | SDA_assert_ACK;
//assign SDA = SDA_low ? 1'b0 : 1'bz;
//
//assign IOout = mem;
endmodule:i2c_s

