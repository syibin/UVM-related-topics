`ifndef APB_SEQUENCE_SVH
`define APB_SEQUENCE_SVH
class apb_sequence extends uvm_sequence #(REQ = apb_seq_item);
  `uvm_object_utils(apb_sequence)
  `uvm_declare_p_sequencer(testbench_pkg::apb_seqr)

  sequence_pinger pinger;
  int wait_cycles_min; // wait x cyles where x:[max,min]
  int wait_cycles_max;
  
  int burst_count_min; // # of reqs in a burst before moving back into wait mode
  int burst_count_max;

  int burst_spacing_min; // cycles between reqs
  int burst_spacing_max;

  int burst_en; 
  function new(string name = "apb_sequence");
    super.new(name);
  endfunction
 
  function void randomize_traffic_mode();
    testbench_pkg::traffic_e_t traffic_mode;
    randcase
	  1: traffic_mode = testbench_pkg::NORMAL;
	  0: traffic_mode = testbench_pkg::BURST;
	endcase
	if (traffic_mode == testbench_pkg::NORMAL) begin
	  wait_cycles_min = 100;
	  wait_cycles_max = 200;
	  burst_count_min = 0;
	  burst_count_max = 0;
	  burst_spacing_min = 0;
	  burst_spacing_max = 0;
      burst_en = 0;
	end
	else begin
	  wait_cycles_min = 100;
	  wait_cycles_max = 200;
	  burst_count_min = 2;
	  burst_count_max = 6;
	  burst_spacing_min = 0;
	  burst_spacing_max = 10;
      burst_en = 1;
	end
  endfunction
 
  task body();
    super.body();
	randomize_traffic_mode();
	pinger = new("pinger",wait_cycles_max,wait_cycles_min, burst_count_max, burst_count_min,
	             burst_spacing_max,burst_spacing_min,burst_en);
	// TODO: ADD initialization sequence
    fork : f1
	  forever begin
	    p_sequencer.wait_clocks(1);
		pinger.waiter();
	  end
	  forever begin
	    @(pinger.ping);
		send_apb_request();
	  end
	  forever begin
	    wait(p_sequencer.end_stimulus);
	  end
    join_any
    disable f1;
  endtask

  task send_apb_request();
    
  endtask
  
endclass
`endif
