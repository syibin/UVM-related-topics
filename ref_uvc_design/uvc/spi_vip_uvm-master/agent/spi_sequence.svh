class spi_sequence extends uvm_sequence #(spi_item);

    //Registration macro
    `uvm_object_utils(spi_sequence)
    
    //Constructor
    function new(string name = "spi_sequence");
        super.new(name);
    endfunction
    
    //Body task
    task body;
        spi_item item;
        
        repeat (10) begin
            item = spi_item::type_id::create("item");
            start_item(item);
            assert(item.randomize());
            finish_item(item);
        end

    endtask
    
endclass
    
    