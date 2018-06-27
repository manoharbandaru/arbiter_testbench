class arbiter_coverage#(int MAX_REQ = 2) extends uvm_subscriber#(arbiter_seq_item);
  `uvm_component_param_utils(arbiter_coverage#(MAX_REQ))
  function new (string name = "arb_cov", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  //Default write function for the subscriber export.
  virtual function void write(arbiter_seq_item seq_item);
  endfunction : write
  
endclass : arbiter_coverage