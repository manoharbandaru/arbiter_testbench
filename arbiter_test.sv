//Base test
class test_base extends uvm_test;
  `uvm_component_utils(test_base)
  arbiter_env#(MAX_REQ) 		env;
  arbiter_send_req#(MAX_REQ) 	seq_send_req;
    
  function new(string name = "test_base", uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //Setting config variables
    uvm_config_db#(int)::set(this, "arb_env", "coverage_enable", 1);
    uvm_config_db#(int)::set(this, "arb_env", "scoreboard_enable", 1);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "*", "uvm_active_passive", UVM_ACTIVE);
    
    //Creating the env. That takes care of agent/scoreboard/cov
    env = arbiter_env#(MAX_REQ)::type_id::create("arb_env", this);
      
    //Creating the sequence. Multuple tests can re-use it instead of creating.
    seq_send_req = arbiter_send_req#(MAX_REQ)::type_id::create("send_req");
  endfunction : build_phase
    
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    #50ns;
    phase.drop_objection(this);
  endtask : main_phase
    
endclass : test_base

//Tests 
class test_send_req extends test_base;
  `uvm_component_utils(test_send_req)
  function new(string name = "test_send_req", uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    #10ns;
    seq_send_req.randomize();
    seq_send_req.start(env.agent.arb_sequencer);					//Have to pass in the sequencer for the sequence to run on.
    #5ns;
    phase.drop_objection(this);
  endtask : main_phase    
endclass : test_send_req

class test_default_sequence extends test_base;
  `uvm_component_utils(test_default_sequence)
  function new(string name = "test_default_sequence", uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(null, "/.*sequencer.run_phase/", "default_sequence", arbiter_send_req#(MAX_REQ)::get_type());
  endfunction : build_phase
endclass : test_default_sequence
