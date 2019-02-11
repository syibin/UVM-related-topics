//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_write_seq.sv -  A sequence for doing Write operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


class ddr3_write_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_write_seq)

	string m_name = "DDR3_WRITE_SEQ";

	ddr3_seq_item ddr3_tran,ddr3_tran_nop;
	
	function new (string name = m_name);
		super.new(name);
	endfunction 

	// body task
	task body;
		`uvm_info(m_name,"Starting WRITE sequence",UVM_HIGH)
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");
		ddr3_tran_nop = ddr3_seq_item::type_id::create("ddr3_tran_nop");

	
		start_item(ddr3_tran);									// start the transaction
		assert(ddr3_tran.randomize())					// randomize 
		ddr3_tran.CMD = ACTIVATE;
		`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH);
		finish_item(ddr3_tran);
		
		start_item(ddr3_tran_nop);									// start the transaction
		ddr3_tran_nop.CMD = NOP;
		ddr3_tran_nop.num_nop = ceil(TRCD/TCK_MIN);
		finish_item(ddr3_tran_nop);									// start the transaction



		start_item(ddr3_tran);									// start the transaction
		ddr3_tran.CMD = WRITE;									// transaction of Write command
		`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH);
		finish_item(ddr3_tran);									// end of transaction
		
		
		start_item(ddr3_tran_nop);									// start the transaction
		ddr3_tran_nop.CMD = NOP;
		ddr3_tran_nop.num_nop = 20000;
		finish_item(ddr3_tran_nop);									// start the transaction
	
	endtask 

endclass

