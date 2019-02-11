

class ddr3_read_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_read_seq)

	string m_name = "DDR3_READ_SEQ";

	ddr3_seq_item ddr3_tran;
	
	function new (string name = m_name);
		super.new(name);
	endfunction 

	task body;
		`uvm_info(m_name,"Starting READ sequence",UVM_HIGH)
		ddr3_tran = ddr3_seq_item::type_id::create("ddr3_tran");

		start_item(ddr3_tran);
		assert(ddr3_tran.randomize())
		ddr3_tran.CMD = READ;
		`uvm_info(m_name,ddr3_tran.conv_to_str(),UVM_HIGH);
		finish_item(ddr3_tran);
	
	endtask 

endclass