//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_rst_seq.sv -  A sequence for doing Reset or Power UP operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

class ddr3_rst_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_rst_seq)

	string m_name = "DDR3_RST_SEQ";

	ddr3_seq_item ddr3_tran;
	
	function new (string name = m_name);
		super.new(name);
	endfunction 							//new

	task body;
		`uvm_info(m_name,"Starting RESET sequence",UVM_HIGH)
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");

		start_item(ddr3_tran);				// Start the transaction
		assert(ddr3_tran.randomize())		// Randomize
		ddr3_tran.CMD = RESET;				// Issue Reset Command
		`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH);
		finish_item(ddr3_tran);				// End the transaction
	
		start_item(ddr3_tran);				// Start the transaction
		// assert(ddr3_tran.randomize())		// Randomize
		ddr3_tran.CMD = ZQ_CAL_L;				// Issue Reset Command
		`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH);
		finish_item(ddr3_tran);	
	endtask 

endclass

