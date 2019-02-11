//environment//
////////////////////////////////////////////////////////////////////////////
//	ddr3_env.sv - AN UVM Environment 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////


class ddr3_env extends uvm_env;
	`uvm_component_utils(ddr3_env)

	string m_name = "DDR3_ENV";


	ddr3_tb_driver m_driver;		//driver
	ddr3_sequencer m_sequencer;		// sequencer
	ddr3_input_monitor m_ip_mon;
	ddr3_coverage m_cov;


	function new(string name = m_name,uvm_component parent = null);
		super.new(name,parent);
	endfunction 					// new function

	
	function void build_phase(uvm_phase phase);

		super.build_phase(phase);

		m_driver = ddr3_tb_driver::type_id::create("m_driver",this);
		m_sequencer = ddr3_sequencer::type_id::create("m_sequencer",this);
		m_ip_mon = ddr3_input_monitor::type_id::create("m_ip_mon",this);
		m_cov = ddr3_coverage::type_id::create("m_cov",this);

	endfunction 					// build phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		m_ip_mon.ip_mon_ap.connect(m_cov.analysis_export);
	endfunction 
									// connect phase

endclass
