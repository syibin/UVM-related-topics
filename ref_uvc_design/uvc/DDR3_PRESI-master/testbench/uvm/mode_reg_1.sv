//mode register 1

////////////////////////////////////////////////////////////////////////////
//	mode_reg_1.sv - Setting the mode reg sequence 1 by adding constraints
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////
class mode_reg_1 extends uvm_object;
`uvm_object_utils(mode_reg_1)

string m_name_1 = "MODE_REG_1";

// Variables inside the mode_reg_1
bit  [2:0] BA=3'b001;
rand    bit      DLL;
rand   bit [1:0] ODS;
rand    bit [1:0] AL;
rand     bit   Q_off;
rand       bit  TQDS;
bit        RSV =1'b0;
rand  bit [2:0] R_TT; 
rand          bit WL;


function new(string name = m_name_1);
super.new(name);
endfunction


//constraint DLL_c_1   { DLL == 1'b1;  }        // Disable Normal
constraint DLL_c_1   { DLL == 1'b0;  }        // Disable Normal
constraint ODSL_c_1  { ODS == 2'b00; }        // RZQ/6(40 ohm(NOM))
constraint AL_c_1    { AL == 2'b00;  }        // Disabled
constraint Q_off_c_1 { Q_off == 1'b0;}        // Enabled
constraint R_TT_c_1  { R_TT == 3'b001;}       // RZQ/4   
constraint TDQS_c_1  { TQDS == 1'b0; }        // 1'b0
constraint WL_c_1    { WL == 1'b0;   }        // 1'b0 


function cfg_mode_reg_t pack;
    return {BA,RSV,Q_off,TQDS,RSV,R_TT[2],RSV,WL,R_TT[1],ODS[1],AL,R_TT[0],ODS[0],DLL};
endfunction 

function void unpack(cfg_mode_reg_t reg_cfg);
    {BA,RSV,Q_off,TQDS,RSV,R_TT[2],RSV,WL,R_TT[1],ODS[1],AL,R_TT[0],ODS[0],DLL} = reg_cfg;
endfunction 

function string conv_to_str();
    conv_to_str = $sformatf("MODE_REG_1:BA:%b,Q_off:%b,TDQS:%b,R_TT:%b,WL:%b,ODS:%b,AL:%b,DLL:%b",BA,Q_off,TQDS,R_TT,WL,ODS,AL,DLL);
endfunction


endclass 
