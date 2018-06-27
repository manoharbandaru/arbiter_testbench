//Sequence Item class	
class arbiter_seq_item#(int MAX_REQ = 2) extends uvm_sequence_item;
  `uvm_object_param_utils(arbiter_seq_item#(MAX_REQ))
  rand int req;
  int grnt;
  constraint req_c {
    req inside {[0:MAX_REQ-1]};
  }
  function new (string name = "seq_item");
    super.new(name);
  endfunction : new
endclass : arbiter_seq_item

//Sequence
class arbiter_send_req#(int MAX_REQ = 2) extends uvm_sequence;
  `uvm_object_param_utils(arbiter_send_req#(MAX_REQ))
  rand int request;
  constraint request_c {
    request inside {[0:MAX_REQ-1]};
  }
  
  function new (string name = "send_req");
    super.new(name);
  endfunction : new
  
  task body();
    arbiter_seq_item#(MAX_REQ) seq_item;
    `uvm_info(get_name(), "Entered body task", UVM_DEBUG)
    seq_item = arbiter_seq_item#(MAX_REQ)::type_id::create("seq_item");
    seq_item.randomize() with {req == request;};
    `uvm_info(get_name(), "Randomizing the sequence item done. Sending sequence item", UVM_DEBUG)
    `uvm_send(seq_item);
    `uvm_info(get_name(), "Exiting body task", UVM_DEBUG)
  endtask : body
endclass : arbiter_send_req


/**************************************************************
Arbiter Driver. This class drives the virtual interface
based on the seqeunce item passed on to it. Sequences via
the sequencer send the sequece item to the driver typically.
**************************************************************/
class arbiter_driver#(int MAX_REQ = 2) extends uvm_driver #(arbiter_seq_item#(MAX_REQ));	
  `uvm_component_param_utils(arbiter_driver#(MAX_REQ))
  //Declare the vif and the sequence item
  virtual arbiter_if#(MAX_REQ)		v_if;
  arbiter_seq_item#(MAX_REQ)		seq_item, item;
  
  function new (string name = "arb_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual arbiter_if#(MAX_REQ))::get(this, "", "arbiter_if", v_if)) `uvm_fatal(get_name(), "Virtual Interface not set")
  endfunction : build_phase
  
  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    fork
      forever begin
        drive_vif();
      end
    join_none
    endtask : main_phase
    
    task drive_vif();
      seq_item_port.get_next_item(item);		//Wait for next item from the sequencer
      $cast(seq_item, item);					//Cast the item into a local object. Just to make sure we don't modify the seq item accidentally. As its a sigle item that is being passed around.
      `uvm_info(get_name(), $psprintf("Seen sequence item at %0d, req value = %0d", $time, seq_item.req), UVM_DEBUG);
      //This is a pretty straight forward driver. Just pass the value in seq item into the vif. More complex drivers may need logic here.
      v_if.req 		<= seq_item.req;
      seq_item_port.item_done();				//Tell the seqencer that the item is done. No response from the driver as its a simple req/grnt.	TODO: Will sending grant in the response help?
    endtask : drive_vif
endclass : arbiter_driver
      

/**************************************************************
Arbiter Monitor. This class monitors the virtual interface
and sends out the sequence item. Scoreboard/coverage are the
typical consumers.
**************************************************************/
class arbiter_monitor#(int MAX_REQ = 2) extends uvm_monitor;
  `uvm_component_param_utils(arbiter_monitor#(MAX_REQ))
  
  //Declaring virtual interface and analysis port
  uvm_analysis_port#(arbiter_seq_item#(MAX_REQ))	arb_port;
  arbiter_seq_item#(MAX_REQ)						seq_item;
  virtual arbiter_if#(MAX_REQ)						v_if;

  
  function new (string name = "arb_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual arbiter_if#(MAX_REQ))::get(this, "", "arbiter_if", v_if)) `uvm_fatal(get_name(), "Virtual Interface Not set.")

      arb_port = new("arb_port", this);
  endfunction : build_phase
      
  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    seq_item = arbiter_seq_item#(MAX_REQ)::type_id::create("arb_seq_item");
    //Put the monitor_vif in a forever method as it has to always run and monitor the signals.
    fork
      forever begin
      	monitor_vif();
      end
    join_none
  endtask : main_phase
  
  virtual task monitor_vif();
    @(posedge v_if.clk);	//Wait for the posedge of clk
    //If the value of the interface changes, then send the seq_item. Else, we are just send the same seq_item over and over again on every clk edge.
    //Can also do @(req/grnt) instead of @clk.
    if ((seq_item.req != v_if.req) || (seq_item.grnt != v_if.grnt)) begin
      seq_item.randomize() with {req == v_if.req;};
      seq_item.grnt = v_if.grnt;
      arb_port.write(seq_item);										//Write to the analysis port.
    end    
  endtask : monitor_vif
  
  assertions();
endclass : arbiter_monitor
    
/**************************************************************
Arbiter Agent. This contains driver, monitor and sequencer.
**************************************************************/

class arbiter_agent#(int MAX_REQ = 2) extends uvm_component;
  `uvm_component_param_utils_begin(arbiter_agent#(MAX_REQ))
  	`uvm_field_enum(uvm_active_passive_enum, uvm_active_passive, UVM_ALL_ON)
  `uvm_component_utils_end

  uvm_sequencer#(arbiter_seq_item#(MAX_REQ))		arb_sequencer;
  arbiter_driver#(MAX_REQ)							arb_driver;
  arbiter_monitor#(MAX_REQ)							arb_monitor;
  uvm_active_passive_enum 							uvm_active_passive;
  uvm_analysis_export#(arbiter_seq_item#(MAX_REQ))	arb_export;
  
  function new (string name = "arb_agent", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //Construct the sequencer and driver only if the agent is active.
    if (uvm_active_passive == UVM_ACTIVE) begin
      arb_sequencer = uvm_sequencer#(arbiter_seq_item#(MAX_REQ))::type_id::create("arbiter_sequencer", this);
      `uvm_info(get_name(), "Creating sequencer and driver in the agent", UVM_DEBUG)
      arb_driver = arbiter_driver#(MAX_REQ)::type_id::create("arbiter_driver", this);
    end
    //Monitor is always active.
    arb_monitor = arbiter_monitor#(MAX_REQ)::type_id::create("arbiter_monitor", this);
    //Build the arbiter export to expose it to env
    arb_export = new("arb_export", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Driver/sequencer are active only if the agent is active.
    if (uvm_active_passive == UVM_ACTIVE) begin
      arb_driver.seq_item_port.connect(arb_sequencer.seq_item_export);	//Driver will have inbuilt seq_item_port if it extends from uvm_driver.
    end
    arb_monitor.arb_port.connect(arb_export);							//Connect the monitor's port to agent's export.
  endfunction : connect_phase
endclass : arbiter_agent