//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_mode_reg1_seq.sv -  A sequence for doing Precharge and Configuring mode 1 registers operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

class ddr3_mode_reg1_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_mode_reg1_seq)


	string m_name = "DDR3_MODE_REG1_SEQ";
	
	ddr3_seq_item ddr3_tran;

	mode_reg_1 reg_1;


	function new(string name = m_name);
		super.new(name);
	endfunction								// new funtion


	task body;

		`uvm_info(m_name,"creating and sending sequence item",UVM_HIGH)
		
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");            // Precharge
		start_item(ddr3_tran);
		ddr3_tran.CMD = PRECHARGE;
		ddr3_tran.row_addr = 14'b00010000000000; //all banks active
		ddr3_tran.bank_sel = 3'b111; //will be taken as don't care 
		finish_item(ddr3_tran);

		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");            // No operation 
		start_item(ddr3_tran);
		ddr3_tran.CMD = NOP;
		ddr3_tran.num_nop = ceil(TRP/TCK_MIN); 
		finish_item(ddr3_tran);

		`uvm_info(m_name,"configuring the Mode 1 register",UVM_HIGH)        // s
		reg_1 = mode_reg_1::type_id::create("reg_1");
		 ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		assert(reg_1.randomize())
		`uvm_info(m_name,reg_1.conv_to_str(),UVM_HIGH)
		ddr3_tran.CMD = MSR;
		ddr3_tran.mode_cfg = reg_1.pack();
		finish_item(ddr3_tran);


		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		ddr3_tran.CMD = NOP;
		ddr3_tran.num_nop = ceil(TMRD); 
		finish_item(ddr3_tran);

	endtask 

endclass

