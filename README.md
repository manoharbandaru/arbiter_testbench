# arbiter_testbench
This is a basic parameterized testbench of an arbiter. Emphesis is more on the verification components.

TODO: Complete design, scoreboard and coverage. 

testbench.sv 
  Contains the top level instantiation of the interface, design and the test.
  Set the virtual interfaces in the config db.
  
arbiter_test.sv
  This file contains the base test and other tests which extend from it.
  
arbiter_env.sv
  Top level environment which hookes up the agent, scoreboard and coverage. Consumes virtual interface from the testbench. Should be re-usable.
  
arbiter_agent.sv
  This contains the driver, monitor and sequencer for the arbiter.
  Driver consumes the sequence items from the sequencer and drives the virtual interface.
  Monitor generates sequence items based on the pin toggling on the virtual interface.
  Sequencer in this case is the default sequencer. It passes the sequence items from the test to the driver.
  
arbiter_scoreboard.sv
  Scoreboard has analysis imp and subscribes to the monitor. This is used to verify the design. 
  
arbiter_coverage.sv
  Coverage has an analysis imp and it consumes the cycles from the scoreboard and used for coverage.
 
