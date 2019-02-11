
////////////////////////////////////////////////////////////////////////////
//	ddr3_set_reg1_seq.sv - Setting the reg 1 mode and reset sequence if 
//                          someone wants to run the mode individually
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////
class ddr3_set_reg1_seq extends uvm_sequence #(ddr3_seq_item);
    `uvm_object_utils(ddr3_set_reg1_seq)

    string m_name = "DDR3_SET_REG1_SEQ";
    
    ddr3_rst_seq m_rst_seq;         //handle for reset
    ddr3_mode_reg1_seq m_mode_reg_1_seq;            // mode reg 1

    function new (string name = m_name);
    super.new(name);
    endfunction         // new function


    task body;
    begin
        m_rst_seq = ddr3_rst_seq::type_id::create("m_rst_seq");
        m_mode_reg_1_seq = ddr3_mode_reg1_seq::type_id::create("m_mode_reg_1_seq");
        `uvm_info(m_name,"Starting reset sequence",UVM_HIGH)                // reset seq
        m_rst_seq.start(null,this);
        `uvm_info(m_name,"Starting mode reg 1 sequence",UVM_HIGH)           // mode 1 seq
        m_mode_reg_1_seq.start(null,this);
    end
    endtask
    

    
endclass
