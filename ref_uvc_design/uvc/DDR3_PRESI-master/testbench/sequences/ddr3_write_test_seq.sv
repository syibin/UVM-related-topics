
//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_write_test_seq.sv -  A sequence for doing Write operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


class ddr3_write_test_seq extends uvm_sequence #(ddr3_seq_item);
	`uvm_object_utils(ddr3_write_test_seq)

	string m_name = "DDR3_WRITE_TEST_SEQ";
	
	ddr3_set_all_reg_seq m_config_reg_seq;
	ddr3_write_seq m_write_seq;

	function new (string name = m_name);
		super.new(name);
	endfunction 
	
	task body;
        `uvm_info(m_name,"Starting RESET,CONFIGURING MODES and single WRITE data sequence",UVM_HIGH)

		m_config_reg_seq = ddr3_set_all_reg_seq::type_id::create("m_config_reg_seq");
		m_write_seq = ddr3_write_seq::type_id::create("m_write_seq");

        `uvm_info(m_name,"Starting RESET and CONFIGURING MODES",UVM_HIGH)
		m_config_reg_seq.start(null,this);
        `uvm_info(m_name,"Writing single data",UVM_HIGH)
		m_write_seq.start(null,this);



	endtask 
	
endclass

