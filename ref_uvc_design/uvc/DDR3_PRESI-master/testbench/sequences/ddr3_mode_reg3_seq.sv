//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_mode_reg3_seq.sv -  A sequence for doing Precharge and Configuring mode 3 registers operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
class ddr3_mode_reg3_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_mode_reg3_seq)


	string m_name = "DDR3_MODE_REG3_SEQ";
	
	ddr3_seq_item ddr3_tran;

	mode_reg_3 reg_3;


	function new(string name = m_name);
		super.new(name);
	endfunction								// new funtion


	task body;

		`uvm_info(m_name,"creating and sending sequence item",UVM_HIGH)
		
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		ddr3_tran.CMD = PRECHARGE;
		ddr3_tran.row_addr = 14'b00010000000000; //all banks active
		ddr3_tran.bank_sel = 3'b111; //will be taken as don't care 
		finish_item(ddr3_tran);

		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		ddr3_tran.CMD = NOP;
		ddr3_tran.num_nop = ceil(TRP/TCK_MIN); 
		finish_item(ddr3_tran);

		`uvm_info(m_name,"configuring the Mode 0 register",UVM_HIGH)
		reg_3 = mode_reg_3::type_id::create("reg_3");
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		assert(reg_3.randomize())
		`uvm_info(m_name,reg_3.conv_to_str(),UVM_HIGH)
		ddr3_tran.CMD = MSR;
		ddr3_tran.mode_cfg = reg_3.pack();
		finish_item(ddr3_tran);


		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		start_item(ddr3_tran);
		ddr3_tran.CMD = NOP;
		ddr3_tran.num_nop = ceil(TMRD); 
		finish_item(ddr3_tran);

	endtask 

endclass
