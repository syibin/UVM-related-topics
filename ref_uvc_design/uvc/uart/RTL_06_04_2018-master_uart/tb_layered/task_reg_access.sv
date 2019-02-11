task automatic driver::reg_access( input        [31:0] address,      // register's address
                                   input  reg_access_t access_type,  // 0 - read, 1 - write 
                                   input        [31:0] reg_wr_data,  // data to be written into register
                                   input         [3:0] reg_be,       // byte enables for write data bytes (1 be per byte)  
                                   output       [31:0] reg_rd_data,  // data read from register
                                   output              reg_err       // error returned
                                    );

            bit [3:0] timeout_cnt;

    		@(posedge uif.clk);
    		uif.psel   <= 1'b1;
    		uif.paddr  <= address;
    		uif.pwrite <= access_type;
            
    		if(access_type == REG_WR) begin

    			uif.pwdata <= reg_wr_data;
    			uif.pstrb  <= reg_be;

    		end
            
    		@(posedge uif.clk);
    		uif.penable <= 1'b1;

    		fork
        
                begin : wait_for_resp

                    wait(uif.pready);
                    //$display("PREADY is Aseerted Here");
                    /*@(posedge uif.clk);
                    uif.psel        <= 1'b0;
                    uif.penable     <= 1'b0;*/
                    
                    if((access_type == REG_RD) & uif.pslverr) begin

                        $display("!!! ERROR !!! Illegal register access occured @%0t", $realtime);
                        reg_rd_data = 32'hDEAD_BEEF;
                        reg_err     = 1'b1;

                    end

                    if((access_type == REG_RD) & !uif.pslverr) begin

                        reg_rd_data = uif.prdata;
                        reg_err     = 1'b0;

                    end

                    if((access_type == REG_WR) & uif.pslverr)  reg_err = 1'b1;
                    if((access_type == REG_WR) & !uif.pslverr) reg_err = 1'b0;
                    
                    @(posedge uif.clk);
                    uif.psel        <= 1'b0;
                    uif.penable     <= 1'b0;


                end : wait_for_resp

                while (!uif.pready) begin : timeout

                    @(posedge uif.clk);
                    timeout_cnt++;
                    if(timeout_cnt == 4'hF) begin

                        $display("Register access timeout reached at %0t!", $realtime);
                        $finish(2);
                        
                    end

                end : timeout

            join_any

endtask : reg_access