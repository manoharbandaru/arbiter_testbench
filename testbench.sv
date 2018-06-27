/****************************************************************************
******************************ENV PACKAGE************************************
****************************************************************************/
package arbiter_env_pkg;
	import uvm_pkg::*;
	//Declare the classes which are going to be used in the env
	typedef arbiter_seq_item;
	typedef arbiter_env;
	typedef arbiter_agent;
	typedef arbiter_driver;
	typedef arbiter_monitor;
	typedef arbiter_scoreboard;
	typedef arbiter_coverage;

	`include "arbiter_agent.sv"
	`include "arbiter_scoreboard.sv"
	`include "arbiter_coverage.sv"
	`include "arbiter_env.sv"
endpackage : arbiter_env_pkg


/****************************************************************************
******************************TEST PACKAGE***********************************
****************************************************************************/
package test_pkg;
  import uvm_pkg::*;
  import arbiter_env_pkg::*;
  parameter int MAX_REQ = 4;

  `include "arbiter_test.sv"
endpackage : test_pkg;


/*****************************************************************************
***************************TEST BENCH*****************************************
*****************************************************************************/

module top_arbiter;
  import uvm_pkg::*;
  import test_pkg::*;
  
  reg clk;
  reg rst_n;
  reg [MAX_REQ - 1:0] req;
  reg [MAX_REQ - 1:0] grnt;
  
  //Setting interface here
  arbiter_if#(MAX_REQ) arb_interface();
  
  //Instantiating RTL
  arbiter#(MAX_REQ) roundrobin_arbiter(.*);
 
  //Assigning the signals to interface. Won't need it if we declare modports
  assign arb_interface.clk = clk;
  assign arb_interface.rst_n = rst_n;
  assign arb_interface.grnt = grnt;
  assign req = arb_interface.req;
    
  initial begin
    //Passing in the interface to the environment via config_db
    uvm_config_db#(virtual arbiter_if#(MAX_REQ))::set(null, "*", "arbiter_if", arb_interface);
    //Run Test
    run_test("test_send_req");
  end
  
  //Dump the signals.
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_arbiter);
  end
  
  //Clock generation.
  //Need clocking block?
  initial begin
    clk = 0;
    forever begin
      #2ns clk = ~clk;
    end
  end
  
  //Reset deassertion.
  initial begin
    repeat(2) @(posedge clk);
    rst_n = 'b1;
  end
endmodule : top_arbiter

/*****************************************************************************
***************************INTERFACE******************************************
*****************************************************************************/
interface arbiter_if;
  parameter int MAX_REQ = 1;
  reg [MAX_REQ - 1:0] req;
  reg [MAX_REQ - 1:0] grnt;
  reg clk;
  reg rst_n;
endinterface : arbiter_if