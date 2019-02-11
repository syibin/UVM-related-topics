//////////////////////////////////////////////////////////////////////////////////////////////////
//	mode_reg_0.sv -  A sequence item which iclues the signals and the commands of controller
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


class mode_reg_0 extends uvm_object;
`uvm_object_utils(mode_reg_0)

string m_name="MODE_REG_0";

bit RSV='b0;
rand bit [1:0]BL;
// rand bit CL;
rand bit BT;
rand bit [3:0]CAS;
rand bit DLL;
rand bit [2:0]WR;
rand bit PD;
bit [2:0]BA = 3'b000;



function new(string name = m_name);
    super.new(name);
endfunction


constraint BL_c { BL == 2'b00; }
// constraint CL_c { CL == 1'b1; }
constraint BT_c { BT == 1'b0; }
constraint CAS_c { CAS == CWL_MIN; }
constraint DLL_c { DLL == 1'b1; }
constraint WR_c { WR == WR_MIN; }
constraint PD_c { PD == 1'b0; }


function cfg_mode_reg_t pack;
    return {BA,RSV,PD,WR,DLL,RSV,CAS[3:1],BT,CAS[0],BL};
endfunction 

function void unpack(input cfg_mode_reg_t reg_cfg);
	{BA,RSV,PD,WR,DLL,RSV,CAS[3:1],BT,CAS[0],BL} = reg_cfg;
endfunction 


function string conv_to_str();
    conv_to_str = $sformatf("%s:BL:%b,BT:%b,CAS:%b,DLL:%b,WR:%b,PD:%b",m_name,BL,BT,CAS,DLL,WR,PD);
endfunction


endclass 
