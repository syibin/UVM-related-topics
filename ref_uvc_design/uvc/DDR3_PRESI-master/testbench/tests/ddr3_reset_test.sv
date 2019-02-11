/// reset test

////////////////////////////////////////////////////////////////////////////
//	mode_reset_test.sv - A reset test for verifying the reset sequence
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////


class ddr3_reset_test extends ddr3_base_test;
`uvm_component_utils(ddr3_reset_test)

string m_name = "DDR3_RESET_TEST";

ddr3_rst_seq m_reset_seq;

function new(string name = m_name,uvm_component parent = null);
	super.new(name,parent);
endfunction					// new function


task run_phase(uvm_phase phase);
begin
       m_reset_seq = ddr3_rst_seq::type_id::create("m_reset_seq");

	phase.raise_objection(this,$sformatf("%s:Starting sequence m_reset_seq",m_name));
	m_reset_seq.start(m_env.m_sequencer);
	phase.drop_objection(this,$sformatf("%s:Done driving the sequence",m_name));	
end 
endtask 				// run phase


endclass
