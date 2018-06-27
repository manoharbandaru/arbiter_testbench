// Code your design here
//This arbiter is with input/output signals
//TODO: move everything into interfaces and add parameters.
module arbiter(req, grnt, clk, rst_n);
  parameter int MAX_REQ = 1;
  
  input [MAX_REQ - 1:0] req;
  input  clk;
  input  rst_n;
  output [MAX_REQ - 1:0] grnt;
  
  reg [MAX_REQ - 1:0] grnt;
  
  always@(posedge clk or negedge rst_n) begin
    if(rst_n == 'b0) begin
      grnt <= '0;
    end 
    else begin
      grnt <= req;
    end
    
  end
endmodule : arbiter