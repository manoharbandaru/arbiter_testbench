class arbiter_scoreboard#(int MAX_REQ = 2) extends uvm_scoreboard;
  `uvm_component_param_utils(arbiter_scoreboard#(MAX_REQ))
  
  `uvm_analysis_imp_decl(_arb)			//No need of a custom implementation here as this scoreboard is consuming only from one monitor. But, just wanted this as an example.
  
  uvm_analysis_imp_arb#(arbiter_seq_item#(MAX_REQ), arbiter_scoreboard#(MAX_REQ)) 			arb_imp;
  
  function new (string name = "arb_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    arb_imp = new ("arb_imp", this);
  endfunction : build_phase
  
  function void write_arb(arbiter_seq_item#(MAX_REQ) seq_item);
    `uvm_info(get_name(), "Seen a sequence item", UVM_DEBUG)
  endfunction : write_arb
endclass : arbiter_scoreboard