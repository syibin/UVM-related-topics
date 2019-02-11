
////////////////////////////////////////////////////////////////////////////
//	ddr3_set_reg3_seq.sv - Setting the reg 3 mode and reset sequence if 
//                          someone wants to run the mode individually
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////

class ddr3_set_reg3_seq extends uvm_sequence #(ddr3_seq_item);
    `uvm_object_utils(ddr3_set_reg3_seq)

    string m_name = "DDR3_SET_REG3_SEQ";
    
    ddr3_rst_seq m_rst_seq;
    ddr3_mode_reg3_seq m_mode_reg_3_seq;

    function new (string name = m_name);
    super.new(name);
    endfunction         // new function

    // body task
    task body;
    begin
        m_rst_seq = ddr3_rst_seq::type_id::create("m_rst_seq");
        m_mode_reg_3_seq = ddr3_mode_reg3_seq::type_id::create("m_mode_reg_3_seq");

        `uvm_info(m_name,"Starting reset sequence",UVM_HIGH)        // reset sequence
        m_rst_seq.start(null,this);
        `uvm_info(m_name,"Starting mode reg 3 sequence",UVM_HIGH)       // reg 3 mode
        m_mode_reg_3_seq.start(null,this);
    end
    endtask
    

    
endclass
