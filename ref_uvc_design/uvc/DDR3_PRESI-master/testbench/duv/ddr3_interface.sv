//////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////////


   `include "1024Mb_ddr3_parameters.vh"
   `include "uvm_macros.svh"
   import uvm_pkg::*;
   import ddr3_tb_pkg::*;
interface ddr3_interface();

   
bit   ck;
bit   rst_n;
bit   cke;
bit   cs_n;
bit   ras_n;
bit   cas_n;
bit   we_n;
bit   odt;
bit   odt_out;
bit   [BA_BITS-1:0] ba;
bit   [ADDR_BITS-1:0] addr;
tri   [DM_BITS-1:0] dm_tdqs; 
tri   [DQ_BITS-1:0] dq; 
tri   [DQS_BITS-1:0] dqs_n; 
tri   [DQS_BITS-1:0] dqs; 
tri   [DQS_BITS-1:0] tdqs_n; 
real tck;
wire ck_n = ~ck;


string m_name = "DDR3_INTERFACE";

bit dqs_en;
bit dq_en;

int unsigned wl = AL_MAX + CWL_MAX;
int unsigned bl = BL_MAX;

bit [DQS_BITS-1:0] dqs_out;
logic [DQ_BITS-1:0] dq_out;
bit [DM_BITS-1:0] dm_out;


ddr3_input_monitor m_ip_mon_h;
ddr3_seq_item ip_mon_trans;
bit reset_asserted = 1'b0;
bit write_pkt = 1'b0;



assign dqs = dqs_en ? dqs_out : 'bz;
assign dqs_n = dqs_en ? ~dqs_out : 'bz;
assign dq = dq_en ? dq_out : 'bz;
assign dm_tdqs = dq_en ? dm_out : 'bz; 

initial
begin
	$timeformat (-12,3," ps",10);
    tck = TCK_MIN;
    ck  = 1'b1;
    ip_mon_trans = new("ip_mon_trans");
end

// clock generator
always @(posedge ck) 
begin
    ck <= #(tck/2) 1'b0;
    ck <= #(tck) 1'b1;
end

// power up	
task power_up;
begin
	`uvm_info(m_name,"STARTING DDR3 RESET",UVM_HIGH)
    rst_n   <= 1'b0;
    cke     <= 1'b0;
    cs_n    <= 1'b1;
    odt_out <= 1'b0;
    //#10000;
    #200000000;
    @(negedge ck); 
    rst_n = 1'b1;
	`uvm_info(m_name,"ENDING DDR3 RESET",UVM_HIGH)
    //#10000;
    #500000000;
    @(negedge ck); 
    nop(TXPR/tck +1);
end
endtask

// load mode
task load_mode(input [BA_BITS-1:0] bank, input [ADDR_BITS-1:0] bus_addr);
    begin
        `uvm_info(m_name,"STARTING LOAD OPERATION",UVM_HIGH)
//        case (bank)
//            0:mode_reg0 = addr;
//            1:mode_reg1 = addr;
//            2:mode_reg2 = addr;
//        endcase

        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b0;
        we_n  <= 1'b0;
        ba    <= bank;
        addr     <= bus_addr;
        @(negedge ck);
        nop(10);
        `uvm_info(m_name,"ENDING LOAD OPERATION",UVM_HIGH)
    end
endtask

// refresh
task refresh;
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b0; 
    cas_n <= 1'b0;
    we_n  <= 1'b1;
    @(negedge ck);
end
endtask

//precharge

task precharge (input [BA_BITS-1:0] bank,input [ROW_BITS-1:0] ap);
    begin
	`uvm_info(m_name,"STARTING DDR3 PRECHARGE",UVM_HIGH)
	if (ap[10] == 1) `uvm_info(m_name,"All Bank Precharge",UVM_HIGH) else `uvm_info(m_name,$sformatf("Precharging Bank %0d",bank),UVM_HIGH)
        cke   <= 1'b1;
        cs_n  <= 1'b0;
        ras_n <= 1'b0; 
        cas_n <= 1'b1;
        we_n  <= 1'b0;
        ba    <= bank;
        addr    <= ap;
        @(negedge ck);
    end
endtask

//activate 

task activate( input bit [BA_BITS-1:0] bank,input bit [ROW_BITS-1:0] row);
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b0; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    ba    <= bank;
    addr     <= row;
    @(negedge ck);
end
endtask

// zq calibration

task zq_calibration(input long);
begin
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b0;
    ba    <= 0;
    addr    <= long << 10;
    @(negedge ck);
end
endtask

//nop

task nop(input int unsigned count);
begin
	`uvm_info(m_name,"STARTING DDR3 NO OPERATION",UVM_HIGH)
    cke   <= 1'b1;
    cs_n  <= 1'b0;
    ras_n <= 1'b1; 
    cas_n <= 1'b1;
    we_n  <= 1'b1;
    repeat(count)
    @(negedge ck);
	`uvm_info(m_name,"ENDING DDR3 NO OPERATION",UVM_HIGH)
end
endtask

task write;
    	input   bit [BA_BITS-1:0] bank;
    	input  	bit [ADDR_BITS-1:0] bus_addr;
    	input 	int unsigned  BL;
	input	logic [DQ_BITS-1:0] dq [BL_MAX];
	input	bit [DM_BITS-1:0] dm_v[BL_MAX];
	input 	int unsigned WL; 
	int unsigned  i;
    begin
	$display("B:wl=%0d,bl=%0d",wl,bl);
	`uvm_info(m_name,"STARTING DDR3 WRITE OPERATION",UVM_HIGH)
	wl =  WL;
	bl = BL;
	
	$display("A:wl=%0d,bl=%0d",wl,bl);
	
	if (BL == 'd1) begin 
	`uvm_info(m_name,"SELECTED ON THE FLY PROGRAMMING OF BURST LENGTH",UVM_HIGH)
	if (bus_addr[12] == 1'b1) 
	`uvm_info(m_name,"BL 8 SELECTED",UVM_HIGH)
	else 
	`uvm_info(m_name,"BL 4 SELECTED",UVM_HIGH)
	end
       
	if (bus_addr[10] == 1'b1) 
	`uvm_info(m_name,"AUTO PRECHARGE SELECTED",UVM_HIGH)
	else
	`uvm_info(m_name,"AUTO PRECHARGE NOT SELECTED",UVM_HIGH)

 
	cke   = 1'b1;
        cs_n  = 1'b0;
        ras_n = 1'b1;
        cas_n = 1'b0;
        we_n  = 1'b0;
        ba    = bank;

	
	addr = bus_addr;

	@(negedge ck);

        cas_n = 1'b1;
        we_n  = 1'b1;

	$display("%0t,Waiting for one clock before deassertion\n",$time);
	#(wl*tck-tck/2);
	$display("%0t,Done for one clock before deassertion\n",$time);
        cas_n = 1'b1;
        we_n  = 1'b1;
	
         dqs_en = 1'b1;
         dqs_out = {DQS_BITS{1'b1}};

	 @(posedge ck);
         #(tck/4);
	 //dqs_out = {DQS_BITS{1'b0}};
	 //#(tck/4);
	`uvm_info(m_name,"STARTING DDR3 WRITE DATA BURST",UVM_HIGH)
         for (i=1; i<=bl; i=i+1) begin
	`uvm_info(m_name,$sformatf("SENDING DATA FOR BURST %d",i),UVM_HIGH)
             //#(wl*tck + i*tck/2);
	 dqs_out = {DQS_BITS{1'b0}};
	 #(tck/4);

            //dqs_en = 1'b1;
            // if (i%2 == 0) begin
            //     dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b0}};
            // end else begin
            //     dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b1}};
            // end
	
	     
	     dq_en  =  1'b1;
             dm_out =  dm_v[i];
             dq_out =  dq[i];
	     #(tck/4);
         	dqs_out = {DQS_BITS{1'b1}};
		
	     //dq_en  <= #(wl*tck + i*tck/2 + tck/4) 1'b1;
             //dm_out <= #(wl*tck + i*tck/2 + tck/4) dm_v[i];
             //dq_out <= #(wl*tck + i*tck/2 + tck/4) dq[i];
	     #(tck/4);
         end
         dqs_en = 1'b0;
         dq_en  = 1'b0;
         //dqs_en <= #(wl*tck + bl*tck/2 + tck/2) 1'b0;
         //dq_en  <= #(wl*tck + bl*tck/2 + tck/4) 1'b0;

	//cke   <= 1'b1;
        //cs_n  <= 1'b0;
        //ras_n <= 1'b1;
        //cas_n <= 1'b0;
        //we_n  <= 1'b0;
        //ba    <= bank;

	//
	//addr <= bus_addr;


        // dqs_en <= #(wl*tck-tck/2) 1'b1;
        // dqs_out <= #(wl*tck-tck/2) {DQS_BITS{1'b1}};
        // cs_n  <= #(tck) 1'b1;
	//`uvm_info(m_name,"STARTING DDR3 WRITE DATA BURST",UVM_HIGH)
        // for (i=1; i<=bl; i=i+1) begin
	//`uvm_info(m_name,$sformatf("SENDING DATA FOR BURST %d",i),UVM_HIGH)
        //     #(wl*tck + i*tck/2);
        //     dqs_en <= 1'b1;
        //     if (i%2 == 0) begin
        //         dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b0}};
        //     end else begin
        //         dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b1}};
        //     end
	//
	//      #(wl*tck + i*tck/2 + tck/4);
	//     
	//     dq_en  <=  1'b1;
        //     dm_out <=  dm_v[i];
        //     dq_out <=  dq[i];
	//     //dq_en  <= #(wl*tck + i*tck/2 + tck/4) 1'b1;
        //     //dm_out <= #(wl*tck + i*tck/2 + tck/4) dm_v[i];
        //     //dq_out <= #(wl*tck + i*tck/2 + tck/4) dq[i];
        // end
        //  #(wl*tck + bl*tck/2 + tck/2);
        // dqs_en <= 1'b0;
        // dq_en  <= 1'b0;
        // //dqs_en <= #(wl*tck + bl*tck/2 + tck/2) 1'b0;
        // //dq_en  <= #(wl*tck + bl*tck/2 + tck/4) 1'b0;


	//cke   <= 1'b1;
        //cs_n  <= 1'b0;
        //ras_n <= 1'b1;
        //cas_n <= 1'b0;
        //we_n  <= 1'b0;
        //ba    <= bank;

	//
	//addr <= bus_addr;


        // dqs_en <= #(wl*tck-tck/2) 1'b1;
        // dqs_out <= #(wl*tck-tck/2) {DQS_BITS{1'b1}};
        // cs_n  <= #(tck) 1'b1;
	//`uvm_info(m_name,"STARTING DDR3 WRITE DATA BURST",UVM_HIGH)
        // for (i=0; i<=bl; i=i+1) begin
	//`uvm_info(m_name,$sformatf("SENDING DATA FOR BURST %d",i),UVM_HIGH)
        //     #(wl*tck + i*tck/2);
        //     dqs_en <= 1'b1;
        //     if (i%2 == 0) begin
        //         dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b0}};
        //     end else begin
        //         dqs_out <= #(wl*tck + i*tck/2) {DQS_BITS{1'b1}};
        //     end
	//
	//      #(wl*tck + i*tck/2 + tck/4);
	//     
	//     dq_en  <=  1'b1;
        //     dm_out <=  dm_v[i];
        //     dq_out <=  dq[i];
	//     //dq_en  <= #(wl*tck + i*tck/2 + tck/4) 1'b1;
        //     //dm_out <= #(wl*tck + i*tck/2 + tck/4) dm_v[i];
        //     //dq_out <= #(wl*tck + i*tck/2 + tck/4) dq[i];
        // end
        //  #(wl*tck + bl*tck/2 + tck/2);
        // dqs_en <= 1'b0;
        // dq_en  <= 1'b0;
        // //dqs_en <= #(wl*tck + bl*tck/2 + tck/2) 1'b0;
        // //dq_en  <= #(wl*tck + bl*tck/2 + tck/4) 1'b0;
        @(negedge ck);  
    end
endtask


// WRITE : begin
//     en        = 1'b1;
//     max_count = T_CL-1+3;
//     if(v_count=='d0) begin
//         cont_if_mem.we_n  = 1'b0;											////	WRITE STATE BANK and ADDRESS BIFURCATION  with cas_n= 0
//         cont_if_mem.ba    = s_addr[12:10];
//         cont_if_mem.addr  = {s_addr[9:3],3'b0};
//         cont_if_mem.cas_n = 1'b0;
    

	task sample_ip();

	forever begin //{
	@(posedge ck)

	casex ({rst_n,cke,cs_n,ras_n,cas_n,we_n})
		6'b00???? : begin
			if (reset_asserted == 'b0) begin 	
				ip_mon_trans.CMD = RESET;
				reset_asserted = 1'b1;
				write_pkt = 1'b1;
			end 
				end
		6'b11?111 : begin
				ip_mon_trans.CMD = NOP;
				write_pkt = 1'b1;
		       		end 	

		//default : `uvm_info(m_name,"unknown signals sampled in monitor",UVM_HIGH)
	endcase 
	
	if (write_pkt) begin //{

	`uvm_info(m_name,"Writing the packet to the monitor",UVM_DEBUG)
	`uvm_info(m_name,ip_mon_trans.conv_to_str(),UVM_DEBUG)

	m_ip_mon_h.write_ap(ip_mon_trans);
	write_pkt = 1'b0;
	end //}
	end 	//}
	endtask


endinterface
