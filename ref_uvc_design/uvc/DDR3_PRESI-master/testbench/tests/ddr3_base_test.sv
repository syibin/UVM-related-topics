
class ddr3_base_test extends uvm_test;
`uvm_component_utils(ddr3_base_test)

string m_name = "DDR3_BASE_TEST";
	
ddr3_env m_env;
ddr3_tb_reg_model m_reg_model;

function new(string name = m_name,uvm_component parent=null);
	super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_reg_model = ddr3_tb_reg_model::type_id::create("m_reg_model");
	uvm_config_db #(ddr3_tb_reg_model)::set(this,"*","reg_model",m_reg_model);
	m_env = ddr3_env::type_id::create("m_env",this);
endfunction


endclass
