
////////////////////////////////////////////////////////////////////////////
//	ddr3_set_reg0_seq.sv - Setting the reg 0 mode and reset sequence if 
//                          someone wants to run the mode individually
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////

class ddr3_set_reg0_seq extends uvm_sequence #(ddr3_seq_item);
		`uvm_object_utils(ddr3_set_reg0_seq)

		string m_name = "DDR3_SET_REG0_SEQ";
		
		// handle 
		ddr3_rst_seq m_rst_seq;				// reset
		ddr3_mode_reg0_seq m_mode_reg_0_seq;		//reg 0 seq

		function new (string name = m_name);
		super.new(name);
		endfunction			//new


		task body;
		begin
			m_rst_seq = ddr3_rst_seq::type_id::create("m_rst_seq");
			m_mode_reg_0_seq = ddr3_mode_reg0_seq::type_id::create("m_mode_reg_0_seq");
			
			`uvm_info(m_name,"Starting reset sequence",UVM_HIGH)			// reset seq
			m_rst_seq.start(null,this);
			
			`uvm_info(m_name,"Starting mode reg 0 sequence",UVM_HIGH)		// mode 0 seq
			m_mode_reg_0_seq.start(null,this);
		end
		endtask
		

		
endclass
