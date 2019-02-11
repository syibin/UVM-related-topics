

///////


class ddr3_input_monitor extends uvm_monitor;
`uvm_component_utils(ddr3_input_monitor)


	uvm_analysis_port #(ddr3_seq_item) ip_mon_ap; 


string m_name = "DDR3_INPUT_MONITOR";

	
	virtual ddr3_interface m_intf;


	ddr3_seq_item ip_mon_trans;

function new(string name = m_name, uvm_component parent = null);
	super.new(name,parent);
	ip_mon_ap = new("ip_mon_ap",this);
	ip_mon_trans = ddr3_seq_item::type_id::create("ip_mon_trans");
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	    assert(uvm_config_db #(virtual ddr3_interface)::get(null,"uvm_test_top","DDR3_interface",m_intf)) `uvm_info(m_name,"Got the interface in Monitor",UVM_HIGH)
	    m_intf.m_ip_mon_h = this;
endfunction


task run_phase(uvm_phase phase);

	`uvm_info(m_name,"Starting the input monitor",UVM_HIGH)
		m_intf.sample_ip();
endtask

task write_ap(ddr3_seq_item m_inf_pkt);

	ip_mon_trans.copy(m_inf_pkt);
	
	`uvm_info(m_name,"Got packet from the interface",UVM_DEBUG)

	`uvm_info(m_name,ip_mon_trans.conv_to_str(),UVM_HIGH)

	`uvm_info(m_name,"Writing the packet to the Analysis Port",UVM_DEBUG)


	ip_mon_ap.write(ip_mon_trans);
endtask


endclass
