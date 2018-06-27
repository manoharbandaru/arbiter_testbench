//This class contains the environment, agents and other parts of the verifaction components which are required for arbiter
class arbiter_env#(int MAX_REQ = 2) extends uvm_env;
  
  
  uvm_active_passive_enum 			uvm_active_passive;
  int								coverage_enable;
  int								scoreboard_enable;
  arbiter_agent#(MAX_REQ) 			agent;
  arbiter_scoreboard#(MAX_REQ) 		scoreboard;
  arbiter_coverage#(MAX_REQ)		coverage;
  virtual arbiter_if#(MAX_REQ)		v_if;
  
  `uvm_component_param_utils_begin(arbiter_env#(MAX_REQ))
  	`uvm_field_int (coverage_enable, UVM_ALL_ON)
  	`uvm_field_int (scoreboard_enable, UVM_ALL_ON)
  	`uvm_field_enum (uvm_active_passive_enum, uvm_active_passive, UVM_ALL_ON)
  `uvm_component_utils_end
  
  function new (string name = "arb_env", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual arbiter_if#(MAX_REQ))::get(this, "", "arbiter_if", v_if)) `uvm_fatal(get_name(), "Virtual Interface Not set.")
    
    `uvm_info(get_name(), $psprintf("scoreboard_enable = %0b, coverage_enable = %0b, active_passive = %0b", scoreboard_enable, coverage_enable, uvm_active_passive), UVM_DEBUG)
    
    if (scoreboard_enable == 1) begin
      scoreboard = arbiter_scoreboard#(MAX_REQ)::type_id::create("arbiter_scoreboard", this);
    end
    if (coverage_enable == 1) begin
      coverage = arbiter_coverage#(MAX_REQ)::type_id::create("arbiter_coverage", this);
    end
    agent = arbiter_agent#(MAX_REQ)::type_id::create("arbiter_agent", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Connect Agent's export to the scoreboard's imp
    agent.arb_export.connect(scoreboard.arb_imp);
  endfunction : connect_phase
  
endclass : arbiter_env