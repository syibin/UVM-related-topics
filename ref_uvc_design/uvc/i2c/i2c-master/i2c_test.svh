`ifndef APB_BASE_TEST_SV
`define APB_BASE_TEST_SV

//--------------------------------------------------------
//Top level Test class that instantiates env, configures and starts stimulus
//--------------------------------------------------------
class apb_base_test extends uvm_test;

  //Register with factory
  `uvm_component_utils(apb_base_test);
  
  apb_env  env;
  apb_config cfg;
  virtual seqMult_if seqMultvif;
  
  function new(string name = "apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //Build phase - Construct the cfg and env class using factory
  //Get the virtual interface handle from Test and then set it config db for the env component
  function void build_phase(uvm_phase phase);
    env = apb_env::type_id::create("env",this);
    cfg = apb_config::type_id::create("cfg",this);
    
    if(!uvm_config_db#(virtual seqMult_if)::get(this,"","seqMultvif",seqMultvif)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(),".vif"});
    end
    
    //Passes down virtual interface to env
    uvm_config_db#(virtual seqMult_if)::set(this, "env", "seqMultvif", seqMultvif);
    
  endfunction

  //Run phase - Create an abp_sequence and start it on the apb_sequencer
  task run_phase( uvm_phase phase );
    apb_base_seq apb_seq;
    apb_seq = apb_base_seq::type_id::create("seqMult_seq",this);

    //Starts the sequence on the sequencer
    apb_seq.start(env.agt.sqr);
  endtask: run_phase

  virtual function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase (phase);
    uvm_top.set_timeout (10000ns);
  endfunction
  
  
endclass


`endif
