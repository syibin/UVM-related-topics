//sequencer//

////////////////////////////////////////////////////////////////////////////
//	ddr3_sequencer.sv - Sequencer between the sequences and driver 
//
//	Author:		Ashwin Harathi, Kirtan Mehta, Mohammad Suheb Zameer
//
///////////////////////////////////////////////////////////////////////////////


class ddr3_sequencer extends uvm_sequencer #(ddr3_seq_item,ddr3_seq_item);
		`uvm_component_utils(ddr3_sequencer)

			function new(string name = "ddr3_sequencer",uvm_component parent = null);
				super.new(name,parent);
			endfunction 
endclass
