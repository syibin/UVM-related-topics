
////////////////////////////////////////////////////////////////////////////
//	ddr3_tb_reg_model.sv - Setting the all mode reg sequence 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////


class ddr3_tb_reg_model extends uvm_object;
	`uvm_object_utils(ddr3_tb_reg_model)

	string m_name = "DDR3_TB_REG_MODEL";

	// handle for all mode 
	mode_reg_0 reg0;
	mode_reg_1 reg1;
	mode_reg_2 reg2;
	mode_reg_3 reg3;



	function new(string name=m_name);
		super.new(name);
		reg0 = mode_reg_0::type_id::create("reg0");
		reg1 = mode_reg_1::type_id::create("reg1");
		reg2 = mode_reg_2::type_id::create("reg2");
		reg3 = mode_reg_3::type_id::create("reg3");
		assert(reg0.randomize());
		assert(reg1.randomize());
		assert(reg2.randomize());
		assert(reg3.randomize());
	endfunction				// new function

	// Load the model by seeing the bank and unpack it
	function void load_model(input cfg_mode_reg_t reg_cfg);
		case (reg_cfg.ba) 
			2'b00: reg0.unpack(reg_cfg);
			2'b01: reg1.unpack(reg_cfg);
			2'b10: reg2.unpack(reg_cfg);
			2'b11: reg3.unpack(reg_cfg);
			default: `uvm_error(m_name,"WRONG MODE SELECTED")
		endcase 
	endfunction

	function string conv_to_str();
		conv_to_str = $sformatf("%s: List of REGS and configurations\n\t\t%s\n\t\t%s\n\t\t%s\n\t\t%s",
					m_name,reg0.conv_to_str(),reg1.conv_to_str(),reg2.conv_to_str(),reg3.conv_to_str());
	endfunction 


endclass
