////



class ddr3_coverage extends uvm_subscriber#(ddr3_seq_item);
`uvm_component_utils(ddr3_coverage)

string m_name = "DDR3_COVERAGE";

ddr3_seq_item cov_trans;	

    covergroup group_1;                    

        cov_cmd: coverpoint cov_trans.CMD;                               
        
        cov_ba: coverpoint cov_trans.mode_cfg.ba;
        cov_bus_addr: coverpoint cov_trans.mode_cfg.bus_addr;

        cov_ba_addr: cross cov_ba,cov_bus_addr;

        
    endgroup

    covergroup group_2;                      
        
        cov_row_addr: coverpoint cov_trans.row_addr;
        cov_bank_sel: coverpoint cov_trans.bank_sel;
        cov_col_addr: coverpoint cov_trans.col_addr;
        
        cov_row_bank_col: cross cov_row_addr,cov_bank_sel,cov_col_addr;

    endgroup
function new(string name = m_name,uvm_component parent = null);
	super.new(name,parent);
	group_1 = new();
	group_2 = new();
endfunction 


function void write(T t);

	cov_trans = new("cov_trans");
	cov_trans.copy(t);
	`uvm_info(m_name,cov_trans.conv_to_str(),UVM_HIGH);
	group_1.sample();
	group_2.sample();

	

endfunction 





endclass
