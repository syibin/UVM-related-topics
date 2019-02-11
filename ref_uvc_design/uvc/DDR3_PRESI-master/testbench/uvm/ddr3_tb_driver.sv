//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_tb_driver.sv -  Driver takes the value from the sequencer and 
//						depending upon the sequence various controller task are performed 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////



class ddr3_tb_driver extends uvm_driver#(ddr3_seq_item);
	`uvm_component_utils(ddr3_tb_driver)

	string m_name = "DDR3_TB_DRIVER";
	    
	u_int_t cl,bl,cwl,al,rl,wl;

	virtual ddr3_interface m_intf; 	//interface
	ddr3_tb_reg_model reg_model_h;

    function new(string name = m_name, uvm_component parent = null);
	    super.new(name,parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
	    super.build_phase(phase);
 
	    assert(uvm_config_db #(virtual ddr3_interface)::get(null,"uvm_test_top","DDR3_interface",m_intf)) `uvm_info(m_name,"Got the interface in driver",UVM_HIGH)
	    assert(uvm_config_db #(ddr3_tb_reg_model)::get(this,"","reg_model",reg_model_h)) `uvm_info(m_name,"Got the handle for REG MODEL",UVM_HIGH)

    endfunction

	//run phase
    task run_phase(uvm_phase phase);

	    ddr3_seq_item ddr3_tran;
		
		
	    forever begin 
			
			// handshake with the sequencer to take the transaction from the sequencer
		    seq_item_port.get_next_item(ddr3_tran);
		    phase.raise_objection(this,$sformatf("%s:Got a transaction from the sequencer",m_name));
			`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH)
			case (ddr3_tran.CMD)
				
				RESET: begin				// Reset and Poer up performs the same function
					m_intf.power_up();
				end

				PRECHARGE: begin			// Precharge 
					m_intf.precharge(ddr3_tran.bank_sel,ddr3_tran.row_addr);	
					end 
				
				ZQ_CAL_L: begin				// Calibration task
					m_intf.zq_calibration(1);
					m_intf.nop(512);
				end

				MSR: begin
					reg_model_h.load_model(ddr3_tran.mode_cfg);
					m_intf.load_mode(ddr3_tran.mode_cfg.ba, ddr3_tran.mode_cfg.bus_addr);
					void'(calc_latencies());
					`uvm_info(m_name,reg_model_h.conv_to_str(),UVM_HIGH)
					
				end

				NOP: begin					// no operation
					//m_intf.nop(10);
					m_intf.nop(ddr3_tran.num_nop);
				end

				//WRITE: begin				// Write operation
				//	m_intf.write(ddr3_tran.bank_sel, ddr3_tran.col_addr,0,0,0,ddr3_tran.row_addr);
				//end

				ACTIVATE: begin 
					m_intf.activate(ddr3_tran.addr_proc.bank,ddr3_tran.addr_proc.row);
					end

				WRITE: begin 
					if (bl == 'd1) `uvm_info(m_name,"On the fly burst mode enabled",UVM_HIGH)
					if (bl == 'd0) bl = 'd8;
					if (bl == 'd2) bl = 'd4;
					
					m_intf.write(ddr3_tran.wr_rd_cmd_addr.ba,ddr3_tran.wr_rd_cmd_addr.bus_addr,bl,ddr3_tran.data_proc,ddr3_tran.dm,wl);
				end 

		    endcase 

		    seq_item_port.item_done();

		    phase.drop_objection(this,$sformatf("%s:Done Transfer",m_name));	// Drop the objection once completed

	    end //}

	endtask

	function void calc_latencies();
			cl = reg_model_h.reg0.CAS + 4;
			bl = reg_model_h.reg0.BL;
			cwl = reg_model_h.reg2.CWL + 5;
			al = (reg_model_h.reg1.AL == 0) ? 'h0 : cl - reg_model_h.reg1.AL;
			rl = cl + al;
			wl = cwl + al;
	endfunction 	
	
endclass //ddr3_tb_driver extends uvm_drive
