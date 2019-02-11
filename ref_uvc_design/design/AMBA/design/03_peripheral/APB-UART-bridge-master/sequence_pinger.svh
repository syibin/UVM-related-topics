`ifndef SEQUENCE_PINGER_SVH
`define SEQUENCE_PINGER_SVH
// Use in sequence to get pinged when its time to send in the reqs
// Copied many parts of this code :P
class sequence_pinger extends uvm_object;
  `uvm_object_utils(sequence_pinger)

  int wait_cycles_min; // wait x cyles where x:[max,min]
  int wait_cycles_max;
  
  int burst_count_min; // # of reqs in a burst before moving back into wait mode
  int burst_count_max;

  int burst_spacing_min; // cycles between reqs
  int burst_spacing_max;

  int burst_en;

  event ping;
  
  int wait_ctr;
  int burst_ctr;

  function new(string name = "sequence_pinger", int wait_cycles_max, int wait_cycles_min,
               int burst_count_max, int burst_count_min, int burst_spacing_max,
			   int burst_spacing_min, int burst_en
			  );
    super.new(name);
    this.wait_cycles_max   = wait_cycles_max;
    this.wait_cycles_min   = wait_cycles_min;
	this.burst_count_min   = burst_count_min;
	this.burst_count_max   = burst_count_max;
	this.burst_en          = burst_en;
	this.burst_spacing_max = burst_spacing_max;
	this.burst_spacing_min = burst_spacing_min;
	configure_ctrs();
  endfunction
  
  task waiter();
    wait_ctr = wait_ctr - 1;
	if (!wait_ctr) begin
	  ->ping;
	  burst_ctr = burst_ctr - 1;
	  configure_ctrs();
	end
  endtask
  
  function void configure_ctrs ();
    if (burst_ctr) begin
	  wait_ctr = $urandom_range(burst_spacing_max, burst_spacing_min);
	end
	else begin
	  wait_ctr = $urandom_range(wait_cycles_max, wait_cycles_min);
	  if (burst_en) begin
	    burst_ctr = $urandom_range(burst_count_max, burst_count_min);
	  end
	  else begin
	    burst_ctr = 1;
	  end
	end
  endfunction

endclass

`endif


