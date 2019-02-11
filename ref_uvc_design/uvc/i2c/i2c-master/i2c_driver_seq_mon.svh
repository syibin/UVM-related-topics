//----------------------------------------------------
// This file contains the APB Driver, Sequencer and Monitor component classes defined
//----------------------------------------------------
`ifndef APB_DRV_SEQ_MON_SV
`define APB_DRV_SEQ_MON_SV

typedef apb_config;
typedef apb_agent;

//---------------------------------------------
// APB master driver Class  
//---------------------------------------------
class apb_master_drv extends uvm_driver#(seqMult_seq);
  
  `uvm_component_utils(apb_master_drv)
   
   virtual seqMult_if seqMultvif;
   apb_config cfg;

   function new(string name,uvm_component parent = null);
      super.new(name,parent);
   endfunction

   //Build Phase
   //Get the virtual interface handle form the agent (parent ) or from config_db
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     if(!uvm_config_db#(virtual seqMult_if)::get(this,"","seqMultvif",seqMultvif)) begin
       `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
     end
   endfunction

  task pre_reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    uvm_report_info(get_full_name(), "PRERESET_BEG", UVM_LOW);
    //uvm_report_info("CLK1", $sformatf("%0b", this.seqMultvif.sig_clk));
    seqMultvif.sig_rst = 1'b1;
    #10;
    phase.drop_objection(this);
    uvm_report_info(get_full_name(), "PRERESET_END", UVM_LOW);
    //uvm_report_info("CLK2", $sformatf("%0b", this.seqMultvif.sig_clk));
  endtask:pre_reset_phase
  
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    uvm_report_info(get_full_name(), "RESET_BEG", UVM_LOW);
    //uvm_report_info("CLK3", $sformatf("%0b", this.seqMultvif.sig_clk));
    //uvm_report_info("ab_ready 1", $sformatf("%0b", this.seqMultvif.sig_ab_ready));
    seqMultvif.sig_rst = 1'b0;
    #11;
    seqMultvif.sig_rst = 1'b1;
    //#6;
    //uvm_report_info("CLK4", $sformatf("%0b", this.seqMultvif.sig_clk));
    //uvm_report_info("ab_ready 2", $sformatf("%0b", this.seqMultvif.sig_ab_ready));
    phase.drop_objection(this);
    uvm_report_info(get_full_name(), "RESET_END", UVM_LOW);
  endtask:reset_phase
  
   //Run Phase
   //Implement the Driver -Sequencer API to get an item
   //Based on if it is Read/Write - drive on APB interface the corresponding pins
   virtual task main_phase(uvm_phase phase);
     seqMult_seq seq_item;
     super.run_phase(phase);
     forever begin
       phase.raise_objection( .obj( this ), .description( get_name() ) );
       //uvm_report_info(get_full_name(), "This is a Test.", UVM_LOW);
       
       seq_item_port.get_next_item(seq_item);  //Communicates with the Sequencer
              
       //uvm_report_info(get_full_name(), "This is a Test 2.", UVM_LOW);
       //uvm_report_info("a", $sformatf("%0d", seq_item.a));
       //uvm_report_info("b", $sformatf("%0d", seq_item.b));
       //uvm_report_info("ab_valid", $sformatf("%0d", seq_item.ab_valid));
       
       //uvm_report_info("CLK5", $sformatf("%0b", this.seqMultvif.sig_clk));
       
       @(negedge this.seqMultvif.sig_clk) 
       begin
       //    uvm_report_info(get_full_name(), "This is a Test 3.", UVM_LOW);
           this.seqMultvif.sig_a = seq_item.a;
           this.seqMultvif.sig_ab_valid = seq_item.ab_valid;
           this.seqMultvif.sig_b = seq_item.b;
       end
       //@(posedge this.seqMultvif.sig_clk) 
       //begin
       //	   uvm_report_info(get_full_name(), "This is a Test 4.", UVM_LOW);
       //  if (this.seqMultvif.sig_ab_valid && this.seqMultvif.sig_ab_ready) begin
       //      this.seqMultvif.sig_a_real = seqMultvif.sig_a;
       //      this.seqMultvif.sig_b_real = seqMultvif.sig_b;
       //  end
       //end
       phase.drop_objection( .obj( this ), .description( get_name() ) );
       seq_item_port.item_done();
     end
   endtask: main_phase

endclass: apb_master_drv

//---------------------------------------------
// APB Sequencer Class  
//  Derive form uvm_sequencer and parameterize to apb_rw sequence item
//---------------------------------------------
class apb_sequencer extends uvm_sequencer #(seqMult_seq);

   `uvm_component_utils(apb_sequencer)
 
   function new(input string name, uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

endclass : apb_sequencer

//-----------------------------------------
// APB Monitor class  
//-----------------------------------------
class apb_monitor extends uvm_monitor;

  virtual seqMult_if seqMultvif;

  //Analysis port -parameterized to apb_rw transaction
  ///Monitor writes transaction objects to this port once detected on interface
  uvm_analysis_export#(seqMult_seq) seqMult_ap_inp;
  //This is the output for the DUT
  uvm_analysis_export#(seqMult_seq) seqMult_ap_out;

  //config class handle
  `uvm_component_utils(apb_monitor)

   function new(string name, uvm_component parent = null);
     super.new(name, parent);
   endfunction: new

   //Build Phase - Get handle to virtual if from agent/config_db
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     if(!uvm_config_db#(virtual seqMult_if)::get(this,"","seqMultvif",seqMultvif)) begin
       `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
     end
     seqMult_ap_inp = new( .name( "seqMult_ap_inp" ), .parent( this ) );
     seqMult_ap_out = new( .name( "seqMult_ap_out" ), .parent( this ) );
   endfunction

   virtual task main_phase(uvm_phase phase);
     forever begin
       seqMult_seq seq_item;

       @(posedge this.seqMultvif.sig_clk)
       begin
         if (seqMultvif.sig_ab_valid && seqMultvif.sig_ab_ready) begin
           seq_item = seqMult_seq::type_id::create( .name( "seq_item" ) );
           seq_item.a = seqMultvif.sig_a;
           seq_item.b = seqMultvif.sig_b;
           seqMult_ap_inp.write(seq_item);
         end
	 if (seqMultvif.sig_z_valid) begin
           seq_item = seqMult_seq::type_id::create( .name( "seq_item" ) );
           seq_item.z = seqMultvif.sig_z;
           seqMult_ap_out.write(seq_item);
         end
       end

     end
   endtask : main_phase

endclass: apb_monitor

class sb_comparator extends uvm_component;

  `uvm_component_utils(sb_comparator)
  uvm_analysis_export #(seqMult_seq) axp_in;
  uvm_analysis_export #(seqMult_seq) axp_out;
  uvm_tlm_analysis_fifo #(seqMult_seq) expfifo;
  uvm_tlm_analysis_fifo #(seqMult_seq) outfifo;

  int VEC_CNT, PASS_CNT, FAIL_CNT;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axp_in = new("axp_in", this);
    axp_out = new("axp_out", this);
    expfifo = new("expfifo", this);
    outfifo = new("outfifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    axp_in.connect (expfifo.analysis_export);
    axp_out.connect(outfifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    seqMult_seq exp_tr, out_tr;
    forever begin
      uvm_report_info("sb_comparator run task", "WAITING for expected output", UVM_LOW);
      expfifo.get(exp_tr);
      uvm_report_info("sb_comparator run task", "ACQUIRED expected output", UVM_LOW);
      uvm_report_info("sb_comparator run task", "WAITING for actual output", UVM_LOW);
      outfifo.get(out_tr);
      uvm_report_info("sb_comparator run task", "ACQUIRED actual output", UVM_LOW);
      if (out_tr.compare(exp_tr)) begin
        uvm_report_info ("PASS ", $sformatf("Actual=%0d Expected=%0d \n", out_tr.z, exp_tr.z), UVM_LOW);
	    PASS();
      end
      else begin
        ERROR();
      end
    end
  endtask

  function void PASS();
    VEC_CNT++;
    PASS_CNT++;
  endfunction

  function void ERROR();
    VEC_CNT++;
    ERROR_CNT++;
  endfunction

endclass


class sb_predictor extends uvm_subscriber #(seqMult_seq);
  `uvm_component_utils(sb_predictor)

  uvm_analysis_port #(seqMult_seq) results_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    results_ap = new("results_ap", this);
  endfunction

  function void write(seqMult_seq t);
    seqMult_seq exp_tr = seqMult_seq::type_id::create("exp_tr");
    exp_tr = t;
    exp_tr.z = exp_tr.a * exp_tr.b;
    //---------------------------
    //exp_tr = sb_calc_exp(t);
    results_ap.write(exp_tr);
  endfunction

endclass

//----------------------------------------------
// APB Scoreboard class
//----------------------------------------------
class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  //These are ports that are coming in from outside monitors
  uvm_analysis_export #(seqMult_seq) axp_in;
  uvm_analysis_export #(seqMult_seq) axp_out;
  sb_predictor prd;
  sb_comparator cmp;

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     axp_in = new("axp_in", this);
     axp_out = new("axp_out", this);
     prd = sb_predictor::type_id::create("prd", this);
     cmp = sb_comparator::type_id::create("cmp", this);
  endfunction
  
  function void connect_phase( uvm_phase phase );
    axp_in.connect (prd.analysis_export);
    axp_out.connect (cmp.axp_out);
    prd.results_ap.connect(cmp.axp_in);
  endfunction

endclass


`endif
