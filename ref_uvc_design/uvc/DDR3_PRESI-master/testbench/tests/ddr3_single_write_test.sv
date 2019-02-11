
//////////////////////////////////////////////////////////////////////////////////////////////////
//	ddr3_single_write_test.sv -  A sequence for doing Write operation 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

class ddr3_single_write_test extends ddr3_base_test;
	`uvm_component_utils(ddr3_single_write_test)

	string m_name = "DDR3_SINGLE_WRITE_TEST";

	ddr3_write_test_seq m_write_seq;
	
	function new (string name=m_name,uvm_component parent =null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);

		m_write_seq = ddr3_write_test_seq::type_id::create("m_write_seq");
		phase.raise_objection(this,$sformatf("%s:Starting m_write_seq",m_name));
		`uvm_info(m_name,"Starting Single write test",UVM_HIGH)
		m_write_seq.start(m_env.m_sequencer);
		phase.drop_objection(this,$sformatf("%s:Done with  m_write_seq",m_name));

	endtask 
	

endclass
