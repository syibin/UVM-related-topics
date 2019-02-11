`ifndef APB_SEQ_ITEM
`define APB_SEQ_ITEM
class apb_seq_item extends uvm_sequence_item;
  
  rand bit write;
  rand bit [3:0] addr;
  rand bit [`DATA_WIDTH-1:0] data;
  
  `uvm_object_utils_begin
    `uvm_field_int(write,UVM_DEFAULT)
	`uvm_field_int(addr,UVM_DEFAULT)
	`uvm_field_int(data,UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new (string name = "apb_seq_item");
    super.new(name);
  endfunction
  
endclass
`endif